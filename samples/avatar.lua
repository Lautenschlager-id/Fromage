local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Updating avatar:")
		print(client.changeAvatar("http://avatars.atelier801.com/3955/7903955.jpg?1544677221208")) -- Changes the avatar picture

		print("Removing avatar:")
		print(client.removeAvatar()) -- Removes the avatar picture
	end

	client.disconnect()
	os.execute("pause >nul")
end)()