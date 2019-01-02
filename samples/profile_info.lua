local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password") -- Needs a connection for 'getProfile(nil)'
	
	if client.isConnected() then
		print("Account's profile:")
		local myProfile, result = client.getProfile() -- Gets account's profile
		if myProfile then
			p(myProfile)
		else
			print(result)
		end

		print("Bolo's profile:")
		local boloProfile, result = client.getProfile("Bolodefchoco#0000") -- Gets Bolodefchoco's profile
		if boloProfile then
			p(boloProfile)
		else
			print(result)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()