-- GCC language assembler

local STRIP_COMMENTS = true

local lineno = 0
local labels = {}
local lines = {}

for line in io.lines() do
    -- extract comments
    local comment = ""
    if line:find(';') ~= nil then
        local index = line:find(';')
        comment = line:sub(index)
        line = line:sub(1, index-1)
    end
    -- check line type
    if string.match(line, "^%s*$") ~= nil then
        -- empty line
    elseif string.match(line, "^%w+:$") ~= nil then
        -- label
        local label = string.match(line, "^(%w+):$")
        labels[label] = lineno
        line = ""
        comment = "; " .. label .. ": " .. comment
    else
        -- operator
        lineno = lineno + 1
    end
    table.insert(lines, { line, comment })
end

for k, v in ipairs(lines) do
    local line, comment = unpack(v)
    if string.match(line, "^%s*$") == nil then
        -- replace symbols
        local reg = {}
        for w in string.gmatch(line, "%g+") do
            if labels[w] ~= nil then
                -- replace labels
                w = tostring(labels[w])
            end
            if #reg >= 2 then
                table.insert(reg, ",")
            end
            table.insert(reg, w)
        end
        line = table.concat(reg, " ")
    end
    if STRIP_COMMENTS then
        print(line)
    else
        print(line, comment)
    end
end
