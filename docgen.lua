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

-- > File
--[[@
	@file FileName
	@desc Long description
	@desc ...
	@shortdesc Short description
]]

-- /!\ will always be replaced to a warning image
-- @see Name will make a link.

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
	str = string.lower(str)
	str = string.gsub(str, "[ %(%),]", '-')
	str = string.gsub(str, "%.", '')
	return str
end

local _DATA = { } -- [file] = { _METHODS = { [n] = data }, _ENUMS = { [n] = data }, _TREE = { [n] = true } }
local _TREE = { }

local createFile = function(file)
	if not _DATA[file] then
		_DATA[file] = { }
	end
	if not _DATA[file]._TREE then
		_DATA[file]._TREE = { }
	end
end

local generate = function(content, fileName)
	-- Method / Function. Matches [x.]y = function(z)
	string.gsub(content, '%-%-%[%[@\n(.-)%]%]\n\t*(.-)\n', function(data, object)
		local objSrc, objName, objParam = string.match(object, "([^%.%s]-)%.?([^%.%s]+) *=.-%((.-)%)")
		if objName and objSrc ~= '' and objSrc ~= "self" then
			objName = objSrc .. "." .. objName
		end
		if not objName or _TREE[objName] then return end
		objParam = (objParam == ' ' and '' or objParam)
		object = ">### " .. objName .. " ( " .. objParam .. " )"
		_TREE[objName] = true

		local str = { }

		local description = getList(data, "desc")
		description = ">" .. table.concat(description, "<br>\n>")

		local file = getList(data, "file", nil, 1)
		file = file and file[1] or fileName

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

		createFile(file)
		if not _DATA[file]._METHODS then
			_DATA[file]._METHODS = { }
		end
		_DATA[file]._METHODS[#_DATA[file]._METHODS + 1] = table.concat(str, "\n")
		_DATA[file]._TREE[objName] = url(objName .. " (" .. string.gsub(objParam, ' ', '') .. ")")
	end)
	-- Enums / Tables. Matches x = [e(]{ y }[)]
	string.gsub(content, '%-%-%[%[@\n(.-)%]%]\n\t*([^\n]+)(%b{})', function(data, object, info)
		local objName = string.match(object, "%.(%S+)")
		if not objName or _TREE[objName] then return end

		local etype = getList(data, "type", nil, 1)
		etype = etype and etype[1] or ''
		object = "### " .. objName .. " <sub>\\<" .. etype .. "></sub>"

		_TREE[objName] = true

		local str = { }

		local description = getList(data, "desc")
		description = "###### " .. table.concat(description, "<br>") -- No safe way to make it \n instead of \n\n

		local file = fileName

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

		createFile(file)
		if not _DATA[file]._ENUMS then
			_DATA[file]._ENUMS = { }
		end
		_DATA[file]._ENUMS[#_DATA[file]._ENUMS + 1] = table.concat(str, "\n")
		_DATA[file]._TREE[objName] = url(objName .. "-" .. etype)
	end)
	-- File description
	string.gsub(content, "%-%-%[%[@\n(.-)%]%]\n+", function(data)
		local file = getList(data, "file", nil, 1)
		if not file then return end
		file = file[1]

		local description = getList(data, "desc")
		if not description then return end
		description = table.concat(description, "<br>\n")

		local shortDesc = getList(data, "shortdesc", nil, 1)
		shortDesc = shortDesc and shortDesc[1] or nil
		if shortDesc == '↑' then
			shortDesc = description
		end

		createFile(file)
		_DATA[file]._DESC = {
			long = description,
			short = shortDesc
		}
	end)
end

local write = function(file, data, tree) -- tree = @see
	local str = { }
	
	if data._DESC and data._DESC.long then
		str[1] = data._DESC.long
	end

	local len = #str
	if data._METHODS then
		str[len + 1] = "# Methods"
		str[len + 2] = table.concat(data._METHODS, "\n---\n")
	end

	len = #str
	if data._ENUMS then
		str[len + 1] = "# Enums"
		str[len + 2] = table.concat(data._ENUMS, "\n---\n")
	end

	local file = io.open(file, "w+")
	str = table.concat(str, "\n")

	str = string.gsub(str, "/!\\", "![/!\\\\](http://images.atelier801.com/168395f0cbc.png)")
	
	str = string.gsub(str, "@see (%w+)", function(name)
		local link = string.match(tree, "%[" .. name .. "%]%((.-)%)") or nil
		return link and ("[" .. name .. "](" .. link .. ")") or name
	end)

	file:write(str)
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
	"libs/enumerations.lua",
	"libs/extensions.lua",
	"docfiles.lua"
}
for file = 1, #list do
	local f = io.open(list[file], 'r')
	local fileName = string.match(list[file], "([^/]+)%.lua$")
	if fileName then
		fileName = string.gsub(fileName, "%a", string.upper, 1) -- 1st char should be cap as std
	else
		fileName = "Unknown"
	end
	generate(f:read("*a"), fileName)
	f:close()
end

local dataFile = { }
_TREE, counter = { }, 0
for k, v in next, _DATA do
	dataFile[k] = v
	v._TREE = toArr(v._TREE)
	table.sort(v._TREE, function(a, b) return a.k < b.k end)
	counter = counter + 1
	_TREE[counter] = { k = k, v = v._TREE, d = v._DESC }
end
table.sort(_TREE, function(a, b) return a.k < b.k end)

counter = 0
local fileDescData, data = { }
for f = 1, #_TREE do
	data = { }
	data[1] = "- [" .. _TREE[f].k .. "](" .. _TREE[f].k .. ".md)"

	counter = counter + 1
	fileDescData[counter] = data[1] .. ((_TREE[f].d and _TREE[f].d.short) and (" → " .. _TREE[f].d.short) or "")

	for l = 1, #_TREE[f].v do
		data[l + 1] = "\t- [" .. _TREE[f].v[l].k .. "](" .. _TREE[f].k .. ".md#" .. _TREE[f].v[l].v .. ")"
	end
	_TREE[f] = table.concat(data, "\n")
end

local tree = table.concat(_TREE, "\n")

local file = io.open("docs/README.md", 'r')
local readme = file:read("*a")
file:close()
readme = string.match(readme, "^(.-## Topics\n\n)")

file = io.open("docs/README.md", "w+")
file:write(readme .. table.concat(fileDescData, "\n") .. "\n\n## Tree\n\n" .. tree)
file:flush()
file:close()

for k, v in next, dataFile do
	write("docs/" .. k .. ".md", v, tree)
end