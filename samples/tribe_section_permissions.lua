local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

local checkPermission = function(perm)
	io.write("\n\t[y/n]\t" .. perm .. "? ")

	local answer = string.lower(io.read(1))
	io.read() -- ?!
	return answer == 'y'
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local section = client.createSection({
			name = "API",
			icon = enumerations.sectionIcon.cogwheel
		}) -- Creates a section

		local tribeRanks = client.getTribeRanks() -- Gets the tribe ranks

		local indexes = {
			{ "canRead", { }, 0 },
			{ "canAnswer", { }, 0 },
			{ "canCreateTopic", { }, 0 },
			{ "canModerate", { }, 0 },
			{ "canManage", { }, 0 }
		}

		for i = 2, 3 do -- Skips the leader role. It's added automatically
			print("\nRole '" .. tribeRanks[i] .. "'")
			for j = 1, #indexes do
				local perm = string.gsub(indexes[j][1], "%u", " %1", 1) -- Makes the field name more readable
				if checkPermission(perm) then
					indexes[j][3] = indexes[j][3] + 1 -- Counter
					indexes[j][2][indexes[j][3]] = tribeRanks[i]
				end
			end
		end

		print("\nNon members")
		for j = 1, #indexes - 2 do
			local perm = string.gsub(indexes[j][1], "%u", " %1", 1)
			if checkPermission(perm) then
				indexes[j][3] = indexes[j][3] + 1
				indexes[j][2][indexes[j][3]] = enumerations.misc.non_member
			end
		end

		local data = { }
		for i = 1, #indexes do
			data[indexes[i][1]] = indexes[i][2]
		end
		
		print(client.setTribeSectionPermissions(data, section))
	end

	client.disconnect()
	os.execute("pause >nul")
end)()