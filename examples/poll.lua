local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local do_poll = function(poll, err)
			if poll then
				print("Getting poll data:")
				local pollData
				pollData, err = client.getPoll(poll.data) -- Gets the private poll data
				if pollData then
					p(pollData)
	
					print("Answering poll:")
					print(client.answerPoll(pollData.options[1].id, poll.data, pollData.id)) -- Answers a poll
				else
					print(err)
				end
			else
				print(err)
			end
		end

		print("Creating private poll:")
		local poll, err = client.createPrivatePoll({ "Bolodefchoco#0000", "+Bolodefchoco#0000" }, "Poll test", "That's the question", { "To be", "Not to be" }, { public = true, multiple = true }) -- Creates a private poll
		do_poll(poll, err)

		print("Creating public poll:")
		poll, err = client.createPoll("Poll test", "That's the question", { "To be", "Not to be" }, {
			f = enumerations.forum.atelier801,
			s = 167
		}, { public = true, multiple = true }) -- Creates a poll
		do_poll(poll, err)
	end

	client.disconnect()
	os.execute("pause >nul")
end)()