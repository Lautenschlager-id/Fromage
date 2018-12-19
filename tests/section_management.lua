local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Creating section:")
		local section, err = client.createSection({
			name = "API",
			icon = enumerations.sectionIcon.cogwheel,
		}) -- Creates a section in your tribe forum			min_characters = 5

		if section then
			print("New section id: " .. section.f .. ", " .. section.s)

			print("Updating section:")
			print(client.updateSection({
				state = enumerations.displayState.locked,
				icon = enumerations.sectionIcon.hole
			}, section)) -- Updates the section
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()