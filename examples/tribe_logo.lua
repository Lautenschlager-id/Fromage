local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Updating tribe logo:")
		print(client.changeTribeLogo("http://avatars.atelier801.com/3955/7903955.jpg?1544677221208")) -- Changes the tribe logo

		print("Removing logo:")
		print(client.removeTribeLogo()) -- Removes the tribe logo
	end

	client.disconnect()
	os.execute("pause >nul")
end)()