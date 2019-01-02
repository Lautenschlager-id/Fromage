local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Members:")
		local members, err = client.getTribeMembers() -- Gets the list of members of the tribe
		if members then
			p(members)
		else
			print(err)
		end

		print("Tribe ranks:")
		local ranks
		ranks, err = client.getTribeRanks() -- Gets the list of rank names of the tribe
		if ranks then
			p(ranks)
		else
			print(err)
		end

		print("Tribe history:")
		local history
		history, err = client.getTribeHistory() -- Gets the list of history logs of the tribe
		if history then
			p(history)
		else
			print(err)
		end

		print("Tribe forum sections:")
		local sections
		sections, err = client.getTribeForum() -- Gets the data of the tribe forum
		if sections then
			p(sections)
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()