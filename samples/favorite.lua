local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local bolosTopic = client.getCreatedTopics("Bolodefchoco#0000")[1].location.data -- Gets the topics created by someone, then its location
		print("Favoriting a topic:")
		print(client.favoriteElement(enumerations.element.topic, bolosTopic.t, bolosTopic)) -- Favorites a topic

		print("Favorite topics:")
		local favoriteTopics, err = client.getFavoriteTopics() -- Gets the favorite topics of the account
		if favoriteTopics then
			p(favoriteTopics)
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
			p(favoriteTribes)
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