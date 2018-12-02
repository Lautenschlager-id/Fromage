--[[ Dependencies ]]--
local http = require("coro-http")
local base64 = require("deps/base64")

--[[ Enums and Sets ]]--
local cookieState = {
	login = 0, -- Get all cookies
	afterLogin = 1, -- Get all cookies after login
	action = 2 -- afterLogin, except the ones in the `nonActionCookie` set.
}

local nonActionCookie = {
	["JSESSIONID"] = true,
	["token"] = true,
	["token_date"] = true
}

local forumUri = {
	--[[ Naming Convention:
		- new -> n
		- private -> p
		- message -> m
		- create -> c
		- answer -> a
	]]
	index = "index",
	connection = "identification",
	login = "login",
	logout = "deconnexion",
	cpm = "create-dialog",
	npm = "new-dialog",
	cpDisc = "create-discussion",
	npDisc = "new-discussion",
	npPoll = "new-private-poll",
	answer = "answer-conversation",
	cTopic = "create-topic",
	nTopic = "new-topic",
	nPoll = "new-forum-poll",
	aForumPoll = "answer-forum-poll",
	apPoll = "answer-conversation-poll"
}

local htmlChunk = {
	secretKeys = '<input type="hidden" name="(.-)" value="(.-)">',
	pollOption = '<label class="(.-) "> +<input type="%1" name="reponse_" id="reponse_(%d+)" value="%2" .-/> +(.-) +</label>',
	pollId = '<input type="hidden" name="po" value="(%d+)">'
}

local enumError = {
	secret_key_not_found = "Secret keys could not be found.",
	already_connected = "This instance is already connected, disconnect first.",
	not_connected = "This instance is not connected yet, connect first.",
	no_poll_responses = "Missing poll responses. There must be at least two responses.",
	invalid_forum_url = "Invalid Atelier801's url.",
	no_url_location = "Missing location. The fields %s are needed.",
	no_url_location_private = "The fields %s are needed if the object is private.",
	not_poll = "Invalid topic. Poll not detected.",
	internal = "Internal error.",
	poll_option_not_found = "Invalid poll option."
}

local separator = {
	cookie = ", ",
	forumData = "§#§"
}

--[[ Functions and Tables ]]--
local forumLink = "https://atelier801.com/"

local saltBytes = {
	247, 026, 166, 222,
	143, 023, 118, 168,
	003, 157, 050, 184,
	161, 086, 178, 169,
	062, 221, 067, 157,
	197, 221, 206, 086,
	211, 183, 164, 005,
	074, 013, 008, 176
}
do
	local chars = { }
	for i = 1, #saltBytes do
		chars[i] = string.char(saltBytes[i])
	end

	saltBytes = table.concat(chars)
end

local cryptToSha256 
do
	local required, openssl = pcall(require, "openssl")
	assert(required, "\"openssl\" module not found.")

	local sha256 = openssl.digest.get("sha256")
	cryptToSha256 = function(str)
		local hash = openssl.digest.new(sha256)
		hash:update(str)
		return hash:final()
	end
end

local getPasswordHash = function(password)
	local hash = cryptToSha256(password)
	hash = cryptToSha256(hash .. saltBytes)
	local len = #hash

	local out, counter = { }, 0
	for i = 1, len, 2 do
		counter = counter + 1
		out[counter] = string.char(tonumber(string.sub(hash, i, (i + 1)), 16))
	end

	return base64.encode(table.concat(out))
end

local encodeUrl = function(url)
	local out = {}

	string.gsub(url, '.', function(letter)
		out[#out + 1] = string.upper(string.format("%02x", string.byte(letter)))
	end)

	return "%" .. table.concat(out, '%')
end

local assertion = function(name, etype, id, value)
	local t = type(value)

	if type(etype) == "table" then
		local names, counter = { }, 0
		for k, v in next, etype do
			if v == t then
				return
			else
				names[counter] = v
			end
		end
		error("bad argument #" .. id .. " to '" .. name .. "' (" .. table.concat(names, " | ") .. " expected, got " .. t .. ")")
	else
		assert(t ~= etype, "bad argument #" .. id .. " to '" .. name .. "' (" .. etype .. " expected, got " .. t .. ")")
	end
end

local returnRedirection = function(success, data)
	if success then
		local link = string.match(data, '"redirection":"(.-)"')
		if link then
			return true, link
		end
	end

	return false, data
end

table.search = function(tbl, value, index)
	local found = false
	for k, v in next, tbl do
		if index and type(v) == "table" then
			found = (v[index] == value)
		else
			found = (v == value)
		end
		if found then
			return k
		end
	end
end

table.createSet = function(tbl, index)
	local out = { }
	for k, v in next, tbl do
		local i, j
		if index then
			i = v[index]
			j = v
		else
			i = v
			j = true
		end

		out[i] = j
	end
	return out
end

--[[ Class ]]--
return function()
	-- Internal
	local this = {
		-- Whether the account is connected or not
		isConnected = false,
		-- The nickname of the account, if it's connected.
		userName = '',
		cookieState = cookieState.login,
		-- Account cookies
		cookies = { }
	}
	-- External
	local self = { }

	--[[ System ]]--
	-- Sets the account cookies
	this.setCookies = function(this, header)
		for i = 1, #header do
			-- Won't break because there may be others
			if header[i][1] == "Set-Cookie" then
				local cookie = header[i][2]
				cookie = string.sub(cookie, 1, (string.find(cookie, ';') - 1))

				local eqPos = string.find(cookie, '=')
				local cookieName = string.sub(cookie, 1, (eqPos - 1))

				if (this.cookieState ~= cookieState.action) or (not nonActionCookie[cookieName]) then
					this.cookies[cookieName] = string.sub(cookie, (eqPos + 1))
				end
			end
		end
		if this.cookieState == cookieState.afterLogin then
			this.cookieState = cookieState.action
		end
	end

	-- Gets the default headers for every request
	this.getHeaders = function(this)
		local cookies, counter = { }, 0
		for cookieName, cookieValue in next, this.cookies do
			counter = counter + 1
			cookies[counter] = cookieName .. "=" .. cookieValue
		end

		return {
			{ "User-Agent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" },
			{ "Cookie", table.concat(cookies, separator.cookie) },
			{ "Accept-Language", "en-US,en;q=0.9" }
		}
	end

	-- Gets the secret keys to perform actions
	this.getSecretKeys = function(this, uri, ajaxUri)
		local head, body = http.request("GET", forumLink .. (uri or forumUri.index), this:getHeaders())

		this:setCookies(head)
		return { string.match(body, htmlChunk.secretKeys ) }
	end

	-- Performs a post action on forums
	this.performAction = function(this, uri, postData, ajaxUri)
		local secretKeys = this:getSecretKeys(ajaxUri)
		if #secretKeys == 0 then
			return false, enumError.secret_key_not_found
		end

		postData = postData or { }
		postData[#postData + 1] = secretKeys

		local headers = this:getHeaders()
		if ajaxUri then
			headers[3] = { "Accept", "application/json, text/javascript, */*; q=0.01" }
			headers[4] = { "X-Requested-With", "XMLHttpRequest" }
			headers[5] = { "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8" }
			headers[6] = { "Referer", forumLink .. ajaxUri }
			headers[7] = { "Connection", "keep-alive" }
		end

		local body, head = { }
		for index, data in next, postData do
			body[index] = data[1] .. "=" .. encodeUrl(data[2])
		end
		head, body = http.request("POST", forumLink .. uri, headers, table.concat(body, '&'))

		this:setCookies(head)

		return true, body
	end

	-- Gets a page using the headers of the account
	this.getPage = function(this, url)
		return http.request("GET", url, this:getHeaders())
	end

	--[[ Static Functions ]]--
	--[[@
		@desc Fragments a forum URL.
		@param url<string> The Atelier801's forum URL
		@returns table Fragmented URL. The available indexes are: `uri`, `raw_data` and `data`.
		@returns string|nil Error message
	]]
	self.fragmentUrl = function(url)
		local out = { }

		local std = "^(" .. forumLink .. ")(%S+)"
		local valid, uri, data = string.match(url, std .. "%?(.-)$")

		if not valid then
			data = ''
			valid, uri = string.match(url, std)
		end

		if valid then
			local raw_data = data

			local data = { }
			string.gsub(raw_data, "[^&]+", function(str)
				string.gsub(str, "(.-)=(.+)", function(name, value)
					data[name] = value
				end)
			end)

			return {
				uri = uri,
				raw_data = raw_data,
				data = data
			}
		end

		return out, enumError.invalid_forum_url
	end

	--[[@
		@desc Gets all the options of a poll.
		@param url<string> The Atelier801's forum URL
		@returns table Poll options. The indexes are `id` and `value`.
		@returns string|nil Error message
	]]
	self.getPollOptions = function(url)
		local out = { }

		if not string.find("^" .. forumLink) then
			return out, enumError.invalid_forum_url
		end

		local head, body = this:getPage(url)
		if not body then
			return out, enumError.internal
		end

		if string.find(body, "\"po\"") then -- Check if the topic is a poll
			local counter = 0
			string.gsub(body, htmlChunk.pollOption, function(t, id, value)
				if t == "radio" or t == "checkbox" then
					counter = counter + 1
					out[counter] = {
						id = id
						value = value
					}
				end
			end)

			return out
		end
		return out, enumError.not_poll
	end

	--[[ Functions ]]--
	--[[@
		@desc Connects to an account on Atelier801's forums.
		@param userName<string> Account's user name
		@param userPassword<string> Account's password
		@returns boolean Whether the account connected or not
		@returns string Result string
	]]
	self.connect = function(self, userName, userPassword)
		assertion("connect", "string", 1, userName)
		assertion("connect", "string", 2, userPassword)

		if this.isConnected then
			return false, enumError.already_connected
		end

		local postData = {
			{ "rester_connecte", "on" },
			{ "id", userName },
			{ "pass", getPasswordHash(userPassword) },
			{ "redirect", string.sub(forumLink, 1, -2) }
		}
		local success, data = this:performAction(forumUri.connection, postData, forumUri.login)
		if success then
			if string.sub(data, 2, 15) == '"supprime":"*"' then
				this.isConnected = true
				this.userName = userName
				this.cookieState = cookieState.afterLogin
				return true, data
			end
		end

		return false, data
	end

	--[[@
		@desc Disconnects from an account on Atelier801's forums.
		@returns boolean Whether the account disconnected or not
		@returns string Result string
	]]
	self.disconnect = function(self)
		if not this.isConnected then
			return false, enumError.not_connected
		end

		local success, data = this:performAction(forumUri.logout)
		if string.sub(body, 3, 13) == "redirection" then
			this.isConnected = false
			this.userName = ''
			this.cookieState = cookieState.login
			this.cookies = { }
			return true, data
		else
			return false, data
		end
	end

	--[[@
		@desc Creates a new private message.
		@param destinatary<string> The user who is going to receive the private message
		@param subject<string> The subject of the private message
		@param message<string> The content of the private message
		@returns boolean Whether the private message was created or not
		@returns string if #1, `private message's url`, else `Result string`
	]]
	self.createPrivateMessage = function(self, destinatary, subject, message)
		assertion("createPrivateMessage", "string", 1, destinatary)
		assertion("createPrivateMessage", "string", 2, subject)
		assertion("createPrivateMessage", "string", 3, message)

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataire", destinatary },
			{ "objet", subject },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.cpm, postData, forumUri.npm)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a new private discussion.
		@param destinataries<table> The users who are going to be invited to the private discussion
		@param subject<string> The subject of the private discussion
		@param message<string> The content of the private discussion
		@returns boolean Whether the private discussion was created or not
		@returns string if #1, `private discussion's url`, else `Result string`
	]]
	self.createPrivateDiscussion = function(self, destinataries, subject, message)
		assertion("createPrivateDiscussion", "table", 1, destinataries)
		assertion("createPrivateDiscussion", "string", 2, subject)
		assertion("createPrivateDiscussion", "string", 3, message)

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataires", table.concat(destinatary, separator.forumData) },
			{ "objet", subject },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.cpDisc, postData, forumUri.npDisc)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a new private poll.
		@param destinataries<table> The users who are going to be invited to the private poll
		@param subject<string> The subject of the private poll
		@param message<string> The content of the private poll
		@param pollResponses<table> The poll response options
		@param settings?<table> The poll settings. The available indexes are: `multiple` and `public`.
		@returns boolean Whether the private poll was created or not
		@returns string if #1, `private poll's url`, else `Result string`
	]]
	self.createPrivatePoll = function(self, destinataries, subject, message, pollResponses, settings)
		assertion("createPrivatePoll", "table", 1, destinataries)
		assertion("createPrivatePoll", "string", 2, subject)
		assertion("createPrivatePoll", "string", 3, message)
		assertion("createPrivatePoll", "table", 4, pollResponses)
		assertion("createPrivatePoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return false, enumError.no_poll_responses
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataires", table.concat(destinatary, separator.forumData) },
			{ "objet", subject },
			{ "message", message },
			{ "sondage", "on" },
			{ "reponses", table.concat(destinatary, separator.forumData) }
		}
		if settings then
			if settings.multiple then
				postData[#postData + 1] = { "multiple", "on" }
			end
			if settings.public then
				postData[#postData + 1] = { "publique", "on" }
			end
		end

		local success, data = this:performAction(forumUri.cpDisc, postData, forumUri.npPoll)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Answers a conversation.
		@param conversationId<string,int> The conversation id
		@param answer<string> The answer
		@returns boolean Whether the answer was posted or not
		@returns string if #1, `post's url`, else `Result string`
	]]
	self.answerConversation = function(self, conversationId, answer)
		if tonumber(conversationId) then
			conversationId = tostring(conversationId)
		end
		assertion("answerConversation", "string", 1, conversationId)
		assertion("answerConversation", "string", 2, answer)

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "co", conversationId },
			{ "message_reponse", answer }
		}
		local success, data = this:performAction(forumUri.answer, postData, "conversations?co=" .. conversationId)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a topic.
		@param title<string> The title of the topic
		@param message<string> The initial message of the topic
		@param location<table> The location where the topic should be created. Fields 'f' and 's' are needed.
		@returns boolean Whether the topic was created or not
		@returns string if #1, `topic's url`, else `Result string`
	]]
	self.createTopic = function(self, title, message, location)
		assertion("createTopic", "string", 1, title)
		assertion("createTopic", "string", 2, message)
		assertion("createTopic", "table", 3, location)

		if not location.f or not location.s then
			return false, string.format(enumError.no_url_location, "'f', 's'")
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ 'f', location.f },
			{ 's', location.s },
			{ "titre", title },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.cTopic, postData, forumUri.nTopic .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a new poll.
		@param title<string> The title of the poll
		@param message<string> The content of the poll
		@param pollResponses<table> The poll response options
		@param location<table> The location where the topic should be created. Fields 'f' and 's' are needed.
		@param settings?<table> The poll settings. The available indexes are: `multiple` and `public`.
		@returns boolean Whether the poll was created or not
		@returns string if #1, `poll's url`, else `Result string`
	]]
	self.createPoll = function(self, title, message, pollResponses, location, settings)
		assertion("createPoll", "string", 1, title)
		assertion("createPoll", "string", 2, message)
		assertion("createPoll", "table", 3, pollResponses)
		assertion("createPoll", "table", 4, location)
		assertion("createPoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return false, enumError.no_poll_responses
		end

		if not location.f or not location.s then
			return false, string.format(enumError.no_url_location, "'f', 's'")
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ 'f', location.f },
			{ 's', location.s },
			{ "titre", title },
			{ "message", message },
			{ "sondage", "on" },
			{ "reponses", table.concat(destinatary, separator.forumData) }
		}
		if settings then
			if settings.multiple then
				postData[#postData + 1] = { "multiple", "on" }
			end
			if settings.public then
				postData[#postData + 1] = { "publique", "on" }
			end
		end

		local success, data = this:performAction(forumUri.cTopic, postData, fforumUri.nPoll .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Answers a topic.
		@param message<string> The answer
		@param location<table> The location where the answer should be posted. Fields 'f' and 't' are needed.
		@returns boolean Whether the post was created or not
		@returns string if #1, `post's url`, else `Result string`
	]]
	self.answerTopic = function(self, message, location)
		assertion("answerTopic", "string", 1, message)
		assertion("answerTopic", "table", 2, location)

		if not location.f or not location.t then
			return false, string.format(enumError.no_url_location, "'f', 't'")
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ "message_reponse", message }
		}
		local success, data = this:performAction(forumUri.cTopic, postData, forumUri.nTopic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Answers a poll.
		@param option<int,table,string> The poll option to be selected. You can insert its ID or its text (highly recommended). For multiple options polls, use a table with `numbers` or `strings`.
		@param location<table> The location where the poll answer should be recorded. Fields 'f' and 't' are needed for forum poll, 'co' for private poll.
		@param pollId?<int> The poll id. It's obtained automatically if no value is given.
		@returns boolean Whether the poll option was recorded or not
		@returns string if #1, `poll's url`, else `Result string` or `Error message`
	]]
	self.answerPoll = function(self, option, location, pollId)
		assertion("answerPoll", { "number", "table", "string" }, 1, option)
		assertion("answerPoll", "table", 2, location)
		assertion("answerPoll", { "number", "nil" }, 3, pollId)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return false, string.format(enumError.no_url_location, "'f', 't'") .. " " .. string.format(enumError.no_url_location_private, "'co'")
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local url = forumLink .. (isPrivatePoll and ("conversations?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t))

		local optionIsString = type(option) == "string"
		if optionIsString or (type(option) == "table" and type(option[1]) == "string") then
			local options, err = self.getPollOptions(url)
			if err then
				return false, err
			end

			if optionIsString then
				local index = table.search(options, option, "value")
				if not index then
					return false, enumError.poll_option_not_found
				end
				option = options[index].id
			else
				local tmpSet = table.createSet(options, "value")
				for i = 1, #option do
					if tmpSet[options[i]] then
						options[i] = tmpSet[options[i]].id
					else
						return false, enumError.poll_option_not_found
					end
				end
			end
		end

		if not pollId then
			local head, body = this:getPage(forumLink .. pollId)
			if not body then
				return false, enumError.internal
			end

			pollId = tonumber(string.match(body, htmlChunk.pollId))
			if not pollId then
				return false, enumError.not_poll
			end
		end

		local postData = {
			{ "po", pollId }
		}
		if isPrivatePoll then
			postData[2] = { "co", location.co }
		else
			postData[2] = { 'f', location.f }
			postData[3] = { 't', location.t }
		end
		if type(option) == "string" then
			postData[#postData + 1] = { "reponse_", option }
		else
			local len = #postData
			for i = 1, #option do
				postData[len + i] = { ("reponse_" .. option[i]), option[i] }
			end
		end

		local success, data = this:performAction(forumUri[(isPrivatePoll and "apPoll" or "aForumPoll")], postData, url)
		return returnRedirection(success, data)
	end

	return self
end
