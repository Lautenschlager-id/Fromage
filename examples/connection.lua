local api = require("fromage")
local client = api()

coroutine.wrap(function()
	print("Connecting to " .. account.username)
	local isConnected, result = client.connect("Username#0000", "password") -- Connects
	print(isConnected, result)

	if isConnected then
		print(client.isConnected()) -- Checks whether the instance is really connected, also the user name and id
		print(client.getUser()) -- Gets the data of the account
		print(client.getConnectionTime()) -- Shows the time since the connection

		print("Disconnecting from " .. account.username)
		print(client.disconnect()) -- Disconnects

		print(client.isConnected())
	end

	os.execute("pause >nul")
end)()