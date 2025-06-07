local intel8080 = require "intel8080"
local inspect = require "inspect"

peek = function(arg)
    print(inspect(arg))
end

assert(intel8080)
assert(intel8080.langdef)
assert(intel8080.parsing)
assert(intel8080.assembly)

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
        -- if match == nil then
        --     print("item" .. inspect(item))
        -- end

        -- if match.value ~= item.value or match.radix ~= item.radix then
        --     print("match" .. inspect(match))
        --     print("item" .. inspect(item))
        -- end

        assert(match.value == item.value and match.radix == item.radix)
    end
end

local pretty = intel8080.formatting.make_text_listing

print(pretty(
[==[
MVI  C,F8H   ; Инициализация счетчика
LXI  H,0810H ; Инициализация указателя
MVI A,55H    ; Переслать 55 в A
SUB M        ; Вычитание А из М
JNZ 0ABAH    ; Возвращение в цикл, если не равен 0
INX H        ; Инкремент указателя
MVI A,AAH    ; Переслать AA в A
SUB M        ; Вычитание А из М
JNZ 0ABAH    ; Возвращение в цикл, если не равен 0
INX H        ; Инкремент указателя
DCR C        ; Декремент счетчика
JNZ 0AA5H    ; Возвращение в цикл, если не равен 0
JMP 05B0H    ; Мелодия
MVI C, AH    ; Инициализация счетчика
LXI D, 0BF5H ; Инициализация указателя
MOV A, L     ; Переслать L в A
RRC          ; Сдвиг содержимого аккумулятора вправо
RRC          ; Сдвиг содержимого аккумулятора вправо
RRC          ; Сдвиг содержимого аккумулятора вправо
RRC          ; Сдвиг содержимого аккумулятора вправо
ANI 0FH      ; Сброс (выделение полубайта из байта)
STAX D       ; Сохранение в память
DCX D        ; Декремент указателя
MOV A, H     ; Переслать H в A
ANI 0FH      ; Сброс (выделение полубайта из байта)
STAX D       ; Сохранение в память
DCX D        ; Декремент указателя
MOV A, M     ; Переслать M в A
MOV H, L     ; Переслать L в H
MOV L, A     ; Переслать A в L
DCR C        ; Декремент счетчика
JNZ 0ABFH    ; Возвращение в цикл, если не равен 0
CALL 01E9H   ; Вывод сообщения на дисплей
CALL 01C8H    
JMP 0AD7H     
]==]
, 0x0AA0))
