local api = require("fromage")
local client = api()

coroutine.wrap(function()
	print("Connecting to " .. account.username)
	local isConnected, result = client.connect("Username#0000", "password") -- Connects
	print(isConnected, result)

	if isConnected then
		print(client.isConnected()) -- Checks whether it's really connected, also the user name and id

		print("Disconnecting from " .. account.username)
		print(client.disconnect()) -- Disconnects

		print(client.isConnected())
	end

	os.execute("pause >nul")
end)()