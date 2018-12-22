local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

local print_sectionData = function(data)
	local f                = data.f
	local s                = data.s
	local navbar           = data.navbar
	local name             = data.name
	local hasSubsections   = data.hasSubsections
	local totalSubsections = data.totalSubsections
	local subsections      = data.subsections
	local isSubsection     = data.isSubsection
	local parent           = data.parent
	local pages            = data.pages
	local totalTopics      = data.totalTopics
	local totalFixedTopics = data.totalFixedTopics
	local community        = data.community
	local icon             = data.icon

	print(string.format([[
f : %s
s : %s

Name      : %s
Community : %s [%s]

Icon : %s

Navigation bar  : %s
Parent : [%s, %s] %s

Is Subsection     : %s
Has Subsections   : %s
Total Subsections : %s
Subsections   [1] : [%s, %s] %s

Pages              : %s
Total topics       : %s
Total fixed topics : %s
]],
		f,
		s,

		name,
		enumerations.community(community), community,

		icon,

		navbar[#navbar - 1].name .. " / " .. navbar[#navbar].name,
		(parent and parent.location.data.f), (parent and parent.location.data.s), (parent and parent.name),

		isSubsection,
		hasSubsections,
		totalSubsections,
		(subsections and subsections[1].location.data.f), (subsections and subsections[1].location.data.s), (subsections and subsections[1].name),
	
		pages,
		totalTopics,
		totalFixedTopics
	))
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local location, err = client.getLocation(enumerations.forum.atelier801, enumerations.community.br, enumerations.section.off_topic) -- Gets a location table
		if location then
			local section
			section, err = client.getSection(location) -- Gets the info of a section
			if section then
				print_sectionData(section)

				print("Getting section topics:")
				local topics
				topics, err = client.getSectionTopics(location, false, 1) -- Gets all the topics of the first page with simple info only
				if topics then
					for i = 1, #topics do
						print("[" .. topics[i].f .. ", " .. topics[i].s .. "] " .. topics[i].t .. " - " .. topics[i].title .. ", created on " .. os.date("%c", topics[i].timestamp / 1000))
					end
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