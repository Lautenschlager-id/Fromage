--[[ Dependencies ]]--
local http = require("coro-http")
local base65 = require("deps/base64")

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
	answer = "answer-conversation"
}

local htmlChunk = {
	secretKeys = '<input type="hidden" name="(.-)" value="(.-)">'
}

local enumError = {
	secret_key_not_found = "Secret keys could not be found.",
	already_connected = "This instance is already connected, disconnect first.",
	not_connected = "This instance is not connected yet, connect first.",
	no_poll_responses = "Missing poll responses. There must be at least two responses.",
	invalid_forum_url = "Invalid Atelier801's url."
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

local assertion = function(name, etype, id, value, optional)
	local t = type(value)
	if optional and t ~= "nil" then
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
			{ "Cookie", table.concat(cookies, separator.cookie) }
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
			headers[4] = { "Accept-Language", "en-US,en;q=0.9" }
			headers[5] = { "X-Requested-With", "XMLHttpRequest" }
			headers[6] = { "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8" }
			headers[7] = { "Referer", forumLink .. ajaxUri }
			headers[8] = { "Connection", "keep-alive" }
		end

		local body, head = { }
		for index, data in next, postData do
			body[index] = data[1] .. "=" .. encodeUrl(data[2])
		end
		head, body = http.request("POST", forumLink .. uri, headers, table.concat(body, '&'))

		this:setCookies(head)

		return true, body
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
		@param destinataryUser<string> The user who is going to receive the private message
		@param messageSubject<string> The subject of the private message
		@param message<string> The content of the private message
		@returns boolean Whether the private message was created or not
		@returns string if #1, `private message's url`, else `Result string`
	]]
	self.createPrivateMessage = function(self, destinataryUser, messageSubject, message)
		assertion("createPrivateMessage", "string", 1, destinataryUser)
		assertion("createPrivateMessage", "string", 2, messageSubject)
		assertion("createPrivateMessage", "string", 3, message)

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataire", destinataryUser },
			{ "objet", messageSubject },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.cpm, postData, forumUri.npm)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a new private discussion.
		@param destinataryUsers<table> The users who are going to be invited to the private discussion
		@param messageSubject<string> The subject of the private discussion
		@param message<string> The content of the private discussion
		@returns boolean Whether the private discussion was created or not
		@returns string if #1, `private discussion's url`, else `Result string`
	]]
	self.createPrivateDiscussion = function(self, destinataryUsers, messageSubject, message)
		assertion("createPrivateDiscussion", "table", 1, destinataryUsers)
		assertion("createPrivateDiscussion", "string", 2, messageSubject)
		assertion("createPrivateDiscussion", "string", 3, message)

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataires", table.concat(destinataryUser, separator.forumData) },
			{ "objet", messageSubject },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.cpDisc, postData, forumUri.npDisc)
		return returnRedirection(success, data)
	end

	--[[@
		@desc Creates a new private poll.
		@param destinataryUsers<table> The users who are going to be invited to the private poll
		@param pollSubject<string> The subject of the private poll
		@param message<string> The content of the private poll
		@param pollResponses<table> The poll response options
		@param settings<table?> The poll settings. The available indexes are: `multiple` and `public`.
		@returns boolean Whether the private poll was created or not
		@returns string if #1, `private poll's url`, else `Result string`
	]]
	self.createPrivatePoll = function(self, destinataryUsers, pollSubject, message, pollResponses, settings)
		assertion("createPrivatePoll", "table", 1, destinataryUsers)
		assertion("createPrivatePoll", "string", 2, pollSubject)
		assertion("createPrivatePoll", "string", 3, message)
		assertion("createPrivatePoll", "table", 4, pollResponses)
		assertion("createPrivatePoll", "table", 5, message, true)

		if #pollResponses < 2 then
			return false, enumError.no_poll_responses
		end

		if not this.isConnected then
			return false, enumError.not_connected
		end

		local postData = {
			{ "destinataires", table.concat(destinataryUser, separator.forumData) },
			{ "objet", messageSubject },
			{ "message", message },
			{ "sondage", "on" },
			{ "reponses", table.concat(destinataryUser, separator.forumData) }
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

	return self
end
