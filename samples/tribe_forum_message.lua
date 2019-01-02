local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local location = client.getTribeForum()[1] -- Gets the first section of the tribe forums
		
		local topic, err = client.createTopic("Testing API", "Aye Hey Hi", {
			f = location.f,
			s = location.s
		}) -- Creates a topic

		client.editAnswer('1', "Testing [b]two[/b]", topic.data) -- Edits the message sent

		print("Getting message edition history:")
		local history, err = client.getMessageHistory('1', topic.data) -- Gets the history of editions of the message
		if history then
			p(history)
		else
			print(err)
		end

		print("Unrestricting content of the message:")
		print(client.changeMessageContentState('1', enumerations.contentState.unrestricted, topic.data)) -- Unrestricts the use of images in the message
		
		print("Moderating message:")
		print(client.changeMessageState('1', enumerations.messageState.moderated, topic.data, "This is a test!")) -- Changes the message state

		print("Updating topic:")
		print(client.updateTopic(topic.data, {
			title = "Edited title",
			fixed = false,
			state = enumerations.displayState.active
		})) -- Updates the created topic
	end

	client.disconnect()
	os.execute("pause >nul")
end)()