-- A simple command bot that displays someones profile with a command through a message in the topic @(var 'location'). (!profile name)
-- Requires a file 'lastSeen' with initial value "1"
local json = require("json")
local timer = require("timer")
local http = require("coro-http")

local api = require("fromage")
local client = api()
local enum = client.enumerations()

local readFile = function(fileName, readType)
	local file = io.open(fileName, 'r')
	local out = file:read(readType or "*a")
	file:close()
	return out
end
local writeFile = function(fileName, content)
	local file = io.open(fileName, "w+")
	file:write(tostring(content))
	file:flush()
	file:close()
end

local lastSeen = tonumber(readFile("lastSeen", "*l"))

local location = { f = 5, t = 917113 } -- the topic where !profile is allowed

local normalizeCommand = function(cmd)
	return (string.gsub(string.lower(cmd), "  +", " "))
end

local getUnreadMessages = function()
	local path = "topic?f=" .. location.f .. "&t=" .. location.t
	local body = client.getPage(path)

	local totalPages = tonumber(string.match(body, '"input%-pagination".-max="(%d+)"')) or 1

	if totalPages > 1 then
		body = client.getPage(path .. "&p=" .. totalPages)
	end

	local counter = 0
	string.gsub(body, '<div id="m%d', function()
		counter = counter + 1
	end)

	local totalMessages = ((totalPages - 1) * 20) + counter

	return lastSeen + 1, totalMessages
end

local encodeUrl = function(url)
	local out = {}

	string.gsub(url, '.', function(letter)
		out[#out + 1] = string.upper(string.format("%02x", string.byte(letter)))
	end)

	return '%' .. table.concat(out, '%')
end
local formatName = function(nickname, size, color)
	size = size or 16
	color = color or "009D9D"

	local n, d = string.match(nickname, "(.-)(#%d+)")
	if not d then
		n = nickname
		d = "#0000"
	end

	return "[size=" .. size .. "][color=#" .. color .. "]" .. n .. "[/color][/size][size=" .. math.max(10, size - 5) .. "][color=#606090]" .. d .. "[/color][/size]"
end
math.percent = function(x, y, v)
	v = v or 100
	local m = x/y * v
	return math.min(m, v)
end
local getRate = function(value, of, max)
	of = of or 10
	max = max or 10

	local rate = math.min(max, (value * (max / of)))
	return string.format("[size=12][%s%s] %.2f%%[/size]", string.rep('|', rate), string.rep('-', max - rate), (value / of * 100))
end
local expToLvl = function(xp)
	local last, total, level, remain, need = 30, 0, 0, 0, 0
	for i = 1, 200 do
		local nlast = last + (i - 1) * ((i >= 1 and i <= 30) and 2 or (i <= 60 and 10 or (i <= 200 and 15 or 15)))
		local ntotal = total + nlast

		if ntotal >= xp then
			level, remain, need = i - 1, xp - total, ntotal - xp
			break
		else
			last, total = nlast, ntotal
		end
	end

	return level, remain, need
end
local getProfileText = function(nickname, author)
	nickname = string.gsub(nickname, "#0000", '')
	local _, body = http.request("GET", "https://club-mice.com/yuir_lacasitos/api.php?user=" .. encodeUrl(nickname))
	body = json.decode(body)

	if body then
		if not body.id then 
			return "[b][color=#CB546B]" .. author .. ", the profile you asked was not found.[/color][/b]"
		end

		if not body.title then
			body.title = "«Little Mouse»"
		else
			body.title = string.gsub(body.title, "&amp;", '&')
			body.title = string.gsub(body.title, "\\u00ab", '«')
			body.title = string.gsub(body.title, "\\u00bb", '»')
		end

		local _, remain, need = expToLvl(tonumber(body.experience))
		return string.format("[size=20]%s[/size]\n%s[b]Level %s[/b] %s%s\n%s\n\n[b]Saved mice :[/b] [color=#98E2EB]%s[/color] / [color=#BABD2F]%s[/color] / [color=#CB546B]%s[/color]\n[b]Shaman cheese:[/b] %s\n\n[b]First :[/b] %s %s\n[b]Cheese :[/b] %s %s\n[b]Bootcamp :[/b] %s%s",
			formatName(nickname, 20, (body.gender == "Male" and "98E2EB" or body.gender == "Female" and "FEB1FC" or "C2C2DA")),
			(body.registration_date == "" and "" or ("[b]Creation :[/b] " .. body.registration_date .. "\n\n")),
			body.level, getRate(math.percent(remain, (remain + need)), 100, 10),
			(body.tribe and ("\n[b]Tribe :[/b] " .. body.tribe) or ""),
			body.title,
			body.saved_mice, body.saved_mice_hard, body.saved_mice_divine,
			body.shaman_cheese,
			body.first, getRate(math.percent(body.first, body.round_played, 100), 100, 5),
			body.cheese_gathered, getRate(math.percent(body.cheese_gathered, body.round_played, 100), 100, 10),
			body.bootcamp,
			(body.spouse and("\n\n[color=#EB1D51]❤[/color] " .. formatName(body.spouse) .. (body.marriage_date and (" since [b]" .. body.marriage_date .. "[/b]") or "")) or "")
		)
	else 
		return "[b][color=#CB546B]" .. author .. ", internal error. Can you try again later?[/color][/b]"
	end
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")

	local again = 0
	timer.setInterval(8000, function()
		if again < 0 or again > os.time() then return end

		coroutine.wrap(function()
			local message, command, value
			local i, j = getUnreadMessages()
			if i > j then return end
			again = -1

			local msg = { }
			for m = i, j do
				message = client.getMessage(tostring(m), location)
				if message and message.content and message.author ~= client.getUser() then
					local nickname = string.match(message.content, "^!profile(.-)$")
					if nickname then
						nickname = string.match(nickname, "%S+") or message.author
						if nickname then
							nickname = client.formatNickname(nickname)
							msg[#msg + 1] = getProfileText(nickname, message.author)
						end
					end
				end
			end
			lastSeen = j
			writeFile("lastSeen", lastSeen)

			client.answerTopic(table.concat(msg, "[hr]"), location)
			again = os.time() + 11
		end)()
	end)
end)()