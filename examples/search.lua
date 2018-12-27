local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")

	if client.isConnected() then
		print("Searching for posts:")
		local postList, err = client.search(enumerations.searchType.message_topic, "bolo", 1, {
			searchLocation = enumerations.searchLocation.posts,
			f = enumerations.forum.atelier801,
			community = enumerations.community.br,
			s = enumerations.location.br.atelier801.discussions
		}) -- Searches for messages
		if postList then
			p(postList)
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
			p(postList)
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
			p(postList)
		else
			print(err)
		end

		print("Searching for tribe:")
		local tribeList
		tribeList, err = client.search(enumerations.searchType.tribe, "make tfm", 0) -- Searches for a tribe
		if tribeList then
			p(tribeList)
		else
			print(err)
		end

		print("Searching for player:")
		local playerList
		playerList, err = client.search(enumerations.searchType.player, "bolodef", 0) -- Searches for a player
		if playerList then
			p(playerList)
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()