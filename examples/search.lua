local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	client.connect(account.username, account.password)

	if client.isConnected() then
		print("Searching for posts:")
		local postList, err = client.search(enumerations.searchType.message_topic, "bolo", 1, {
			searchLocation = enumerations.searchLocation.posts,
			f = enumerations.forum.atelier801,
			community = enumerations.community.br,
			s = enumerations.location.br.atelier801.discussions
		}) -- Searches for messages
		if postList then
			for i = 1, #postList do
				print("[" .. enumerations.community(postList[i].community) .. "] [" .. postList[i].location.data.f .. ", " .. postList[i].location.data.t .. "] '" .. postList[i].topicTitle .. "' #" .. postList[i].post .. " by " .. postList[i].author .. ", on " .. os.date("%c", postList[i].timestamp / 1000) .. ":\n" .. string.sub(postList[i].messageHtml, 1, 100))
			end
		else
			print(err)
		end

		print("Searching for titles and posts:")
		local postList
		postList, err = client.search(enumerations.searchType.message_topic, "bolo", 1, {
			searchLocation = enumerations.searchLocation.both,
			f = enumerations.forum.atelier801,
			community = enumerations.community.br,
			s = enumerations.location.br.atelier801.discussions
		}) -- Searches for topics and messages
		if postList then
			for i = 1, #postList do
				print("[" .. enumerations.community(postList[i].community) .. "] [" .. postList[i].location.data.f .. ", " .. postList[i].location.data.t .. "] '" .. postList[i].topicTitle .. "' #" .. postList[i].post .. " by " .. postList[i].author .. ", on " .. os.date("%c", postList[i].timestamp / 1000) .. ":\n" .. string.sub(postList[i].messageHtml, 1, 100))
			end
		else
			print(err)
		end

		print("Searching for titles:")
		local postList, err = client.search(enumerations.searchType.message_topic, "discord", 0, {
			searchLocation = enumerations.searchLocation.titles,
			f = enumerations.forum.atelier801,
			community = enumerations.community.xx,
			s = enumerations.location.xx.atelier801.announcements
		}) -- Searches for topics
		if postList then
			for i = 1, #postList do
				print("[" .. enumerations.community(postList[i].community) .. "] [" .. postList[i].location.data.f .. ", " .. postList[i].location.data.t .. "] '" .. postList[i].title .. "' by " .. postList[i].author .. ", on " .. os.date("%c", postList[i].timestamp / 1000))
			end
		else
			print(err)
		end

		print("Searching for tribe:")
		local tribeList
		tribeList, err = client.search(enumerations.searchType.tribe, "make tfm", 0) -- Searches for a tribe
		if tribeList then
			for i = 1, #tribeList do
				print("[" .. tribeList[i].id .. "] " .. tribeList[i].name)
			end
		else
			print(err)
		end

		print("Searching for player:")
		local playerList
		playerList, err = client.search(enumerations.searchType.player, "bolodef", 0) -- Searches for a player
		if playerList then
			for i = 1, #playerList do
				print("[" .. enumerations.community(playerList[i].community) .. "] " .. playerList[i].name)
			end
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()