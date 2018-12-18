local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
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