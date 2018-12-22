local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		local mapcrew, err = client.getStaffList(enumerations.listRole.mapcrew) -- Gets a list of staff members
		if mapcrew then
			print("Mapcrews:")
			print(table.concat(mapcrew, '\n'))
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()