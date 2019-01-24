local api = require("fromage")
local client = api()

coroutine.wrap(function()
	print("Connecting to " .. account.username)
	local isConnected, result = client.connect("Username#0000", "password") -- Connects
	print(isConnected, result)

	if isConnected then
		print(client.isConnected()) -- Checks whether the instance is set as connected
		print(client.getUser()) -- Gets the data of the account (as name, tribe id, ...)
		print(client.getConnectionTime()) -- Shows the time since the connection
		print(client.extensions()) -- Extension functions
		print(client.isConnectionAlive()) -- Checks whether the connection is alive.

		print("Disconnecting from " .. account.username)
		print(client.disconnect()) -- Disconnects

		print(client.isConnected())
	end

	os.execute("pause >nul")
end)()