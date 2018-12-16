local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Favorite topics:")
		local favoriteTopics, err = client.getFavoriteTopics() -- Gets the favorite topics of the account
		if favoriteTopics then
			for i = 1, #favoriteTopics do
				print("[" .. favoriteTopics[i].favoriteId .. "] [" .. enumerations.community(favoriteTopics[i].community) .. "] " .. favoriteTopics[i].navbar[#favoriteTopics[i].navbar].name .. ", created on " .. os.date("%c", favoriteTopics[i].timestamp / 1000))
			end
		else
			print(err)
		end

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

		local bolosTribe = client.getTribe(bolosTribeId).favoriteId -- Gets someone tribe, and the value favoriteId
		print("Removes tribe favorite:")
		print(client.unfavoriteElement(bolosTribe)) -- Unfavorites a tribe
	end

	client.disconnect()
	os.execute("pause >nul")
end)()