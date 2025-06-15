local Intel8080 = require "intel8080.assembly"

Intel8080.formatting = {}

Intel8080.formatting.format_expression = function (expr)
    local result
    if not (expr.binary_operations and expr.operands) then
        result = ""
        for _, op in ipairs(expr.unary_operations) do
            result = result .. op
            if #op ~= 1 then
                result = result .. " "
            end
        end

        if expr.numeric then
            local radix = {["2"] = "B", ["8"] = "O", ["10"] = "", ["16"] = "H"}
            result = result .. expr.numeric.value .. radix[expr.numeric.radix]
        end
        if expr.location_counter then
            result = result .. "$"
        end
        if expr.label then
            result = result .. expr.label
        end
        if expr.ascii then
            result = result .. "'" .. expr.ascii:gsub("''", "'") .. "'"
        end
        if expr.expression then
            result = result .. "(" .. Intel8080.formatting.format_expression(expr.expression) .. ")"
        end
    else
        result = Intel8080.formatting.format_expression(expr.operands[1])
        for i = 1, #expr.binary_operations do
           result = result .. " " .. expr.binary_operations[i] .. " " .. Intel8080.formatting.format_expression(expr.operands[i + 1])
        end
    end

    return result
end

Intel8080.formatting.make_text_listing = function (code, location_counter, labels)
    local state = Intel8080.assembly.assemble(code, location_counter, labels)
    local formatted_lines = {}
    local last_formatted_line = 0

    for _, line in ipairs(state) do
        if not line.cmd and not line.comment and not line.label then
            goto continue
        end

        if last_formatted_line == 0 or line.location_counter ~= formatted_lines[last_formatted_line].location_counter then
            last_formatted_line = last_formatted_line + 1
            formatted_lines[last_formatted_line] = {
                location_counter = line.location_counter,
                label = {line.label},
                bytes = line.cmd and line.cmd.bytes or {},
                asm = line.cmd and {cmd_name = line.cmd.cmd_name, args = line.cmd.args} or nil,
                comment = {line.comment}
            }
        else
            table.insert(formatted_lines[last_formatted_line].label, line.label)
            table.insert(formatted_lines[last_formatted_line].comment, line.comment)
            formatted_lines[last_formatted_line].asm = line.cmd and {cmd_name = line.cmd.cmd_name, args = line.cmd.args} or nil
            formatted_lines[last_formatted_line].bytes = line.cmd and line.cmd.bytes or nil
        end
        ::continue::
    end

    local final_result = {}

    for line_no, line in ipairs(formatted_lines) do
        local counter = line.location_counter
        local result = {"", "", "", "", ""}

        result[1] = result[1] .. string.format([==[%.4XH]==], counter)

        for i, label in ipairs(line.label) do
            result[2] = result[2] .. string.format([==[%s:]==], label)
        end

        for i, byte in ipairs(line.bytes) do
            result[3] = result[3] .. string.format([==[%.2X]==], byte)
            counter = counter + 1
        end

        local args = ""
        if line.asm.args then
            for i, arg in ipairs(line.asm.args) do
                local formatted
                if arg.register or arg.register_pair then
                    formatted = arg.register or arg.register_pair
                elseif arg.byte or arg.word or arg.faux then
                    formatted = Intel8080.formatting.format_expression(arg.byte or arg.word or arg.faux)
                end

                if i == 1 then
                    args = formatted
                else
                    args = args .. ", " .. formatted
                end
            end

            result[4] = string.format([==[%s %s]==], line.asm.cmd_name, args)
        else
            result[4] = string.format([==[%s]==], line.asm.cmd_name)
        end

        for i, comment in ipairs(line.comment) do
            if i == 1 then
                result[5] = string.format([==[%s]==], comment)
            else
                result[5] = string.format([==[ %s]==], comment)
            end
        end

        table.insert(final_result, result)
    end

    local max_label
    local max_bin
    local max_cmd

    for _, line in ipairs(final_result) do
        max_label = math.max(max_label or 0, #(line[2]))
        max_bin = math.max(max_bin or 0, #(line[3]))
        max_cmd = math.max(max_cmd or 0, #(line[4]))
    end

    local bin_space
    if max_label == 0 then
        max_label = ""
        bin_space = ""
    else
        bin_space = "    "
    end
    if max_bin == 0 then
        max_bin = ""
    end
    if max_cmd == 0 then
        max_cmd = ""
    end

    local printout
    for _, result in ipairs(final_result) do
        printout = (printout and printout .. "\n" or "")
            .. result[1]
            .. string.format("    %" .. max_label .. "s", result[2])
            .. bin_space
            .. string.format("%-" .. max_bin .. "s", result[3])
            .. string.format("    %-" .. max_cmd .. "s", result[4])
            .. "    " .. result[5]
    end

    return printout
end

Intel8080.formatting.make_listing = function (code, location_counter, labels)
    local state = Intel8080.assembly.assemble(code, location_counter, labels)
    local formatted_lines = {}
    local last_formatted_line = 0

    for _, line in ipairs(state) do
        if not line.cmd and not line.comment and not line.label then
            goto continue
        end

        if last_formatted_line == 0 or line.location_counter ~= formatted_lines[last_formatted_line].location_counter then
            last_formatted_line = last_formatted_line + 1
            formatted_lines[last_formatted_line] = {
                location_counter = line.location_counter,
                label = {line.label},
                bytes = line.cmd and line.cmd.bytes or {},
                asm = line.cmd and {cmd_name = line.cmd.cmd_name, args = line.cmd.args} or nil,
                comment = {line.comment}
            }
        else
            table.insert(formatted_lines[last_formatted_line].label, line.label)
            table.insert(formatted_lines[last_formatted_line].comment, line.comment)
            formatted_lines[last_formatted_line].asm = line.cmd and {cmd_name = line.cmd.cmd_name, args = line.cmd.args} or nil
            formatted_lines[last_formatted_line].bytes = line.cmd and line.cmd.bytes or nil
        end
        ::continue::
    end

    context.setupxtable({"booktabs"}, {
        bodyfont = "10pt",
    })
    context.startxtable({"booktabs"})

    context.startxtablehead()

    context.startxrow({align = "center, lohi"})
        context.startxcell({"booktabs:toprule"}, {nx="5"})
        context.stopxcell()
    context.stopxrow()

    context.startxrow({align = "center, lohi"})
        context.startxcell({option = "fixed", width = "\\dimexpr\\widthofstring{Адрес}"})
            context("Адрес")
        context.stopxcell()

        context.startxcell({option = "fixed"})
            context("Метка")
        context.stopxcell()

        context.startxcell({option = "fixed"})
            context("Машинный\\blank[none] код")
        context.stopxcell()

        context.startxcell({option = "stretch"})
            context("Ассемблерный\\blank[none] код")
        context.stopxcell()

        context.startxcell({option = "stretch"})
            context("Комментарии")
        context.stopxcell()
    context.stopxrow()

    context.startxrow({align = "center, lohi"})
        context.startxcell({"booktabs:midrule"}, {nx="5"})
        context.stopxcell()
    context.stopxrow()

    context.stopxtablehead()

    context.startxtablebody()
    for line_no, line in ipairs(formatted_lines) do
        context.startxrow()
            context.startxcell({align = "center"})
                local counter = line.location_counter
                local result
                for i, _ in ipairs(line.bytes) do
                    if i == 1 then
                        result = string.format([==[\tech{\unit{%.4X}H}]==], counter)
                    else
                        result = result .. string.format([==[\blank[none]\tech{\unit{%.4X}H}]==], counter)
                    end
                    counter = counter + 1
                end
                context(result)
            context.stopxcell()

            context.startxcell({align = "flushright"})
                local result
                for i, label in ipairs(line.label) do
                    if i == 1 then
                        result = string.format([==[\tech{%s:}]==], label)
                    else
                        result = result .. string.format([==[\blank[none]\tech{%s:}]==], label)
                    end
                end
                context(result)
            context.stopxcell()

            context.startxcell({align = "center", width = "\\dimexpr\\widthofstring{Машинный} + 1em"})
                local result
                for i, byte in ipairs(line.bytes) do
                    if i == 1 then
                        result = string.format([==[\tech{%.2X}]==], byte)
                    else
                        result = result .. string.format([==[\blank[none]\tech{%.2X}]==], byte)
                    end
                    counter = counter + 1
                end
                context(result)
            context.stopxcell()

            context.startxcell({align = "flushleft", width = "\\dimexpr\\widthofstring{Ассемблерный код}"})
                local args = ""
                if line.asm.args then
                    for i, arg in ipairs(line.asm.args) do
                        local formatted
                        if arg.register or arg.register_pair then
                            formatted = arg.register or arg.register_pair
                        elseif arg.byte or arg.word or arg.faux then
                            formatted = Intel8080.formatting.format_expression(arg.byte or arg.word or arg.faux)
                        end

                        if i == 1 then
                            args = formatted
                        else
                            args = args .. ", " .. formatted
                        end
                    end

                    context([==[\tech{%s %s}]==], line.asm.cmd_name, args)
                else
                    context([==[\tech{%s}]==], line.asm.cmd_name)
                end
            context.stopxcell()

            context.startxcell({align = "width, stretch, morehyphenated, fullhz, hanging"})
                for i, comment in ipairs(line.comment) do
                    if i == 1 then
                        context([==[%s]==], comment)
                    else
                        context([==[ %s]==], comment)
                    end
                end
            context.stopxcell()
        context.stopxrow()

        if line_no ~= #formatted_lines then
            context.startxrow({align = "center, lohi"})
                context.startxcell({"booktabs:addlinespace"}, {nx="5"})
                context.stopxcell()
            context.stopxrow()
        end
    end
    context.stopxtablebody()

    context.startxtablefoot()

    context.startxrow({align = "center, lohi"})
        context.startxcell({"booktabs:bottomrule"}, {nx="5"})
        context.stopxcell()
    context.stopxrow()

    context.stopxtablefoot()

    context.stopxtable()
end


return Intel8080
