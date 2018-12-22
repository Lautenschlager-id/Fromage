local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

local print_pollData = function(data)
	-- data.options is in a separated loop
	local f             = data.f
	local t             = data.t
	local co            = data.co
	local id            = data.id
	local author        = data.author
	local totalVotes    = data.totalVotes
	local isPublic      = data.isPublic
	local allowMultiple = data.allowMultiple
	local messageHtml   = data.messageHtml
	local timestamp     = data.timestamp

	print(string.format([[
f       : %s
t       : %s
co      : %s
Poll ID : %d

Author     : %s
Created in : %d

Total Votes    : %d
Is Public      : %s
Allow Multiple : %s

Message : %s
]],
		f,
		t,
		co,
		id,

		author,
		timestamp,

		totalVotes,
		isPublic,
		allowMultiple,

		messageHtml
	))
end

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		local do_poll = function(poll, err)
			if poll then
				print("Getting poll data:")
				local pollData
				pollData, err = client.getPoll(poll.data) -- Gets the private poll data
				if pollData then
					print_pollData(pollData)
	
					print("Poll options:")
					for i = 1, #pollData.options do
						print("[" .. pollData.options[i].id .. "] " .. pollData.options[i].value .. (pollData.options[i].votes and (" (" .. pollData.options[i].votes .. ") [" .. (pollData.options[i].votes / pollData.totalVotes * 100) .. "]") or ""))
					end
	
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