local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Members:")
		local members, err = client.getTribeMembers() -- Gets the list of members of the tribe
		if members then
			for i = 1, #members do
				print("[" .. enumerations.community(members[i].community) .. "] " .. members[i].name .. (members[i].rank and (" - " .. members[i].rank) or "") .. (members[i].timestamp and (" - " .. os.date("%c", members[i].timestamp / 1000)) or ""))
			end
			print("Total members: " .. members._count)
		else
			print(err)
		end

		print("Tribe ranks:")
		local ranks
		ranks, err = client.getTribeRanks() -- Gets the list of rank names of the tribe
		if ranks then
			for i = 1, #ranks do
				print(ranks[i])
			end	
		else
			print(err)
		end

		print("Tribe history:")
		local history
		history, err = client.getTribeHistory() -- Gets the list of history logs of the tribe
		if history then
			for i = 1, #history do
				print("[" .. os.date("%c", history[i].timestamp / 1000) .. "] " .. history[i].log)
			end
		else
			print(err)
		end

		print("Tribe forum sections:")
		local sections
		sections, err = client.getTribeForum() -- Gets the data of the tribe forum
		if sections then
			for i = 1, #sections do
				print((sections[i].tr and ("[" .. sections[i].tr .. "]") or "") .. (sections[i].f and ("[" .. sections[i].f .. ", " .. sections[i].s .. "]") or "") .. " " .. sections[i].name)
			end
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()