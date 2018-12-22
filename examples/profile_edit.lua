local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Editing profile:")
		print(client.updateProfile({
			community = enumerations.community.en,
			birthday = "10/10/2010",
			location = "Burning in hell",
			gender = enumerations.gender.male,
			presentation = "[b]Heya![/b] I love [color=#FFFFFF]Malibu[/color]"
		})) -- Updates the account's profile

		print("Editing parameters:")
		print(client.updateParameters({
			online = true
		})) -- Updates the parameters of the profile
	end

	client.disconnect()
	os.execute("pause >nul")
end)()