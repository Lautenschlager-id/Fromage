-- A simple command bot that saves a command logged in a topic (var 'location') and returns the command value when the user sends the command in the available sections (var 'section')
-- Requires a file 'lastSeen' with initial value "1"
-- Requires a file 'commands' with initial value "{}"
-- Requires a file 'userLastSeen' with initial value "{}"
local json = require("json")
local timer = require("timer")

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
local commands = json.decode(readFile("commands"))
local userLastSeen = json.decode(readFile("userLastSeen"))

local location = { f = 5, t = 917052 }
local section = { [167] = true }

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

local createAuthorInterval = function(author)
	timer.setInterval(10000, function()
		coroutine.wrap(function()
			local lastPosts, err = client.getLastPosts(1, author, true)
			if lastPosts then
				local first = lastPosts[1]
				if not first then
					return print(author .. ": Invalid lastPosts")
				end

				if userLastSeen[author].f == first.location.data.f and userLastSeen[author].t == first.location.data.t and userLastSeen[author].post == first.post then
					return
				end

				for i = 1, #lastPosts do
					if userLastSeen[author].f == lastPosts[i].location.data.f and userLastSeen[author].t == lastPosts[i].location.data.t and userLastSeen[author].post == lastPosts[i].post then
						break
					end
 
					if lastPosts[i].navbar and section[lastPosts[i].navbar[#lastPosts[i].navbar - 1].location.data.s] then
						lastPosts[i].contentHtml = normalizeCommand(string.gsub(lastPosts[i].contentHtml, "<.->", ''))
						if commands[author][lastPosts[i].contentHtml] then
							client.answerTopic(commands[author][lastPosts[i].contentHtml], lastPosts[i].location.data)
						end
					end
				end

				userLastSeen[author] = { f = first.location.data.f, t = first.location.data.t, post = first.post }
				writeFile("userLastSeen", json.encode(userLastSeen))
			else
				print(author .. ": " .. err)
			end
		end)()
	end)
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")

	timer.setInterval(10000, function()
		coroutine.wrap(function()
			print("Reading...")
			local message, command, value
			local i, j = getUnreadMessages()
			if i > j then return end

			for m = i, j do
				message = client.getMessage(tostring(m), location)
				if message and message.content then
					command, value = string.match(message.content, "^([^%[%]\n]+)\n*%[spoiler%]\n*(.+)\n*%[/spoiler%]\n*$")
					if command then
						if not commands[message.author] then
							commands[message.author] = { }
							userLastSeen[message.author] = { f = location.f, t = location.t, post = tostring(m) }
							writeFile("userLastSeen", json.encode(userLastSeen))
							createAuthorInterval(message.author)
						end
						commands[message.author][normalizeCommand(command)] = value
						writeFile("commands", json.encode(commands))
					end
				end
			end
			lastSeen = j
			writeFile("lastSeen", lastSeen)
		end)()
	end)

	for author in next, commands do
		createAuthorInterval(author)
	end
end)()