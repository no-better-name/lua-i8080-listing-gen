local Intel8080 = require "intel8080.langdef"
lpeg = require "lpeg"

Intel8080.parsing = {}

Intel8080.parsing.blank = lpeg.S(utf8.char(0x20, 0x09))
Intel8080.parsing.arg_sep = lpeg.P ","
Intel8080.parsing.label_delim = lpeg.P ":"
Intel8080.parsing.comment_delim = lpeg.P ";"
Intel8080.parsing.newline = lpeg.P "\n"

Intel8080.parsing.register = {
    A = lpeg.Cg((lpeg.P "A" + lpeg.P "a") / string.upper),
    B = lpeg.Cg((lpeg.P "B" + lpeg.P "b") / string.upper),
    C = lpeg.Cg((lpeg.P "C" + lpeg.P "c") / string.upper),
    D = lpeg.Cg((lpeg.P "D" + lpeg.P "d") / string.upper),
    E = lpeg.Cg((lpeg.P "E" + lpeg.P "e") / string.upper),
    H = lpeg.Cg((lpeg.P "H" + lpeg.P "h") / string.upper),
    L = lpeg.Cg((lpeg.P "L" + lpeg.P "l") / string.upper),
    M = lpeg.Cg((lpeg.P "M" + lpeg.P "m") / string.upper),
}

Intel8080.parsing.register_pair = {
    B = lpeg.Cg((lpeg.P "B" + lpeg.P "b") / string.upper),
    D = lpeg.Cg((lpeg.P "D" + lpeg.P "d") / string.upper),
    H = lpeg.Cg((lpeg.P "H" + lpeg.P "h") / string.upper),

    SP = lpeg.Cg((lpeg.P "SP" + lpeg.P "sp") / string.upper),
    PC = lpeg.Cg((lpeg.P "PC" + lpeg.P "pc") / string.upper),

    PSW = lpeg.Cg((lpeg.P "PSW" + lpeg.P "psw") / string.upper),
}

Intel8080.parsing.numeric = {
    bin = lpeg.Ct(lpeg.Cg(lpeg.R "01"^1, "value")
        * lpeg.Cg(lpeg.S "Bb" / "2", "radix")),

    oct = lpeg.Ct(lpeg.Cg(lpeg.R "07"^1, "value")
        * lpeg.Cg(lpeg.S "OoQq" / "8", "radix")),

    dec = lpeg.Ct(lpeg.Cg(lpeg.R "09"^1, "value")
        * lpeg.Cg(lpeg.S "Dd"^-1 / "10", "radix")),

    hex = lpeg.Ct(lpeg.Cg((lpeg.R "09" + lpeg.R "af" + lpeg.R "AF")^0 / string.upper, "value")
        * lpeg.Cg(lpeg.S "Hh" / "16", "radix")),
}

Intel8080.parsing.location_counter = lpeg.Cg (lpeg.P "$")

Intel8080.parsing.label
    = lpeg.Cg((lpeg.R("az", "AZ") + lpeg.S "_-" + lpeg.P "@" + lpeg.P "?") * (lpeg.R("az", "AZ", "09") + lpeg.S "_-")^0)

Intel8080.parsing.operation = {
    OR    = lpeg.Cg ((lpeg.P "OR" + lpeg.P "or") / string.upper),
    XOR   = lpeg.Cg ((lpeg.P "XOR" + lpeg.P "xor") / string.upper),
    AND   = lpeg.Cg ((lpeg.P "AND" + lpeg.P "and") / string.upper),
    NOT   = lpeg.Cg ((lpeg.P "NOT" + lpeg.P "not") / string.upper),
    EQ    = lpeg.Cg ((lpeg.P "EQ" + lpeg.P "eq") / string.upper),
    LT    = lpeg.Cg ((lpeg.P "LT" + lpeg.P "lt") / string.upper),
    LE    = lpeg.Cg ((lpeg.P "LE" + lpeg.P "le") / string.upper),
    GT    = lpeg.Cg ((lpeg.P "GT" + lpeg.P "gt") / string.upper),
    GE    = lpeg.Cg ((lpeg.P "GE" + lpeg.P "ge") / string.upper),
    NE    = lpeg.Cg ((lpeg.P "NE" + lpeg.P "ne") / string.upper),
    MOD   = lpeg.Cg ((lpeg.P "MOD" + lpeg.P "mod") / string.upper),
    SHL   = lpeg.Cg ((lpeg.P "SHL" + lpeg.P "shl") / string.upper),
    SHR   = lpeg.Cg ((lpeg.P "SHR" + lpeg.P "shr") / string.upper),
    HIGH  = lpeg.Cg ((lpeg.P "HIGH" + lpeg.P "high") / string.upper),
    LOW   = lpeg.Cg ((lpeg.P "LOW" + lpeg.P "low") / string.upper),
    PLUS  = lpeg.Cg (lpeg.P "+"),
    MINUS = lpeg.Cg (lpeg.P "-"),
    TIMES = lpeg.Cg (lpeg.P "*"),
    DIV   = lpeg.Cg (lpeg.P "/"),
}

Intel8080.parsing.expression = {}

Intel8080.parsing.expression.flatten = function (expr)
    if type(expr) == "table" and #expr == 1 then
        expr = expr[1]
    end
    return expr
end

Intel8080.parsing.expression.collect = function (expr)
    if not expr[1] then return expr end

    expr.binary_operations = {}
    expr.operands = {}

    for key, value in ipairs(expr) do
        if value.binary_operation then
            table.insert(expr.binary_operations, value.binary_operation)
        else
            table.insert(expr.operands, value)
        end
        expr[key] = nil
    end

    return expr
end

Intel8080.parsing.expression.rule =
    lpeg.P {
        [1] = "expression",
        expression = lpeg.Ct(
            lpeg.Cg(lpeg.V "disjunct")
            * (
                Intel8080.parsing.blank^1
                * lpeg.Ct(lpeg.V "disjunction")
                * Intel8080.parsing.blank^1
                * lpeg.Cg(lpeg.V "disjunct")
            )^0
        ) / Intel8080.parsing.expression.flatten / Intel8080.parsing.expression.collect,

        disjunct = lpeg.Ct(
            lpeg.Cg(lpeg.V "conjuct")
            * (
                Intel8080.parsing.blank^1
                * lpeg.Ct(lpeg.V "conjunction")
                * Intel8080.parsing.blank^1
                * lpeg.Cg(lpeg.V "conjuct")
            )^0
        ) / Intel8080.parsing.expression.flatten / Intel8080.parsing.expression.collect,

        conjuct = lpeg.Ct(
            lpeg.Cg(lpeg.V "comparison_operand")
            * (
                Intel8080.parsing.blank^1
                * lpeg.Ct(lpeg.V "comparison")
                * Intel8080.parsing.blank^1
                * lpeg.Cg(lpeg.V "comparison_operand")
            )^0
        ) / Intel8080.parsing.expression.flatten / Intel8080.parsing.expression.collect,

        comparison_operand = lpeg.Ct(
            lpeg.Cg(lpeg.V "factor")
            * (
                Intel8080.parsing.blank^0
                * lpeg.Ct(lpeg.V "addition")
                * Intel8080.parsing.blank^0
                * lpeg.Cg(lpeg.V "factor")
            )^0
        ) / Intel8080.parsing.expression.flatten / Intel8080.parsing.expression.collect,

        factor = lpeg.Ct(
            lpeg.Cg(lpeg.V "value")
            * (
                (
                    Intel8080.parsing.blank^0
                    * lpeg.Ct(lpeg.V "multiplication_symbol")
                    * Intel8080.parsing.blank^0
                    * lpeg.Cg(lpeg.V "value")
                )
                +
                (
                    Intel8080.parsing.blank^1
                    * lpeg.Ct(lpeg.V "multiplication_name")
                    * Intel8080.parsing.blank^1
                    * lpeg.Cg(lpeg.V "value")
                )
            )^0
        ) / Intel8080.parsing.expression.flatten / Intel8080.parsing.expression.collect,

        value = lpeg.Ct(
            lpeg.Cg(
                lpeg.Ct(
                    (
                        (
                            lpeg.V "unary_operation_symbol"
                            * Intel8080.parsing.blank^0
                        )
                        +
                        (
                            lpeg.V "unary_operation_name"
                            * Intel8080.parsing.blank^1
                        )
                    )^0
                )
                , "unary_operations"
            )
            * (
                lpeg.V "number"
                + lpeg.V "loc_counter"
                + lpeg.V "asm_label"
                + (
                    lpeg.P "("
                    * Intel8080.parsing.blank^0
                    * lpeg.Cg(lpeg.V "expression", "expression")
                    * Intel8080.parsing.blank^0
                    * lpeg.P ")"
                )
            )
        ),

        disjunction = lpeg.Cg(Intel8080.parsing.operation.OR + Intel8080.parsing.operation.XOR, "binary_operation"),
        conjunction = lpeg.Cg(Intel8080.parsing.operation.AND, "binary_operation"),
        unary_operation_name = lpeg.Cg(
            Intel8080.parsing.operation.NOT
            + Intel8080.parsing.operation.HIGH
            + Intel8080.parsing.operation.LOW
        ),
        unary_operation_symbol = lpeg.Cg(
            Intel8080.parsing.operation.MINUS
        ),
        comparison = lpeg.Cg(
            Intel8080.parsing.operation.EQ
            + Intel8080.parsing.operation.LT
            + Intel8080.parsing.operation.LE
            + Intel8080.parsing.operation.GT
            + Intel8080.parsing.operation.GE
            + Intel8080.parsing.operation.NE
            , "binary_operation"
        ),
        addition = lpeg.Cg(Intel8080.parsing.operation.PLUS + Intel8080.parsing.operation.MINUS, "binary_operation"),
        multiplication_symbol = lpeg.Cg(Intel8080.parsing.operation.TIMES + Intel8080.parsing.operation.DIV, "binary_operation"),
        multiplication_name = lpeg.Cg(Intel8080.parsing.operation.MOD + Intel8080.parsing.operation.SHL + Intel8080.parsing.operation.SHR, "binary_operation"),
        number = lpeg.Cg(
            Intel8080.parsing.numeric.hex
            + Intel8080.parsing.numeric.oct
            + Intel8080.parsing.numeric.bin
            + Intel8080.parsing.numeric.dec
            , "numeric"
        ),
        loc_counter = lpeg.Cg(Intel8080.parsing.location_counter, "location_counter"),
        asm_label = lpeg.Cg(Intel8080.parsing.label, "label"),
    }

local generate_cmds = function (instructions)
    local final_result = nil

    for name, contents in pairs(instructions) do
        local cmd_name = lpeg.Cg(
            (lpeg.P(string.upper(name)) + lpeg.P(string.lower(name))) / string.upper
            , "cmd_name"
        )

        for _, variation_contents in ipairs(contents) do
            local next_cmd = cmd_name
            local arg_list = nil
            local byte_count = 1

            for _, arg_contents in ipairs(variation_contents.args) do
                local next_arg = nil

                if arg_contents.register then
                    next_arg = lpeg.Cg(Intel8080.parsing.register[arg_contents.register], "register")
                    next_arg = lpeg.Ct(next_arg)
                elseif arg_contents.register_pair then
                    next_arg = lpeg.Cg(Intel8080.parsing.register_pair[arg_contents.register_pair], "register_pair")
                    next_arg = lpeg.Ct(next_arg)
                elseif arg_contents.byte then
                    next_arg = lpeg.Cg(Intel8080.parsing.expression.rule, "byte")
                    next_arg = lpeg.Ct(next_arg)
                    byte_count = byte_count + 1
                elseif arg_contents.word then
                    next_arg = lpeg.Cg(Intel8080.parsing.expression.rule, "word")
                    next_arg = lpeg.Ct(next_arg)
                    byte_count = byte_count + 2
                elseif arg_contents.faux then
                    next_arg = lpeg.Cg(Intel8080.parsing.expression.rule, "faux")
                    next_arg = lpeg.Ct(next_arg)
                end

                if arg_list == nil then
                    arg_list = lpeg.Cg(next_arg)
                else
                    arg_list = arg_list * Intel8080.parsing.blank^0 * Intel8080.parsing.arg_sep * Intel8080.parsing.blank^0 * lpeg.Cg(next_arg)
                end
            end

            if arg_list then
                arg_list = lpeg.Cg(lpeg.Ct(arg_list), "args")
                next_cmd = lpeg.Ct(
                    next_cmd * Intel8080.parsing.blank^1 * arg_list
                )
            else
                next_cmd = lpeg.Ct(next_cmd)
            end

            next_cmd = next_cmd
                / function (full_cmd)
                    full_cmd.bytes = {}
                    for i = 1, byte_count do
                        full_cmd.bytes[i] = 0
                    end
                    full_cmd.bytes[1] = variation_contents.cmd
                    return full_cmd
                end

            if final_result == nil then
                final_result = next_cmd
            else
                final_result = final_result + next_cmd
            end
        end
    end

    return final_result
end

Intel8080.parsing.cmd = generate_cmds(Intel8080.langdef.opcodes)

Intel8080.parsing.line = lpeg.P {
    [1] = "line",
    -- line = lpeg.Ct(
    --     (
    --         Intel8080.parsing.blank^0
    --         * lpeg.V "label"
    --         * Intel8080.parsing.label_delim
    --         * Intel8080.parsing.blank^0
    --     )^-1
    --     *
    --     (
    --         Intel8080.parsing.blank^0
    --         * lpeg.V "cmd"
    --         * Intel8080.parsing.blank^0
    --     )^-1
    --     *
    --     (
    --         Intel8080.parsing.blank^0
    --         * Intel8080.parsing.comment_delim
    --         * Intel8080.parsing.blank^0
    --         * lpeg.V "comment"
    --     )^-1
    -- ),
    line = lpeg.Ct(
        lpeg.V "label"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.label_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "cmd"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.comment_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "comment"
    )
    + lpeg.Ct(
        lpeg.V "cmd"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.comment_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "comment"
    )
    + lpeg.Ct(
        lpeg.V "label"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.label_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "cmd"
        * Intel8080.parsing.blank^0
    )
    + lpeg.Ct(
        lpeg.V "label"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.label_delim
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.comment_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "comment"
    )
    + lpeg.Ct(
        lpeg.V "label"
        * Intel8080.parsing.blank^0
        * Intel8080.parsing.label_delim
        * Intel8080.parsing.blank^0
    )
    + lpeg.Ct(
        lpeg.V "cmd"
        * Intel8080.parsing.blank^0
    )
    + lpeg.Ct(
        Intel8080.parsing.comment_delim
        * Intel8080.parsing.blank^0
        * lpeg.V "comment"
    ),

    label = lpeg.Cg(
        Intel8080.parsing.label, "label"
    ),
    cmd = lpeg.Cg(
        Intel8080.parsing.cmd, "cmd"
    ),
    comment = lpeg.Cg(
        (lpeg.P(1) - Intel8080.parsing.newline)^0, "comment"
    ),
}

Intel8080.parsing.listing = lpeg.Ct(
    (Intel8080.parsing.blank + Intel8080.parsing.newline)^0
    * Intel8080.parsing.line
    * (Intel8080.parsing.blank + Intel8080.parsing.newline)^0
    * (
        (Intel8080.parsing.blank + Intel8080.parsing.newline)^0
        * Intel8080.parsing.line
        * (Intel8080.parsing.blank + Intel8080.parsing.newline)^0
    )^0
)
* lpeg.P (-1)

return Intel8080
