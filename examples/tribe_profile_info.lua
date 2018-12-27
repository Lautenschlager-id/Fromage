local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Tribe's profile:")
		local tribe, err = client.getTribe() -- Gets the client's tribe
		if tribe then
			p(tribe)
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()