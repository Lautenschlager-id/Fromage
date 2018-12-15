local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Updating avatar:")
		print(client.updateAvatar("http://avatars.atelier801.com/3955/7903955.jpg?1544677221208")) -- Changes the avatar picture

		local time = os.time() + 10 -- 10 seconds
		while os.time() < time do end

		print("Removing avatar:")
		print(client.removeAvatar()) -- Removes the avatar picture
	end

	client.disconnect()
	os.execute("pause >nul")
end)()