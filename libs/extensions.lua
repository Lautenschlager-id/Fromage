--[[ Official lib functions ]]--
-- > OS
--[[@
	@desc Gets the content of a file.
	@param file<string> The file name or path.
	@returns string,nil The file content.
]]
os.readFile = function(file)
	local file = io.open(file, 'r')
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end
-- > Table
--[[@
	@desc Concats two tables (by reference).
	@param src<table> The source table to get new values.
	@param list<table> The table that will pass the values to the source table.
]]
table.add = function(src, list)
	local len = #src
	for i = 1, #list do
		src[len + i] = list[i]
	end
end
--[[@
	@desc Creates a set of values based on a given table.
	@param tbl<table> The base table.
	@param index?<string,int> The index to have its value set as index if `tbl` is a dictionary.
	@returns table The set of values.
	@struct {
		-- Without 'index'
		[ tbl[n] ] = true,
		-- With 'index
		[ tbl[n][index] ] = tbl[n]
	}
]]
table.createSet = function(tbl, index)
	local out = { }

	local j = true
	for k, v in next, tbl do
		local i
		if index then
			i = v[index]
			j = v
		else
			i = v
		end

		out[i] = j
	end
	return out
end
--[[@
	@desc Searches for a value in a given table.
	@param tbl<table> The table that may contain the required value.
	@param value<*> The value to be searched in the table.
	@param index?<int,string> The index to be used to search the value, case it's a nested table.
	@returns int,string,nil The first table index where the value was found.
]]
table.search = function(tbl, value, index)
	local found = false
	for k, v in next, tbl do
		if index and type(v) == "table" then
			found = (v[index] == value)
		else
			found = (v == value)
		end
		if found then
			return k
		end
	end
end

--[[ Special functions ]]--
local bbcodeToMarkdown
--[[@
	@desc Converts a BBCode into Markdown. (e.g.: [b] -> **)
	@desc /!\ This function is currently in tests and bugs may occur.
	@param bbcode<string> The bbcode to be converted.
	@returns string The markdown obtained from the bbcode.
]]
bbcodeToMarkdown = function(bbcode)
	bbcode = string.gsub(bbcode, "[%*_~]", "\\%1")

	bbcode = string.gsub(bbcode, "(%[(%S+).-=?(.-)%]\n*(.-)\n*%[/%2%])", function(raw, f, value, content)
		if f == 'b' then
			return "**" .. content .. "**"
		elseif f == 'i' then
			return "*" .. bbcodeToMarkdown(content) .. "*"
		elseif f == 'u' then
			return "__" .. bbcodeToMarkdown(content) .. "__"
		elseif f == 's' then
			return "~~" .. bbcodeToMarkdown(content) .. "~~"
		elseif f == "cel" then
			return bbcodeToMarkdown(content) .. " | "
		elseif f == "row" then
			return "\n" .. bbcodeToMarkdown(content)
		elseif f == "video" then
			if string.find(bbcodeToMarkdown(content), "youtube") then
				return "https://www.youtube.com/watch?v=" .. string.match(string.gsub(content, "\\", ''), "[^/]+$")
			else
				return bbcodeToMarkdown(content)
			end
		elseif f == "url" then
			return "[" .. bbcodeToMarkdown(content) .. "](" .. (value ~= '' and value or content) .. ")"
		elseif f == '*' then
			return "- " .. bbcodeToMarkdown(content)
		elseif f == "quote" then
			return "`" .. value .. ":` ```\n" .. bbcodeToMarkdown(content) .. "```"
		elseif f == "spoiler" then
			return "{{" .. bbcodeToMarkdown(content) .. "}}"
		elseif f == "code" then
			return "```" .. value .. "\n" .. bbcodeToMarkdown(content) .. "```"
		elseif f == "color" or f == "size" or f == "font" or f == 'p' or f == "table" or f == "img" or f == "list" then
			return bbcodeToMarkdown(content)
		end
		return raw
	end)

	bbcode = string.gsub(bbcode, "(%[(.-)%])", function(raw, f)
		if f == "hr" then
			return "\n\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\n"
		end
		return raw
	end)

	bbcode = string.gsub(bbcode, "%*%*%*(.-)%*%*%*", "_%*%*(.-)%*%*_")

	return bbcode
end

local htmlEntitiesToAnsii
do
	local entities = {
		["&amp;"] = '&',
		["&lt;"] = '<',
		["&gt;"] = '>',
		["&laquo;"] = '«',
		["&raquo;"] = '»',
		["&quot;"] = '"'
	}
	--[[@
		@desc Normalizes most of the html entities found in the `htmlContent` fields converting them to ANSII.
		@param str<string> The HTML string to be normalized.
		@returns string The normalized string without HTML entities.
	]]
	htmlEntitiesToAnsii = function(str)
		str = string.gsub(str, "&#(%d+);", function(dec)
			return string.char(dec)
		end)
		str = string.gsub(str, "&.-;", function(e)
			return entities[e] or e
		end)

		return str
	end
end

--[[ New ones, to test ]]--
do
	local color = "\27[%sm%s\27[0m"
	local theme = { -- Scrapped from utils.theme
		error = "1;31",
		failure = "1;33;41",
		highlight = "1;36;44",
		info = "1;36",
		success = "0;32"
	}

	--[[@
		@name os.log
		@desc Sends a log message with colors to the prompt of command.
		@desc Color format is given as `↑name↓text↑`, as in `↑error↓[FAIL]↑`.
		@desc Available code names: `error`, `failure`, `highlight`, `info`, `success`.
		@desc This function is also available for the `error` function. Ex: `error("↑error↓Bug↑")`
		@param str<string> The message to be sent. It may included color formats.
		@param returnValue?<boolean> Whether the formated message has to be returned. If not, it'll be sent to the prompt automatically. @default false
		@returns nil,string The formated message, depending on @returnValue.
	]]
	os.log = function(str, returnValue)
		str = string_gsub(tostring(str), "(↑(.-)↓(.-)↑)", function(format, code, text)
			return (theme[code] and string_format(color, theme[code], text) or format)
		end)

		if returnValue then
			return str
		else
			print(str)
		end
	end
end

table.setNewClass = function()
	local class = setmetatable({ }, {
		__call = function(this, ...)
			return this:new(...)
		end,
		__newindex = function(this, index, value)
			if type(value) == "string" then -- Aliases / Compatibility
				rawset(this, index, function(self, ...)
					os.log("↑failure↓[/!\\]↑ ↑highlight↓" .. index .. "↑ is deprecated, use ↑highlight↓" .. value .. "↑ instead.")
					return this[value](self, ...)
				end)
			else
				rawset(this, index, value)
			end
		end
	})
	class.__index = class

	return class
end

local encodeUrl = function(url)
	if url == "" then return "" end

	local out = {}

	string.gsub(url, '.', function(letter)
		out[#out + 1] = string.upper(string.format("%02x", string.byte(letter)))
	end)

	return "%" .. table.concat(out, '%')
end

local assertion = function(name, etype, id, value)
	local t = type(value)

	if type(etype) == "table" then
		local names, counter = { }, 0
		for k, v in next, etype do
			if v == t then
				return
			else
				counter = counter + 1
				names[counter] = v
			end
		end
		error("bad argument #" .. id .. " to '" .. name .. "' (" .. table.concat(names, " | ") .. " expected, got " .. t .. ")")
	else
		assert(t == etype, "bad argument #" .. id .. " to '" .. name .. "' (" .. etype .. " expected, got " .. t .. ")")
	end
end

return {
	bbcodeToMarkdown = bbcodeToMarkdown,
	htmlEntitiesToAnsii = htmlEntitiesToAnsii,
	encodeUrl = encodeUrl,
	assertion = assertion
}