coroutine.wrap(function()
	local forum = require("a801api")()

	local account = { "Test#0000", "12345" }
	
	print("Connecting to '" .. account[1] .. "'")
	local success, data = forum:connect(account[1], account[2])
	print("Connected to '" .. account[1] .. "'")

	success, data = forum:createTopic("Test", "I'm just testing!!1", {
		f = 0,
		s = 1
	})
	if not success then
		print("Could not create the topic", data)
	else
		print("Topic created")

		local topic, err = forum.fragmentUrl(data)
		if err then
			return print("Could not fragment " .. data)
		end

		success, data = forum:answerTopic("hi", {
			f = topic.f,
			t = topic.t
		})

		if not success then
			print("Can't post message", data)
		else
			print("Message posted")
		end
	end

	forum:disconnect()
end)()