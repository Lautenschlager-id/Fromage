local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Creating topic:")
		local topic = client.createTopic("Testing API", "Aye Hey Hi", {
			f = enumerations.forum.atelier801,
			s = 167
		}) -- Creates a topic

		print("Getting topic info:")
		local topicData, err = client.getTopic(topic.data) -- Gets the data of the topic
		if topicData then
			p(topicData)

			print("Getting message info:")
			local message
			message, err = client.getMessage('1', topic.data) -- topicData.firstMessage, gets the data of a message
			if message then
				p(message)
			else
				print(err)
			end

			print("Getting all topic messages:")
			local messages
			messages, err = client.getTopicMessages(topic.data, false, 1) -- Gets all the messages of the first page with simple info only
			if messages then
				p(messages)
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