local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")

local print_conversationData = function(data)
	local co               = data.co
	local title            = data.title
	local isPrivateMessage = data.isPrivateMessage
	local isDiscussion     = data.isDiscussion
	local isPoll           = data.isPoll
	local pollId           = data.pollId
	local pollOptions      = data.pollOptions
	local isLocked         = data.isLocked
	local pages            = data.pages
 	local totalMessages    = data.totalMessages
	local firstMessage     = data.firstMessage

	print(string.format([[
conversation ID : %d

Title          : %s
Locked         : %s
Total pages    : %d
Total messages : %d

Priv Message [%s] | Priv Disc [%s] | Priv Poll [%s]

Poll ID      : %s
Poll Options : %s

Author : %s
]], 
		co,

		title,
		isLocked,
		pages,
		totalMessages,

		(isPrivateMessage and 'x' or ''), (isDiscussion and 'x' or ''), (isPoll and 'x' or ''),

		pollId,
		(pollOptions and table.concat(pollOptions, " ; ") or nil),

		firstMessage.author
	))
end

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		local location, result, err

		location, result = client.createPrivateMessage("Bolodefchoco#0000", "PM", "[b]hahaha[/b]ha!") -- Creates a private message
		if location then
			local pm
			pm, err = client.getConversation(location.data) -- Gets the private message data
			if pm then
				print("Private message:")
				print_conversationData(pm)
			else
				print(err)
			end
		else
			print(result)
		end

		location, result = client.createPrivateDiscussion({ "Bolodefchoco#0000", "+Bolodefchoco#0000" }, "Conversation", "We're all noobs. [quote=Life]True[/quote]")
		if location then
			local conv
			conv, err = client.getConversation(location.data) -- Gets the private conversation data
			if conv then
				print("Private conversation:")
				print_conversationData(conv)
			else
				print(err)
			end
		else
			print(result)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()