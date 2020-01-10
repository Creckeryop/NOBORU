
function table.serialize(t, name)
    local format = string.format
    local concat = table.concat
    local type = type
    local function serialize(_t, _name)
        local _ = {}
        for k, v in pairs(_t) do
            if type(v) == "string" then
                if type(k) == "string" then
                    _[#_ + 1] = format('%s = \"%s\"', k, v)
                else
                    _[#_ + 1] = format('[%x] = \"%s\"', k, v)
                end
            elseif type(v) == "table" then
                if type(k) == "string" then
                    _[#_ + 1] = format('%s%s', k, serialize(v,''))
                else
                    _[#_ + 1] = format('[%x]%s', k, serialize(v,''))
                end
            else
                if type(k) == "string" then
                    _[#_ + 1] = format('%s = %s', k, v)
                else
                    _[#_ + 1] = format('[%x] = %s', k, v)
                end
            end
        end
        return format('%s = {%s}',_name,concat(_,', '))
    end
    return serialize(t,name)
end

function table.reverse(t)
    local i, j = 1, #t
    while i < j do
		t[i], t[j] = t[j], t[i]
		i = i + 1
		j = j - 1
	end
end

function table.clone(t)
	local pairs = pairs
	local type = type
	local function clone(_t)
		local new_t = {}
		for k, v in pairs(_t) do
			if type(v) == "table" then
				new_t[k] = clone(v)
			else
				new_t[k] = v
			end
		end
		return new_t
	end
	return clone(t)
end