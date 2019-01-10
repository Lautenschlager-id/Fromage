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

return {
	bbcodeToMarkdown = bbcodeToMarkdown,
	htmlEntitiesToAnsii = htmlEntitiesToAnsii
}