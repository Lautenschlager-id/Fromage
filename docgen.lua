-- > Method
--[[@
	@file FileName
	@desc Description
	@desc ...
	@param ParameterName<Type1,Type2> Description
	@param OptionalParameter?<Type> Description @default Value
	@paramstruct ParameterName {
		FieldName<Type1,Type2> Description
		OptionalField?<Type1> Description @default Value
	}
	@returns Type1,Type2 Description
	@struct {
		field = "value", -- Description
	}
]]

-- > Enumeration
--[[@
	@desc Description
	@desc ...
	@type Type
	@tree Text (Replaces the original tree)
	@tree ...
]]

string.split = function(str, pat, f)
	local out = {}

	string.gsub(str, pat, function(v)
		out[#out + 1] = (not f and v or f(v))
	end)

	return out
end

table.map = function(list, f)
	local out = {}
	
	for k, v in next, list do
		out[k] = f(v)
	end
	
	return out
end

local getList = function(data, param, pattern, t)
	local out, counter = { }, 0

	string.gsub(data, "@" .. param .. " " .. (pattern or "(.-)\r?\n"), function(content)
		counter = counter + 1
		out[counter] = content
	end, t)

	return (counter > 0 and out or nil)
end

local getTableLine = function(line)
	local paramName, isOptional, paramType, paramDesc = string.match(line, '^(.-)(%??)<(.-)> (.-)$')
	local pDesc, pDefault = string.match(paramDesc, '^(.-) @default (.-)$')
	if pDesc then
		paramDesc = pDesc
		pDefault = " <sub>(default = " .. pDefault .. ")</sub>"
	else
		pDefault = ''
	end

	paramType = string.split(paramType, "[^,]+")

	return ">| " .. paramName .. " | `" .. table.concat(paramType, "`, `") .. "` | " .. (isOptional == '?' and '✕' or '✔') .. " | " .. paramDesc .. pDefault .. " |"
end

local url = function(str)
	return (string.gsub(string.lower(str), "[ %(%),]", '-'))
end

local _DATA = { } -- [file] = { _METHODS = { [n] = data }, _ENUMS = { [n] = data }, _TREE = { [n] = true } }
local _TREE = { }

local generate = function(content)
	string.gsub(content, '%-%-%[%[@\n(.-)%]%]\n\t*(.-)\n', function(data, object)
		local objName, objParam = string.match(object, "%.(%S+).-%((.-)%)")
		if not objName or _TREE[objName] then return end
		objParam = (objParam == ' ' and '' or objParam)
		object = ">### " .. objName .. " ( " .. objParam .. " )"
		_TREE[objName] = true

		local str = { }

		local description = getList(data, "desc")
		description = ">" .. table.concat(description, "<br>\n>")

		local file = getList(data, "file", nil, 1)
		file = file and file[1] or "API"

		local param = getList(data, "param")
		if param then
			param = table.map(param, getTableLine)
		end

		local paramStruct = getList(data, "paramstruct", '%w+ %b{}')
		if paramStruct then
			paramStruct = table.map(paramStruct, function(line)
				local paramName, paramSyntax, tabs = string.match(line, '(%w+) {(.-)(\t+)}')

				paramSyntax = string.split(paramSyntax, "[^\n]+")
				paramSyntax = table.map(paramSyntax, function(line)
					line = string.gsub(line, "^" .. tabs, '')
					return getTableLine(line)
				end)

				return ">**@`" .. paramName .. "` parameter's structure**:\n>\n>| Index | Type | Required | Description |\n>| :-: | :-: | :-: | - |\n" .. table.concat(paramSyntax, "\n")
			end)
		end

		local returnValue = getList(data, "returns")
		if returnValue then
			returnValue = table.map(returnValue, function(line)
				local rType, rDesc = string.match(line, '^(.-) (.-)$')

				rType = string.split(rType, "[^,]+")

				return ">| `" .. table.concat(rType, "`, `") .. "` | " .. rDesc .. " |"
			end)
		end

		local struct = getList(data, "struct", '(%b{})', 1)
		if struct and struct[1] then
			struct = struct[1]
			local tabs = string.match(struct, '(\t+)}$')

			struct = string.split(struct, "[^\n]+")
			struct = table.map(struct, function(line)
				return (string.gsub(line, "^" .. tabs, '>', 1))
			end)
			struct = ">" .. table.concat(struct, "\n")
		end

		str[1] = object
		if param then
			str[2] = ">| Parameter | Type | Required | Description |"
			str[3] = ">| :-: | :-: | :-: | - |"
			str[4] = table.concat(param, "\n")

			if paramStruct then
				str[5] = '>'
				str[6] = table.concat(paramStruct, "\n>\n")
			end
		end

		local len = #str
		str[len + 1] = '>'
		str[len + 2] = description
		str[len + 3] = str[len + 1]

		if returnValue then
			str[len + 4] = ">**Returns**:"
			str[len + 5] = str[len + 1]
			str[len + 6] = ">| Type | Description |"
			str[len + 7] = ">| :-: | - |"
			str[len + 8] = table.concat(returnValue, "\n")
			str[len + 9] = str[len + 1]
		end

		len = #str
		if struct then
			str[len + 1] = ">**Table structure**:"
			str[len + 2] = ">```Lua"
			str[len + 3] = struct
			str[len + 4] = ">```"
		end

		if not _DATA[file] then
			_DATA[file] = { }
		end
		if not _DATA[file]._METHODS then
			_DATA[file]._METHODS = { }
		end
		if not _DATA[file]._TREE then
			_DATA[file]._TREE = { }
		end
		_DATA[file]._METHODS[#_DATA[file]._METHODS + 1] = table.concat(str, "\n")
		_DATA[file]._TREE[objName] = url(objName .. " (" .. string.gsub(objParam, ' ', '') .. ")")
	end)

	string.gsub(content, '%-%-%[%[@\n(.-)%]%]\n\t*(.-)(%b{})', function(data, object, info)
		local objName = string.match(object, "%.(%S+)")
		if not objName or _TREE[objName] then return end

		local etype = getList(data, "type", nil, 1)
		etype = etype and etype[1] or ''
		object = "### " .. objName .. " <sub>\\<" .. etype .. "></sub>"

		_TREE[objName] = true

		local str = { }

		local description = getList(data, "desc")
		description = "###### " .. table.concat(description, "<br>") -- No safe way to make it \n instead of \n\n

		local file = "ENUMERATIONS"

		local tree = getList(data, "tree")
		if tree then
			tree = "**Structure**:\n```\n" .. table.concat(tree, "\n") .. "\n```"
		else
			info = string.split(info, "[^\n]+")
			local oneCel = false
			info = table.map(info, function(line)
				local index, value = string.match(line, '^\t*(%S+) += +\"?(.-)\"?,?$')
				if index then
					index = string.gsub(index, "%[(%d+)%]", "%1", 1)
					if not oneCel and index == value then
						oneCel = true
					end
					return "| " .. index .. " | " .. (oneCel and '' or (value .. " |"))
				end
				return ''
			end)
			info = (oneCel and ("| Index |\n| :-: |") or ("| Index | Value |\n| :-: | :-: |")) .. table.concat(info, "\n")
		end

		str[1] = object
		str[2] = description
		str[3] = tree or info

		if not _DATA[file] then
			_DATA[file] = { }
		end
		if not _DATA[file]._ENUMS then
			_DATA[file]._ENUMS = { }
		end
		if not _DATA[file]._TREE then
			_DATA[file]._TREE = { }
		end
		_DATA[file]._ENUMS[#_DATA[file]._ENUMS + 1] = table.concat(str, "\n")
		_DATA[file]._TREE[objName] = url(objName .. "-" .. etype)
	end)
end

local write = function(file, data)
	local str = { }
	if data._METHODS then
		str[1] = "# Methods"
		str[2] = table.concat(data._METHODS, "\n---\n")
	end

	local len = #str
	if data._ENUMS then
		str[len + 1] = "# Enums"
		str[len + 2] = table.concat(data._ENUMS, "\n---\n")
	end

	local file = io.open(file, "w+")
	file:write(table.concat(str, "\n"))
	file:flush()
	file:close()
end

local toArr = function(tbl)
	local out, counter = { }, 0
	for k, v in next, tbl do
		counter = counter + 1
		out[counter] = { k = k, v = v }
	end
	return out
end 

local list = {
	"init.lua",
	"package.lua",
	"libs/enum.lua",
	"libs/enumerations.lua"
}
for file = 1, #list do
	local f = io.open(list[file], 'r')
	generate(f:read("*a"))
	f:close()
end

_TREE, counter = { }, 0
for k, v in next, _DATA do
	write("docs/" .. k .. ".md", v)
	v._TREE = toArr(v._TREE)
	table.sort(v._TREE, function(a, b) return a.k < b.k end)
	counter = counter + 1
	_TREE[counter] = { k = k, v = v._TREE }
end
table.sort(_TREE, function(a, b) return a.k < b.k end)

local data
for f = 1, #_TREE do
	data = { }
	data[1] = "- [" .. _TREE[f].k .. "](" .. _TREE[f].k .. ".md)"
	for l = 1, #_TREE[f].v do
		data[l + 1] = "\t- [" .. _TREE[f].v[l].k .. "](" .. _TREE[f].k .. ".md#" .. _TREE[f].v[l].v .. ")"
	end
	_TREE[f] = table.concat(data, "\n")
end

local file = io.open("docs/README.md", 'r')
local readme = file:read("*a")
file:close()
readme = string.match(readme, "^(.-## Tree\n\n)")

file = io.open("docs/README.md", "w+")
file:write(readme .. table.concat(_TREE, "\n"))
file:flush()
file:close()