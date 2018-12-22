local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Adding friend:")
		print(client.addFriend("Bolodefchoco#0000")) -- Adds a friend

		print("Friendlist:")
		local friends, err = client.getFriendlist() -- Gets the friendlist
		if friends then
			print(table.concat(friends, ", "))
		else
			print(err)
		end

		print("Adding someone to the blacklist:")
		print(client.blacklistUser("Tigrounette#0001")) -- Adds someone in the blacklist

		print("Blacklist:")
		local blacklist
		blacklist, err = client.getBlacklist() -- Gets the blacklist
		if blacklist then
			print(table.concat(blacklist, ", "))
		else
			print(err)
		end

		print("Removing blacklisted:")
		print(client.unblacklistUser("Tigrounette#0001")) -- Removes someone from the blacklist
	end

	client.disconnect()
	os.execute("pause >nul")
end)()