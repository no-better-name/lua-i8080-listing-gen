local intel8080 = require "intel8080"
local inspect = require "inspect"
local lpeg = require "lpeg"

peek = function(arg)
    print(inspect(arg))
end

assert(intel8080)
assert(intel8080.langdef)
assert(intel8080.parsing)
assert(intel8080.assembly)
assert(intel8080.formatting)

function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return table.concat(t)
end

assert(intel8080.parsing.register.A:match("a") == "A")
assert(intel8080.parsing.register.B:match("B") == "B")
assert(intel8080.parsing.register_pair.SP:match("sp") == "SP")
assert(intel8080.parsing.register_pair.PSW:match("PSW") == "PSW")

local numeric =
    intel8080.parsing.numeric.hex
    + intel8080.parsing.numeric.oct
    + intel8080.parsing.numeric.bin
    + intel8080.parsing.numeric.dec

for i = 0, 65535 do
    local vals = {
        {match = string.format("%04Xh", i), value = string.format("%04X", i), radix = "16"},
        {match = string.format("%06oo", i), value = string.format("%06o", i), radix = "8"},
        {match = string.format("%06oq", i), value = string.format("%06o", i), radix = "8"},
        {match = string.format("%05dd", i), value = string.format("%05d", i), radix = "10"},
        {match = string.format("%05d", i), value = string.format("%05d", i), radix = "10"},
        {match = toBits(i, 16) .. "b", value = toBits(i, 16), radix = "2"},
        {match = string.format("%Xh", i), value = string.format("%X", i), radix = "16"},
        {match = string.format("%oo", i), value = string.format("%o", i), radix = "8"},
        {match = string.format("%oq", i), value = string.format("%o", i), radix = "8"},
        {match = string.format("%dd", i), value = string.format("%d", i), radix = "10"},
        {match = string.format("%d", i), value = string.format("%d", i), radix = "10"},
        {match = toBits(i) .. "b", value = toBits(i), radix = "2"},
    }

    for pos, item in ipairs(vals) do
        local match = numeric:match(item.match)
        assert(match.value == item.value and match.radix == item.radix)
    end
end

assert(intel8080.parsing.label:match("fumofumo") == "fumofumo")
assert(intel8080.parsing.label:match("FumoFumo") == "FumoFumo")
assert(intel8080.parsing.label:match("fumo-fumo") == "fumo-fumo")
assert(intel8080.parsing.label:match("fumo_fumo") == "fumo_fumo")
assert(intel8080.parsing.label:match("1fumofumo") == nil)
assert(intel8080.parsing.label:match("fumofumo1") == "fumofumo1")

local expression = intel8080.parsing.expression.rule * lpeg.P (-1)
for _, val in ipairs ({"1D", "", "99O", "03H", "35O", "55H + 3", "$ + 3", "fumo + 1", "00FFh or FF00h", "3*5 + 7 EQ 22 AND 0 NE 1", "NOT (5 EQ 3) OR NOT (5 NE 3)"}) do
    print (val .. ": " .. inspect (expression:match(val)))
end

local cmd = intel8080.parsing.cmd * lpeg.P (-1)
for _, val in ipairs ({"ADI 55H", "MOV B", "INX", "STAX D", "MVI M, 32H", "RST 0H", "RST fumo", "SHLD 0990H"}) do
    print (val .. ": " .. inspect (cmd:match(val)))
end

local line = intel8080.parsing.line * lpeg.P (-1)
for _, val in ipairs ({
    "fumo: ADI 55H ; comment",
    "IN 05H ; фумофумо на русском",
    "INX SP",
    "MOV A, C",
    "fumo: MOV A ; comment",
    "MVI",
}) do
    print (val .. ": " .. inspect (line:match(val)))
end

local listing = intel8080.parsing.listing
for _, val in ipairs ({
    [==[
    memcpy:
    ldax d ;  Байт считывается из источника\ldots
    mov m, a ; \ldots{} и он записывается по адресу назначения
    inx d ; Следующая ячейка памяти источника\ldots
    inx h ; Следующая ячейка памяти назначения\ldots
    dcr c ; Одним байтом меньше, декремент счётчика
    jnz memcpy ; Если есть ещё байты, продолжить копирование
    ret ; Выход из подпрограммы
    ]==],
    [==[
    delay:
    CALL 01C8H
    DCX B
    XRA A
    CMP B
    JNZ delay
    CMP C
    JNZ delay
    RET
    ]==], 
    [==[
    main_mode0:
    mvi A, 10001011B
    out B3H

    body_mode0:
    in B1H
    call nibl_sub
    out B0H
    jmp body_mode0
    ]==], 
}) do
    print (val .. ": " .. inspect (listing:match(val)))
end

assert (intel8080.assembly.to_unsigned_word(15) == 15)
assert (intel8080.assembly.to_unsigned_word(-1) == 65535)
assert (intel8080.assembly.to_unsigned_word(32768) == 32768)
assert (intel8080.assembly.to_unsigned_word(65536) == 0)

assert (intel8080.assembly.unary_operation["-"](1) == 65535)
assert (intel8080.assembly.unary_operation["NOT"](0xFF00) == 0x00FF)
assert (intel8080.assembly.unary_operation["HIGH"](0xFF00) == 0x00FF)
assert (intel8080.assembly.unary_operation["LOW"](0xFF00) == 0)

assert (intel8080.assembly.binary_operation["+"](0xFFFF, 1) == 0)
assert (intel8080.assembly.binary_operation["-"](0, 1) == 0xFFFF)

local expression = intel8080.parsing.expression.rule * lpeg.P (-1)
for _, val in ipairs ({"1D", "03H", "35O", "55H + 3", "$ + 3", "fumo + 1", "00FFh or FF00h", "3*5 + 7 EQ 22 AND 0 NE 1", "NOT (5 EQ 3) OR NOT (5 NE 3)"}) do
    print (val .. ": " .. intel8080.assembly.evaluate_expression (expression:match(val), 0x0000, {fumo = 10}))
end

local listing = intel8080.parsing.listing
for _, val in ipairs ({
    [==[
    memcpy:
    ldax d ;  Байт считывается из источника\ldots
    mov m, a ; \ldots{} и он записывается по адресу назначения
    inx d ; Следующая ячейка памяти источника\ldots
    inx h ; Следующая ячейка памяти назначения\ldots
    dcr c ; Одним байтом меньше, декремент счётчика
    jnz memcpy ; Если есть ещё байты, продолжить копирование
    ret ; Выход из подпрограммы
    ]==],
    [==[
    delay:
    CALL 01C8H
    DCX B
    XRA A
    CMP B
    JNZ delay
    CMP C
    JNZ delay
    RET
    ]==], 
    [==[
    main_mode0:
    mvi A, 10001011B
    out B3H

    body_mode0:
    in B1H
    call nibl_sub
    out B0H
    jmp body_mode0
    ]==], 
}) do
    print (val .. ": " .. inspect (intel8080.assembly.assemble (val, 0x0800, {nibl_sub = 0x0900})))
end
