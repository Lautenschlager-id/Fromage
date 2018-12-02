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
	index = "index",
	connection = "identification",
	login = "login",
	logout = "deconnexion"
}

local htmlChunk = {
	secretKeys = '<input type="hidden" name="(.-)" value="(.-)">'
}

local enumError = {
	secret_key_not_found = "Secret keys could not be found.",
	already_connected = "This instance is already connected, disconnect first.",
	not_connected = "This instance is not connected yet, connect first."
}

--[[ Functions and Tables ]]--
local forumLink = "https://188.165.220.104/"

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

getPasswordHash = function(password)
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
			{ "Cookie", table.concat(cookies, "; ") }
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

	--[[ Functions ]]--
	--[[@
		@desc Connects to an account on Atelier801's forums.
		@param userName<string> Account's user name
		@param userPassword<string> Account's password
		@returns boolean Whether the account connected or not
		@returns string Result
	]]
	self.connect = function(self, userName, userPassword)
		assert(type(userName) ~= "string", "bad argument #1 to 'connect' (string expected, got " .. type(userName) .. ")")
		assert(type(userPassword) ~= "string", "bad argument #2 to 'connect' (string expected, got " .. type(userPassword) .. ")")

		if this.isConnected then
			return false, enumError.already_connected
		end

		local postData = {
			{ "rester_connecte", "on" },
			{ "id", userName },
			{ "pass", getPasswordHash(userPassword) },
			{ "redirect", string.sub(forumLink, 1, -2) }
		}
		local sucess, data = this:performAction(forumUri.connection, postData, forumUri.login)
		if not sucess then
			return false, data
		else
			if string.sub(data, 2, 15) == '"supprime":"*"' then
				this.isConnected = true
				this.userName = userName
				this.cookieState = cookieState.afterLogin
				return true, data
			else
				return false, data
			end
		end
	end

	--[[@
		@desc Disconnects from an account on Atelier801's forums.
		@returns boolean Whether the account disconnected or not
		@returns string Result
	]]
	self.disconnect = function(self)
		if not this.isConnected then
			return false, enumError.not_connected
		end

		local sucess, data = this:performAction(forumUri.logout)
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

	return self
end
