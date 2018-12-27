local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Getting dev-tracker:")
		local lastMessages, err = client.getDevTracker() -- Gets the last messages posted in dev-tracker
		if lastMessages then
			p(lastMessages)
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()