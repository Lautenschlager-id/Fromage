-- Lists all the topics of the Modules BR section as BBCODE (@ file 'result.txt'). (Topic | Title | Author)
local api = require("fromage")
local client = api()
local enum = client.enumerations()

local normalizeHTML
do
	local entities = {
		["&amp;"] = '&',
		["&lt;"] = '<',
		["&gt;"] = '>',
		["&laquo;"] = '«',
		["&raquo;"] = '»',
		["&quot;"] = '"'
	}
	normalizeHTML = function(title)
		title = string.gsub(title, "&#(%d+);", function(dec)
			return string.char(dec)
		end)
		title = string.gsub(title, "&.-;", function(e)
			return entities[e] or e
		end)

		return title
	end
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local location = client.getLocation(enum.forum.transformice, enum.community.br, enum.section.modules)
		local list = client.getSectionTopics(location, false, 0)
		table.sort(list, function(a, b) return a.title < b.title end)

		local row = "[row][cel][size=12][url=http://atelier801.com/topic?f=%d&t=%d]T-%d[/url][/size][/cel][cel][size=12]%s[/size][/cel][cel][size=12]%s[/size][/cel][/row]"

		local data = { }
		for i = 1, #list do
			data[i] = string.format(row, list[i].f, list[i].t, list[i].t, normalizeHTML(list[i].title), list[i].author)
		end

		local tbl = "[table align=center border=#0E242D]\n[row][cel][img]https://i.imgur.com/j8P1qR0.png[/img][size=13][b][color=#2E72CB]Topic[/color][/b][/size][/cel][cel][img]http://img.atelier801.com/c4a4f128.png[/img][size=13][b][color=#2E72CB]Title[/color][/b][/size][/cel][cel][img]http://atelier801.com/img/icones/16/1profil.png[/img][size=13][b][color=#2E72CB]Author[/color][/b][/size][/cel][/row]\n%s\n[/table]\n\n[color=#2E72CB]Total topics:[/color] %d"		local file = io.open("result.txt", "w+")
		file:write(string.format(tbl, table.concat(data, "\n"), #list))
		file:flush()
		file:close()
	end

	client.disconnect()
	os.execute("pause")
end)()