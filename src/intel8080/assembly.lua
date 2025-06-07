local Intel8080 = require "intel8080.parsing"
Intel8080.assembly = {}

Intel8080.assembly.to_signed_word = function (val)
    return ((val + 0x7FFF) & 0xFFFF) - 0x7FFF
end

Intel8080.assembly.match_to_number = function (num_match)
    return tonumber(num_match.value, num_match.radix)
end

Intel8080.assembly.unary_operation = {
    ["-"] = function (rhs)
        return Intel8080.assembly.to_signed_word(-rhs)
    end,
    ["NOT"] = function (rhs)
        return Intel8080.assembly.to_signed_word(~rhs)
    end,
    ["HIGH"] = function (rhs)
        return Intel8080.assembly.to_signed_word((rhs & 0xFF00) >> 8)
    end,
    ["LOW"] = function (rhs)
        return Intel8080.assembly.to_signed_word(rhs & 0x00FF)
    end,
}

Intel8080.assembly.binary_operation = {
    ["+"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs + rhs)
    end,
    ["-"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs - rhs)
    end,
    ["*"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs * rhs)
    end,
    ["/"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs // rhs)
    end,
    ["MOD"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs % rhs)
    end,
    ["SHL"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word((lhs & 0xFFFF) << rhs)
    end,
    ["SHR"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word((lhs & 0xFFFF) >> rhs)
    end,
    ["EQ"] = function (lhs, rhs)
        if lhs == rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["NE"] = function (lhs, rhs)
        if lhs ~= rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["LT"] = function (lhs, rhs)
        if lhs < rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["LE"] = function (lhs, rhs)
        if lhs <= rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["GT"] = function (lhs, rhs)
        if lhs > rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["GE"] = function (lhs, rhs)
        if lhs >= rhs then
            return -0x0001
        else
            return 0x0000
        end
    end,
    ["AND"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs & rhs)
    end,
    ["OR"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs | rhs)
    end,
    ["XOR"] = function (lhs, rhs)
        return Intel8080.assembly.to_signed_word(lhs ~ rhs)
    end,
}

Intel8080.assembly.evaluate_expression = function (expr, loc_counter, labels)
    local result
    if not (expr.binary_operations and expr.operands) then
        if expr.numeric then
            result = Intel8080.assembly.to_signed_word(
                Intel8080.assembly.match_to_number(expr.numeric)
            )
        end
        if expr.location_counter then
            result = Intel8080.assembly.to_signed_word(
                loc_counter
            )
        end
        if expr.label then
            result = Intel8080.assembly.to_signed_word(
                labels[expr.label]
            )
        end
        if expr.ascii then
            result = {utf8.codepoint(expr.ascii, 1, 2)}
            result = Intel8080.assembly.to_signed_word(
                (result[1] << 8) + result[2]
            )
        end
        if expr.expression then
            result = Intel8080.assembly.to_signed_word(
                Intel8080.assembly.evaluate_expression(expr.expression, loc_counter, labels)
            )
        end

        for i = #expr.unary_operations, 1, -1 do
            result = Intel8080.assembly.unary_operation[expr.unary_operations[i]](result)
        end
    else
        result = Intel8080.assembly.to_signed_word(
            Intel8080.assembly.evaluate_expression(expr.operands[1], loc_counter, labels)
        )
        for i = 1, #expr.binary_operations do
            local rhs = Intel8080.assembly.evaluate_expression(expr.operands[i + 1], loc_counter, labels)
            result = Intel8080.assembly.binary_operation[expr.binary_operations[i]](result, rhs)
        end
    end

    return result
end

Intel8080.assembly.assemble = function (code, location_counter, labels)
    location_counter = location_counter or 0x0000
    labels = labels or {}
    local starting_location_counter = location_counter
    code = Intel8080.parsing.listing:match(code)

    -- pass 1
    for _, line in ipairs(code) do
        if line.label then
            labels[line.label] = location_counter
        end

        if line.cmd then
            location_counter = location_counter + #line.cmd.bytes
            location_counter = location_counter & 0xFFFF
        end
    end

    location_counter = starting_location_counter
    -- pass 2
    for _, line in ipairs(code) do
        line.location_counter = location_counter

        if line.label then
            labels[line.label] = location_counter
        end

        if line.cmd then
            if line.cmd.args then
                if line.cmd.args[#line.cmd.args].byte then
                    local val = Intel8080.assembly.evaluate_expression(line.cmd.args[#line.cmd.args].byte, location_counter, labels)
                    line.cmd.bytes[2] = val & 0x00FF
                elseif line.cmd.args[#line.cmd.args].word then
                    local val = Intel8080.assembly.evaluate_expression(line.cmd.args[#line.cmd.args].word, location_counter, labels)
                    line.cmd.bytes[2] = val & 0x00FF
                    line.cmd.bytes[3] = (val & 0xFF00) >> 8
                elseif line.cmd.args[#line.cmd.args].faux then
                    local val = Intel8080.assembly.evaluate_expression(line.cmd.args[#line.cmd.args].faux, location_counter, labels)
                    line.cmd.bytes[1] = line.cmd.bytes[1][val]
                    if line.cmd.bytes[1] == nil then
                        error("malformed faux argument to " .. line.cmd.cmd_name)
                    end
                end
            end

            location_counter = location_counter + #line.cmd.bytes
            location_counter = location_counter & 0xFFFF
        end
    end

    return code
end

return Intel8080
