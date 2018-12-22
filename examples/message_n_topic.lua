local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Creating topic:")
		local topic, err = client.createTopic("Testing API", "Aye Hey Hi", {
			f = enumerations.forum.atelier801,
			s = 167
		}) -- Creates a topic
		if topic then
			print("Topic ID: " .. topic.data.t)

			print("Sending message to the topic:")
			local message
			message, err = client.answerTopic("Testing!", topic.data) -- Sends a new message in a topic
			if message then
				print("Message post id: #" .. message.num_id)

				print("Editing message:")
				print(client.editAnswer(message.num_id, "Testing [b]two[/b]", topic.data)) -- Edits the message sent
				
				local subClient = api()
				subClient.connect("Username2#0000", "password2") -- Logs in another account to like
				print("Liking message:")
				print(subClient.likeMessage(message.num_id, topic.data)) -- Likes a message
				subClient.disconnect()
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