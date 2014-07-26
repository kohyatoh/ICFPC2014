-- lisp to GCC compiler
local re = require "re"

local OPS = { add = "ADD", sub = "SUB", mul = "MUL", div = "DIV",
    cons = "CONS", car = "CAR", cdr = "CDR" }

local pat = "({%w+} / {[()]} / .)*"
local tokens = table.pack(re.match(io.read("*all"), pat))

function table.extend(list, other)
    for i, v in ipairs(other) do
        table.insert(list, v)
    end
end

local current = {}
for i, token in ipairs(tokens) do
    if token == "(" then
        local new = { parent = current }
        table.insert(current, new)
        current = new
    elseif token == ")" then
        current = current.parent
    else
        table.insert(current, token)
    end
    print(token)
end
local root = current[1]

local function print_tree (n)
    ident = ident or 0
    if type(n) == "table" then
        io.write "("
        for i, v in ipairs(n) do
            print_tree(v, ident+2)
            io.write " "
        end
        io.write ")"
    else
        io.write(tostring(n))
    end
end

local labelid = 0
local function new_label ()
    labelid = labelid + 1
    return "L" .. tostring(labelid)
end

local function lookup (context, name)
    local k, n = 0, #context
    while k < n do
        for i, v in ipairs(context[n-k]) do
            if v == name then
                return k, i - 1
            end
        end
    end
    return nil
end

local function tree_to_ops (n, context)
    local ops, fns = {}, {}
    if type(n) == "table" then
        local head = table.remove(n, 1)
        if OPS[head] ~= nil then
            for i, v in ipairs(n) do
                local _ops, _fns = tree_to_ops(v, context)
                table.extend(ops, _ops)
                table.extend(fns, _fns)
            end
            table.insert(ops, "  " .. OPS[head])
        elseif head == "if" then
            local b = table.remove(n, 1)
            local opsb, fnsb = tree_to_ops(b, context)
            table.extend(ops, opsb)
            table.extend(fns, fnsb)
            local labels = {new_label(), new_label()}
            for i, v in ipairs(n) do
                local _ops, _fns = tree_to_ops(v, context)
                table.insert(_ops, 1, labels[i] .. ":")
                table.insert(_ops, "  JOIN")
                table.extend(fns, _ops)
                table.extend(fns, _fns)
            end
            table.insert(ops, "  SEL " .. labels[1] .. " " .. labels[2])
        elseif head == "let" then
            local vars = table.remove(n, 1)
            local names = {}
            for i, vars in ipairs(vars) do
                local _ops, _fns = tree_to_ops(vars[2], context)
                table.extend(ops, _ops)
                table.extend(fns, _fns)
                table.insert(names, vars[1])
            end
            table.insert(context, names)
            local label = new_label()
            local body = { label .. ":" }
            for i, v in ipairs(n) do
                local _ops, _fns = tree_to_ops(v, context)
                table.extend(body, _ops)
                table.extend(fns, _fns)
            end
            table.insert(body, "  RTN")
            table.extend(fns, body)
            table.insert(ops, "  LDF " .. label)
            table.insert(ops, "  AP " .. tostring(#names))
            table.remove(context)
        end
    else
        if string.match(n, "^%d+$") ~= nil then
            table.insert(ops, "  LDC " .. n)
        else
            local a, b = lookup(context, n)
            if a == nil then
                error("variable not found: " .. n)
            end
            table.insert(ops, string.format("  LD %d %d", a, b))
        end
    end
    return ops, fns
end

print_tree(root)
io.write"\n"
ops, fns = tree_to_ops(root, {})
for i, v in ipairs(ops) do
    print(v)
end
print"  RTN"
for i, v in ipairs(fns) do
    print(v)
end
