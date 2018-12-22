local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Updating tribe greeting:")
		print(client.updateTribeGreetingMessage("Testing bot.")) -- Changes the greeting message of the tribe

		print("Updating tribe parameters:")
		print(client.updateTribeParameters({
			leader = true
		})) -- Changes the parameters in the profile of the tribe

		print("Updating tribe profile:")
		print(client.updateTribeProfile({
			community = enumerations.community.xx,
			recruitment = enumerations.recruitmentState.closed
		})) -- Edits the profile of the tribe
	end

	client.disconnect()
	os.execute("pause >nul")
end)()