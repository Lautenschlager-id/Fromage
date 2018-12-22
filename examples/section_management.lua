local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
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