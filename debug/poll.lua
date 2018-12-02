coroutine.wrap(function()
	local forum = require("a801api")()

	local account = { "Test#0000", "12345" }
	
	print("Connecting to '" .. account[1] .. "'")
	local success, data = forum:connect(account[1], account[2])
	print("Connected to '" .. account[1] .. "'")

	success, data = forum:createPoll("Test", "I'm just testing!!1", { "hey", "Hoi", "Hahah" }, {
		f = 0,
		s = 1
	}, {
		multiple = true
	})

	if not success then
		print("Could not create the poll", data)
	else
		print("Poll created")

		local topic, err = forum.fragmentUrl(data)
		if err then
			return print("Could not fragment " .. data)
		end

		success, data = forum:answerPoll("Hahah", {
			f = topic.f,
			t = topic.t
		})

		if not success then
			print("Can't vote on the poll", data)
		else
			print("Poll answer recorded")
		end
	end

	forum:disconnect()
end)()