local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		local bolosTopic = client.getCreatedTopics("Bolodefchoco#0000")[1].location.data -- Gets the topics created by someone, then its location
		print("Favoriting a topic:")
		print(client.favoriteElement(enumerations.element.topic, bolosTopic.t, bolosTopic)) -- Favorites a topic

		print("Favorite topics:")
		local favoriteTopics, err = client.getFavoriteTopics() -- Gets the favorite topics of the account
		if favoriteTopics then
			for i = 1, #favoriteTopics do
				print("[" .. favoriteTopics[i].favoriteId .. "] [" .. enumerations.community(favoriteTopics[i].community) .. "] " .. favoriteTopics[i].navbar[#favoriteTopics[i].navbar].name .. ", created on " .. os.date("%c", favoriteTopics[i].timestamp / 1000))
			end
		else
			print(err)
		end

		print("Unfavoriting a topic:")
		local bolosTopicFavId = client.getTopic(bolosTopic).favoriteId
		print(client.unfavoriteElement(bolosTopicFavId, bolosTopic)) -- Unfavorites a topic

		local bolosTribeId = client.getProfile("Bolodefchoco#0000").tribeId -- Gets someone profile, and the value tribeId
		print("Favorites a tribe:")
		print(client.favoriteElement(enumerations.element.tribe, bolosTribeId)) -- Favorites a tribe

		print("Favorite tribes:")
		local favoriteTribes
		favoriteTribes, err = client.getFavoriteTribes() -- Gets the favorite tribes of the account
		if favoriteTribes then
			for i = 1, #favoriteTribes do
				print("[" .. favoriteTribes[i].id .. "] " .. favoriteTribes[i].name)
			end
		else
			print(err)
		end

		local bolosTribeFavId = client.getTribe(bolosTribeId).favoriteId -- Gets someone tribe, and the value favoriteId
		print("Removes tribe favorite:")
		print(client.unfavoriteElement(bolosTribeFavId)) -- Unfavorites a tribe
	end

	client.disconnect()
	os.execute("pause >nul")
end)()