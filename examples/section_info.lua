local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local location, err = client.getLocation(enumerations.forum.atelier801, enumerations.community.br, enumerations.section.off_topic) -- Gets a location table
		if location then
			local section
			section, err = client.getSection(location) -- Gets the info of a section
			if section then
				p(section)

				print("Getting section topics:")
				local topics
				topics, err = client.getSectionTopics(location, false, 1) -- Gets all the topics of the first page with simple info only
				if topics then
					p(topics)
				else
					print(err)
				end
			else
				print(err)
			end
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()