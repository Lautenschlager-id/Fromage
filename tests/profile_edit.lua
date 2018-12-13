local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print(client.updateProfile({
			community = enumerations.community.en,
			birthday = "10/10/2010",
			location = "Burning in hell",
			gender = enumerations.gender.male,
			presentation = "[b]Heya![/b] I love [color=#FFFFFF]Malibu[/color]"
		}))

		print(client.updateParameters({
			online = true
		}))
	end

	client.disconnect()
	os.execute("pause >nul")
end)()