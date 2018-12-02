coroutine.wrap(function()
	local forum = require("a801api")()

	local account = { "Test#0000", "12345" }
	
	print("Connecting to '" .. account[1] .. "'")
	local success, data = forum:connect(account[1], account[2])
	print("Connected to '" .. account[1] .. "'")

	success, data = forum:createPrivateMessage("Test2#0000", "API", "Testing it.")
	if not success then
		print("Can not create new Private Message", data)
	else
		print("Created new Private Message")

		local link, err = forum.fragmentUrl(data)
		if err then
			return print("Could not fragment " .. data)
		end
		success, data = forum:answerConversation(link.co, "Hiiiii")
		if not success then
			print("Can not answer conversation.", data)
		else
			print("Conversation answered")

			print(forum:createPrivateDiscussion({ "Test2#0000", "Test3#0000" }, "Api disc", "Testing again."))
			print(forum:createPrivatePoll({ "Test2#0000", "Test3#0000" }, "Api poll", "Vote please!", { "Yes", "No" }, {
				public = true,
				multiple = false
			}))
		end
		
	end

	forum:disconnect()
end)()