local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

local print_topicData = function(data)
	local f             = data.f
	local s             = data.s
	local t             = data.t
	local elementId     = data.elementId
	local navbar        = data.navbar
	local title         = data.title
	local isFixed       = data.isFixed
	local isLocked      = data.isLocked
	local isDeleted     = data.isDeleted
	local isFavorited   = data.isFavorited
	local favoriteId    = data.favoriteId
	local pages         = data.pages
	local totalMessages = data.totalMessages
	local firstMessage  = data.firstMessage
	local community     = data.community
	local isPoll        = data.isPoll
	local poll          = data.poll

	print(string.format([[
f         : %d
s         : %d
t         : %d
Community : %s [%s]

Element ID : %d

Title          : %s
Navigation bar : %s

Is fixed [%s] | Is locked [%s] | Is deleted [%s]

Is favorited : %s
Favorite ID  : %s

Total pages    : %d
Total messages : %d

Author : %s

Is Poll : %s
Poll ID : %s
]],
		f,
		s,
		t,
		enumerations.community(community), community, -- Can be nil if it's a forum topic

		elementId,

		title,
		navbar[#navbar - 1].name .. " / " .. navbar[#navbar].name,

		(isFixed and "x" or ""), (isLocked and "x" or ""), (isDeleted and "x" or ""),

		isFavorited,
		favoriteId,

		pages,
		totalMessages,

		(firstMessage and firstMessage.author or nil),

		isPoll,
		(isPoll and poll.id or nil)
	))
end

local print_messageData = function(data)
	local f                = data.f
	local t                = data.t
	local p                = data.p
	local post             = data.post
	local timestamp        = data.timestamp
	local author           = data.author
	local id               = data.id
	local prestige         = data.prestige
	local content          = data.content
	local messageHtml      = data.messageHtml
	local isEdited         = data.isEdited
	local editionTimestamp = data.editionTimestamp
	local isModerated      = data.isModerated
	local moderatedBy      = data.moderatedBy
	local reason           = data.reason

	print(string.format([[
f       : %d
t       : %d
p       : %d
Post id : %d
Id      : %d

Author     : %s
Created in : %d
Prestige   : %s

Was edited        : %s
Edition timestamp : %s

Is moderated      : %s
Moderated by      : %s
Moderation Reason : %s

HTML Content : %s
Content      : %s
	]],
		f,
		t,
		p,
		post,
		id,

		author,
		timestamp,
		prestige,

		isEdited,
		editionTimestamp,

		isModerated,
		moderatedBy,
		reason,

		messageHtml,
		content
	))
end

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Creating topic:")
		local topic = client.createTopic("Testing API", "Aye Hey Hi", {
			f = enumerations.forum.atelier801,
			s = 167
		}) -- Creates a topic

		print("Getting topic info:")
		local topicData, err = client.getTopic(topic.data) -- Gets the data of the topic
		if topicData then
			print_topicData(topicData)

			print("Getting message info:")
			local message
			message, err = client.getMessage('1', topic.data) -- topicData.firstMessage, gets the data of a message
			if message then
				print_messageData(message)
			else
				print(err)
			end

			print("Getting all topic messages:")
			local messages
			messages, err = client.getTopicMessages(topic.data, false, 1) -- Gets all the messages of the first page with simple info only
			if messages then
				for i = 1, #messages do
					print("[" .. messages[i].f .. ", " .. messages[i].t .. "] " .. messages[i].id .. ", page " .. messages[i].p .. ", post #" .. messages[i].post)
				end
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