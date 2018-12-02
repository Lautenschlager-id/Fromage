coroutine.wrap(function()
	local forum = require("a801api")

	local account = { "Test#0000", "12345" }
	
	print("Connecting to '" .. account[1] .. "'")
	local sucess, err = forum:connect(account[1], account[2])
	if not sucess then
		print("Can not connect to '" .. account[1] .. "'")
		print(err)
	else
		print("Connected to '" .. account[1] .. "'")

		sucess, err = forum:disconnect()
		if not sucess then
			print("Can not disconnect from '" .. account[1] .. "'")
			print(err)
		else
			print("Disconnected from '" .. account[1] .. "'")
		end
	end
end)()