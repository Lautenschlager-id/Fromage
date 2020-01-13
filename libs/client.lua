local base64 = require("base64")
local http = require("coro-http")

local encode = require("encode")
local enum = require("enum")
local extensions = require("extensions")
local fileManager = require("fileManager")

local forumLink = "https://atelier801.com/"
local actionHeaders = {
	[4] = { "Accept", "application/json, text/javascript, */*; q=0.01" }
	[5] = { "X-Requested-With", "XMLHttpRequest" }
	[6] = { "Content-Type" }
	[7] = { "Referer" }
	[8] = { "Connection", "keep-alive" }
	_fileData = "multipart/form-data; boundary=",
	_urlencoded = "application/x-www-form-urlencoded; charset=UTF-8"
}

local client = table.setNewClass()

client.new = function(self)
	return setmetable({
		isConnected = false,
		username = nil,
		userId = nil,
		tribeId = nil,
		cookies = { },
		cookiesStr = '',
		cookieState = enum.cookieState.login,
		hasCertificate = false,
		connectionTime = -1
	}, self)
end

--[[ Private ]]--
local setCookies = function(self, header)
	-- Add new cookies
	for i = 1, #header do
		-- Won't break because there may be others
		if header[i][1] == "Set-Cookie" then
			local cookie = header[i][2]
			cookie = string.sub(cookie, 1, (string.find(cookie, ';') - 1))

			local eqPos = string.find(cookie, '=')
			local cookieName = string.sub(cookie, 1, (eqPos - 1))

			if (self.cookieState ~= cookieState.action) or (not enum.nonActionCookie[cookieName]) then
				self.cookies[cookieName] = cookie
			end
		end
	end

	if self.cookieState == enum.cookieState.after_login then
		self.cookieState = enum.cookieState.action
	end

	-- Create string
	local cookies, counter = { }, 0
	for _, cookie in next, self.cookies do
		counter = counter + 1
		cookies[counter] = cookie
	end
	self.cookiesStr = table.concat(cookies, enum.separator.cookie)
end

local getHeaders = function(self)
	-- Needs to recreate to avoid references
	return {
		{ "User-Agent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" },
		{ "Cookie", self.cookiesStr },
		{ "Accept-Language", "en-US,en;q=0.9" }
	}
end

local getSecretKeys = function(self, uri)
	local head, body = http.request("GET", forumLink .. (uri or enum.forumUri.index), getHeaders())

	setCookies(self, head)
	return { string.match(body, enum.htmlChunk.secret_keys ) }
end

local performAction
do
	local getSecretKey = function(id)
		return secretKeys[tonumber(id)]
	end

	performAction = function(self, uri, postData, ajaxUri, file)
		local secretKeys = getSecretKeys(self, ajaxUri)
		if #secretKeys == 0 then
			return nil, enum.errorString.secret_key_not_found
		end

		postData = postData or { }
		postData[#postData + 1] = secretKeys

		local headers = getHeaders(self)
		if ajaxUri then
			headers = table.add(headers, actionHeaders)
			headers[6][2] = (file and (actionHeaders._fileData .. fileManager.boundaries[1]) or actionHeaders._urlencoded)
			headers[7][2] = forumLink .. ajaxUri
		end

		local body, head = { }
		for index, data in next, postData do
			body[index] = data[1] .. "=" .. extensions.encodeUrl(data[2])
		end

		head, body = http.request("POST", forumLink .. uri, headers, (file and (string.gsub(file, "/KEY(%d)/", getSecretKey)) or (table.concat(body, '&'))))

		setCookies(self, head)

		return body
	end
end

local getPage = function(self, url)
	local head, body = http.request("GET", forumLink .. url, getHeaders(self))
	return body, head
end

local parseUrlData = function(href)
	href = string.gsub(href, forumLink, '')
	local uri, data = string.match(href, "/?([^%?]+)%??(.*)$")
	if not uri then
		return nil, enum.errorString.invalid_forum_url
	end

	local raw_data = data

	local data = { }
	for name, value in string.gmatch(raw_data, "([^&]+)=([^&#]+)") do
		data[name] = tonumber(value) or value
	end

	return {
		uri = uri,
		raw_data = raw_data,
		data = data,
		id = string.match(raw_data, "#(.-)$"),
		num_id = string.match(raw_data, "#.-(%d+).-$")
	}
end

local getNavbar = function(content, isNavbar)
	local navBar = (isNavbar and content or string.match(content, enum.htmlChunk.navigation_bar))
	if not navBar then
		return nil, enum.errorString.internal .. " (0x1)"
	end

	local navigation_bar = { }
	local counter = 0

	local lastHtml, err, html, name, community = ''
	for href, code in string.gmatch(navBar, enum.htmlChunk.navigation_bar_sections) do
		href, err = parseUrlData(href)
		if not href then
			return nil, err .. " (0x2)"
		end

		counter = counter + 1
		navigation_bar[counter] = {
			location = href
		}

		local html, name = string.match(code, enum.htmlChunk.navigation_bar_sec_content)
		if html then
			navigation_bar[counter].name = name

			lastHtml = html
			if not community then
				community = string.match(html, enum.htmlChunk.community)
			end
		else
			navigation_bar[counter].name = code
		end
	end

	return navigation_bar, lastHtml, community
end

local getBigList
getBigList = function(self, pageNumber, uri, f, getTotalPages, _totalPages, inif)
	local body, head = getPage(selfuri .. "&p=" .. math.max(1, pageNumber))
	if inif then
		local out = inif(head, body)
		if out then
			return out
		end
	end

	if getTotalPages then
		_totalPages = tonumber(string.match(body, enum.htmlChunk.total_pages)) or 1
	end

	local out = {
		_pages = _totalPages
	}
	if pageNumber == 0 then
		local tmp, err
		for i = 1, _totalPages do
			tmp, err = getBigList(i, uri, f, false, _totalPages, inif)
			if err then
				return nil, err
			end
			table.add(out, tmp)
		end

		return out
	end

	f(out, body, pageNumber, _totalPages)
	return out
end

local getList
do
	local bigListF = function(list, body)
		local counter = 0
		if usesCoro then
			-- Using string.gsub would create another environment and break the API because of http requests
			local iterator = string.gmatch(body, html)
			while true do
				local result = { iterator() }
				if #result == 0 then break end
				counter = counter + 1
				list[counter] = f(table.unpack(result))
			end
		else
			string.gsub(body, html, function(...)
				counter = counter + 1
				list[counter] = f(...)
			end)
		end
	end

	getList = function(self, pageNumber, uri, f, html, inif, usesCoro)
		return getBigList(self, pageNumber, uri, bigListF, true, nil, inif)
	end
end

local redirect = function(data, err)
	if data then
		local link = string.match(data, '"redirection":"(.-)"')
		if link then
			return parseUrlData(link)
		end
	end

	return nil, err
end

local formatNickname = function(nickname)
	extensions.assertion("formatNickname", "string", 1, nickname)

	nickname = string.gsub(nickname, "%%23", '#', 1)
	nickname = string.lower(nickname)
	nickname = string.gsub(nickname, "%a", string.upper, 1)

	if not string.find(nickname, '#', -5, true) then
		nickname = nickname .. "#0000"
	end

	return nickname
end

local isValidDate = function(date)
	local day, month, year = string.match(date, "^(%d+)/(%d+)/(%d+)$")

	if not year then
		day, month = string.match(date, "^(%d+)/(%d+)$")
	end

	if not day then
		return false
	end

	local nDay, nMonth = tonumber(day), tonumber(month)
	return (nDay > 0 and nDay < 32 and nMonth > 0 and nMonth < 13), string.format("%02d/%02d" .. (year and "/%04d" or ""), nDay, nMonth, tonumber(year))
end

--[[ Functions ]]--
	--[[ Tools ]]--
--[[@
	@file Api
	@desc Performs a GET request using the connection cookies.
	@param url<string> The URL for the GET request. The forum path is not necessary.
	@returns string,nil Page HTML.
	@returns table,string Page headers or Error message.
]]
client.getPage = function(self, url)
	extensions.assertion("getPage", "string", 1, url)

	url = string.gsub(url, forumLink, '')
	return getPage(self, url)
end

--[[@
	@file Api
	@desc Gets the location of a section on the forums.
	@param forum<int,string> The forum id. An enum from @see forum. (index or value)
	@param community<string,int> The community id. An enum from @see community. (index or value)
	@param section<string,int> The section id. An enum from @see section. (index or value)
	@returns table,nil The location.
	@returns nil,string Error message.
	@struct {
		f = 0, -- The forum id.
		s = 0 -- The section id.
	}
]]
client.getLocation = function(self, forum, community, section)
	extensions.assertion("getLocation", { "number", "string" }, 1, forum)
	extensions.assertion("getLocation", { "string", "number" }, 2, community)
	extensions.assertion("getLocation", { "string", "number" }, 3, section)

	local err
	forum, err = enum._isValid(forum, "forum", "#1")
	if err then return nil, err end
	community, err = enum._isValid(community, "community", "#2", true)
	if err then return nil, err end
	section, err = enum._isValid(section, "section", "#3", true, true)
	if err then return nil, err end

	local s = enum.location[community][enum.forum(forum)][section]
	if not s then
		return nil, enum.errorString.enum_out_of_range .. " (section)"
	end

	return {
		f = forum,
		s = s
	}
end

--[[@
	@file Api
	@desc Gets the instance's account information.
	@returns string,nil The username of the account.
	@returns int,nil The account id.
	@returns int,nil the id of the account's tribe.
]]
client.getUser = function(self)
	return self.userName, self.userId, self.tribeId
end

--[[@
	@file Api
	@desc Gets the total time since the last login performed in the instace.
	@returns int Total time since the connection of the current account.
]]
client.getConnectionTime = function(self)
	if self.connectionTime >= 0 then
		return os.time() - self.connectionTime
	end
	return self.connectionTime
end

--[[@
	@file Api
	@desc Performs a POST request using the connection cookies.
	@param uri<string> The URI code for the POST request. (Function)
	@param postData?<table> The headers for the POST request.
	@param ajaxUri?<string> The ajax URI code for the POST request. (Forum)
	@param file?<string> The file (image) content. If set, self will change most of the standard headers.
	@paramstruct postData
	{
		[n]<table> A table with two strings: header name, header value.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.performAction = function(self, uri, postData, ajaxUri, file)
	extensions.assertion("performAction", "string", 1, uri)
	extensions.assertion("performAction", { "table", "nil" }, 2, postData)
	extensions.assertion("performAction", { "string", "nil" }, 3, ajaxUri)
	extensions.assertion("performAction", { "string", "nil" }, 4, file)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, uri, postData, ajaxUri, file)
end

--[[@
	@file Api
	@desc Parses the URL data.
	@param href<string> The URI and data to be parsed.
	@returns table,nil Parsed data.
	@returns nil,string Error message.
	@struct {
		uri = "", -- The URI.
		raw_data = "", -- The data as string, without the URI.
		data = { }, -- The data as index->value. ( f = 0 )
		id = "", -- The element id, if any is given
		num_id = '0', -- The number of the element id, if any is given. (Still a string)
	}
]]
parseUrlData = function(href)
	extensions.assertion("parseUrlData", "string", 1, href)

	return parseUrlData
end

--[[@
	@file Api
	@desc Checks whether the instance is supposed to be connected to an account or not.
	@desc Note that self function does not perform any request to confirm the existence of the connection and is fully based on @see connect and @see disconnect.
	@desc See @see isConnectionAlive to confirm that the connection is still active.
	@returns boolean Whether there's already a connection or not.
]]
client.isConnected = function(self)
	return self.isConnected
end

--[[@
	@file Api
	@desc Checks whether the instance connection is alive or not.
	@desc /!\ Calling self function several times uninterruptedly may disconnect the account unexpectedly due to the forum delay.
	@desc See @see isConnected to check whether the connection should exist or not.
	@returns boolean Whether the connection is alive or not.
]]
client.isConnectionAlive = function(self)
	if not self.isConnected then
		return false
	end

	local body = getPage(selfenum.forumUri.conversations)
	return not (string.find(body, enum.htmlChunk.error_503) or string.find(body, enum.htmlChunk.not_connected))
end

--[[@
	@file Api
	@desc Formats a nickname.
	@param nickname<string> The nickname.
	@returns string Formated nickname.
]]
client.formatNickname = function(nickname)
	extensions.assertion("formatNickname", "string", 1, nickname)

	return formatNickname(nickname)
end

--[[@
	@file Api
	@desc Extracts the data of a nickname. (Name, Discriminator)
	@param nickname<string> The nickname.
	@returns table The nickname data.
	@struct {
		discriminator = "", -- The nickname's discriminator.
		fullname = "", -- The full nickname. (Name and Discriminator)
		name = "" -- The nickname without the discriminator.
	}
]]
client.extractNicknameData = function(nickname)
	extensions.assertion("extractNicknameData", "string", 1, nickname)

	nickname = formatNickname(nickname)

	local name = string.match(nickname, "%P+")
	local discriminator = string.match(nickname, "#(%d+)$")

	return {
		discriminator = discriminator,
		fullname = nickname,
		name = name
	}
end

--[[@
	@file Api
	@desc Checks whether an account was validated by an e-mail code or not.
	@returns boolean Whether the account is validated or not.
]]
client.isAccountValidated = function(self)
	return self.hasCertificate
end

	--[[ Settings ]]--
--[[@
	@file Settings
	@desc Connects to an account on Atelier801's forums.
	@param userName<string> Account's username.
	@param userPassword<string> Account's password.
	@returns boolean,nil Whether the connection succeeded or not.
	@returns nil,string Error message.
]]
client.connect = function(self, userName, userPassword)
	extensions.assertion("connect", "string", 1, userName)
	extensions.assertion("connect", "string", 2, userPassword)

	if self.isConnected then
		return nil, enum.errorString.already_connected
	end

	userName = formatNickname(userName)

	local result, err = performAction(self, enum.forumUri.identification, {
		{ "rester_connecte", "on" },
		{ "id", userName },
		{ "pass", encode.getPasswordHash(userPassword) },
		{ "redirect", string.sub(forumLink, 1, -2) }
	}, enum.forumUri.login)
	if not result then
		return nil, err .. " (0x1)"
	end

	if string.sub(result, 2, 15) == '"supprime":"*"' then
		self.isConnected = true
		self.userName = userName
		local pr, err = self.getProfile(self)
		if not pr then
			self.isConnected = false
			self.userName = nil
			return nil, err .. " (0x2)"
		end
		self.cookieState = enum.cookieState.after_login
		self.userId = pr.id
		self.tribeId = pr.tribeId
		self.connectionTime = os.time()
		return true, result
	end
	return false, result
end

--[[@
	@file Settings
	@desc Disconnects from an account on Atelier801's forums.
	@returns boolean,nil Whether the account was disconnected or not.
	@returns nil,string Error message.
]]
client.disconnect = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.disconnection, nil, enum.forumUri.acc)
	if not result then
		return nil, err
	end

	if string.sub(result, 2, 15) == '"supprime":"*"' then
		self.isConnected = false
		return true, result
	end
	return false, result
end

--[[@
	@file Settings
	@desc Sends a validation code to the account's e-mail.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.requestValidationCode = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.get_cert, nil, enum.forumUri.acc)
end

--[[@
	@file Settings
	@desc Submits the validation code to the forum to be validated.
	@param code<string> The validation code.
	@returns boolean,nil Whether the validation code is valid or not.
	@returns string Result string or Error message.
]]
client.submitValidationCode = function(self, code)
	extensions.assertion("submitValidationCode", "string", 1, code)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.set_cert, {
		{ "code", code }
	}, enum.forumUri.acc)
	if not result then
		return nil, err
	end

	self.hasCertificate = (result == "{}") -- An empty table is returned when it succeed

	return self.hasCertificate, result
end

--[[@
	@file Settings
	@desc Sets the new account's e-mail.
	@param email<string> The e-mail to be linked to the account.
	@param registration?<boolean> Whether self is the first e-mail assigned to the account or not. @default false
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.setEmail = function(self, email, registration)
	extensions.assertion("setEmail", "string", 1, email)
	extensions.assertion("setEmail", { "boolean", "nil" }, 2, registration)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not registration then
		if not self.hasCertificate then
			return nil, enum.errorString.not_verified
		end
	end

	return performAction(self, enum.forumUri.set_email, {
		{ "mail", email }
	}, enum.forumUri.acc)
end

--[[@
	@file Settings
	@desc Sets the new account's password.
	@param password<string> The new password.
	@param disconnect?<boolean> Whether the account should be disconnect from all the dispositives or not. @default false
	@returns boolean,nil Result string.
	@returns nil,string Error message.
]]
client.setPassword = function(self, password, disconnect)
	extensions.assertion("setPassword", "string", 1, password)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.hasCertificate then
		return nil, enum.errorString.not_verified
	end

	local postData = {
		{ "mdp3", encode.getPasswordHash(password) }
	}
	if disconnect then
		postData[2] = { "deco", "on" }
	end

	return performAction(self, enum.forumUri.set_pw, postData, enum.forumUri.acc)
end

	--[[ Profile ]]--
--[[@
	@file Profile
	@desc Gets the profile data of an user.
	@param userName?<string,int> User name or user id. @default Account's username
	@returns table,nil The profile data.
	@returns nil,string Error message.
	@struct {
		avatarUrl = "", -- The profile picture url.
		birthday = "", -- The birthday string field.
		community = enum.community, -- The community of the user.
		gender = enum.gender, -- The gender of the user.
		highestRole = enum.role, -- The highest role of the account based on the discriminator number.
		id = 0, -- The user id.
		level = 0, -- The level of the user on forums.
		location = "", -- The location string field.
		name = "", -- The name of the user.
		presentation = "", -- The presentation string field (HTML).
		registrationDate = "", -- The registration date string field.
		soulmate = "", -- The username of the account's soulmate.
		title = enum.forumTitle, -- The current forum title of the account based on the level.
		totalMessages = 0, -- The quantity of messages sent by the user.
		totalPrestige = 0, -- The quantity of prestige (likes) obtained by the user.
		tribe = "", -- The name of the account's tribe.
		tribeId = 0 -- The id of the account's tribe.
	}
]]
client.getProfile = function(self, userName)
	extensions.assertion("getProfile", { "string", "number", "nil" }, 1, userName)

	if not self.isConnected then
		if not userName then
			return nil, enum.errorString.not_connected
		end
	end

	userName = userName or self.userName
	local body = getPage(self, enum.forumUri.profile .. "?pr=" .. extensions.encodeUrl(userName))

	local avatar, id = string.match(body, enum.htmlChunk.profile_avatar)
	id = tonumber(id)
	if not id then
		id = tonumber(string.match(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.element_id)))
		if not id then
			return nil, enum.errorString.invalid_user
		end
	end

	local name, hashtag, discriminator = string.match(body, enum.htmlChunk.nickname)
	if not discriminator then
		return nil, enum.errorString.internal .. " (0x1)"
	end

	local highestRole = tonumber(discriminator)
	if not enum.role(highestRole) then
		highestRole = nil
	end

	local registrationDate, community, messages, prestige, level = string.match(body, enum.htmlChunk.date .. ".-" .. enum.htmlChunk.community .. ".-" .. enum.htmlChunk.profile_data)
	level = tonumber(level)
	if not level then
		return nil, enum.errorString.internal .. " (0x2)"
	end

	local gender = string.match(body, enum.htmlChunk.profile_gender)
	gender = gender and string.lower(gender) or "none"

	local location = string.match(body, enum.htmlChunk.profile_location)

	local birthday = string.match(body, enum.htmlChunk.profile_birthday .. enum.htmlChunk.date)

	local presentation = string.match(body, enum.htmlChunk.profile_presentation)

	local soulmate, soulmateDiscriminator = string.match(body, enum.htmlChunk.profile_soulmate .. enum.htmlChunk.nickname)
	if soulmate then
		soulmate = soulmate .. soulmateDiscriminator
	end

	local tribeName, tribeId = string.match(body, enum.htmlChunk.profile_tribe)

	return {
		avatarUrl = avatar,
		birthday = birthday,
		community = enum.community[community],
		gender = enum.gender[gender],
		highestRole = highestRole,
		id = tonumber(id),
		level = level,
		location = location,
		name = name .. hashtag,
		presentation = presentation,
		registrationDate = registrationDate,
		soulmate = soulmate,
		title = enum.forumTitle[level],
		totalMessages = tonumber(messages),
		totalPrestige = tonumber(prestige),
		tribe = tribeName,
		tribeId = tonumber(tribeId)
	}
end

--[[@
	@file Profile
	@desc Changes the profile picture of the account.
	@param image<string> The new image. An URL or file name.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.changeAvatar = function(self, image)
	extensions.assertion("changeAvatar", "string", 1, image)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local extension = fileManager.getExtension(image)
	if not extension then
		return nil, enum.errorString.invalid_extension
	end

	image = fileManager.getFile(image)
	if not image then
		return nil, enum.errorString.invalid_file
	end

	local file = fileManager.buildFileContent("pr", self.userId, extension, image)
	return performAction(self, enum.forumUri.update_avatar, nil, enum.forumUri.profile .. "?pr=" .. self.userId, table.concat(file, enum.separator.file))
end

--[[@
	@file Profile
	@desc Updates the account's profile.
	@param data?<table> The data.
	@paramstruct data {
		community?<string,int> User's community. An enum from @see community. (index or value) @default xx
		birthday?<string> The birthday string field. (dd/mm/yyyy)
		location?<string> The location string field.
		gender?<string,int> User's gender. An enum from @see gender. (index or value)
		presentation?<string> Profile's presentation string field.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateProfile = function(self, data)
	extensions.assertion("updateProfile", { "table", "nil" }, 1, data)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local postData = {
		{ "pr", self.userId }
	}

	if data then
		local err
		if data.community then
			data.community, err = enum._isValid(data.community, "community", "data.community")
			if err then return nil, err end
			postData[#postData + 1] = { "communaute", data.community }
		else
			postData[#postData + 1] = { "communaute", enum.community.xx }
		end
		if data.birthday then
			if not isValidDate(data.birthday) then
				return nil, enum.errorString.invalid_date .. " (data.birthday)"
			end
			postData[#postData + 1] = { "b_anniversaire", "on" }
			postData[#postData + 1] = { "anniversaire", data.birthday }
		end
		if data.location then
			postData[#postData + 1] = { "b_localisation", "on" }
			postData[#postData + 1] = { "localisation", data.location }
		end
		if data.gender then
			data.gender, err = enum._isValid(data.gender, "gender", "data.gender")
			if err then return nil, err end
			postData[#postData + 1] = { "b_genre", "on" }
			postData[#postData + 1] = { "genre", data.gender }
		end
		if data.presentation then
			postData[#postData + 1] = { "b_presentation", "on" }
			postData[#postData + 1] = { "presentation", data.presentation }
		end
	end

	return performAction(self, enum.forumUri.update_profile, postData, enum.forumUri.profile .. "?pr=" .. self.userId)
end

--[[@
	@file Profile
	@desc Removes the profile picture of the account.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.removeAvatar = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.remove_avatar, {
		{ "pr", self.userId }
	}, enum.forumUri.profile .. "?pr=" .. self.userId)
end

--[[@
	@file Profile
	@desc Updates the account profile parameters.
	@param parameters?<table> The parameters.
	@paramstruct parameters {
		online?<boolean> Whether the account should display if it's online or not. @default false
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateParameters = function(self, parameters)
	extensions.assertion("updateParameters", { "table", "nil" }, 1, parameters)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local postData = {
		{ "pr", self.userId }
	}
	if parameters and type(parameters.online) == "boolean" and parameters.online then
		postData[#postData + 1] = { "afficher_en_ligne", "on" }
	end

	return performAction(self, enum.forumUri.update_parameters, postData, enum.forumUri.profile .. "?pr=" .. self.userId)
end

	--[[ Conversations ]]--
--[[@
	@file Inbox
	@desc Gets the data of a conversation (private message).
	@param location<table> The conversation location.
	@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. If the conversation is a poll, it will ignore the poll data if `true`. @default false
	@paramstruct location {
		co<int> The conversation id.
	}
	@returns table,nil The conversation data.
	@returns nil,string Message error.
	@struct {
		co = 0, -- The conversation id.
		firstMessage = getMessage, -- The message object of the first message of the conversation. (It's ignored when 'isPoll')
		invitedUsers = {
			[userName] = "", -- Situation string field. (e.g: invited, gone, author)
		}, -- The list of players that are listed in the conversation.
		isDiscussion = false, -- If the conversation is a discussion.
		isLocked = false, -- Whether the conversation is locked or not.
		isPoll = false, -- If the conversation is a poll.
		isPrivateMessage = false, -- If the conversation is a private message.
		pages = 0, -- The total of pages in the conversation.
		poll = getPoll, -- The poll object if 'isPoll'.
		title = "", -- The conversation title.
		totalMessages = 0 -- The total of messages in the conversation.
	}
]]
client.getConversation = function(self, location, ignoreFirstMessage)
	extensions.assertion("getConversation", "table", 1, location)
	extensions.assertion("getConversation", { "boolean", "nil" }, 2, ignoreFirstMessage)

	if not location.co then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'co'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local path = "?co=" .. location.co
	local body = getPage(self, enum.forumUri.conversation .. path)

	local title = string.match(body, enum.htmlChunk.title)
	if not title then
		return nil, enum.errorString.internal .. " (0x1)"
	end

	local isDiscussion, isPrivateMessage = false, false
	local titleIcon = string.match(body, enum.htmlChunk.conversation_icon)
	if not titleIcon then
		return nil, enum.errorString.internal .. " (0x2)"
	end

	local err
	local isPoll, poll = not not string.find(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.poll_id)) -- Whether it's a poll or not
	if isPoll and not ignoreFirstMessage then
		poll, err = self.getPoll(self, location)
		if not poll then
			return nil, err .. " (0x3)"
		end
	end

	if not isPoll then
		isDiscussion = not not string.find(titleIcon, enum.topicIcon.private_discussion)
		isPrivateMessage = not isDiscussion
	end

	local invitedUsers
	if not isPrivateMessage then
		invitedUsers = { }
		local invList = string.match(body, enum.htmlChunk.conversation_members)

		local foundSelf = false
		for situation, name, discriminator in string.gmatch(invList, enum.htmlChunk.conversation_member_state .. ".-" .. enum.htmlChunk.nickname) do
			name = name .. discriminator

			invitedUsers[name] = enum.memberState(situation) or ("@" .. situation)

			if not foundSelf then
				foundSelf = name == self.userName
			end
		end
		if not foundSelf then
			invitedUsers[self.userName] = enum.memberState.invited
		end
	end

	local isLocked = false
	if not isPrivateMessage then
		isLocked = not not string.find(titleIcon, enum.topicIcon.locked)
	end

	-- Get total of pages and total of messages
	local totalPages = tonumber(string.match(body, enum.htmlChunk.total_pages)) or 1

	local counter = 0
	local lastPage = getPage(self, enum.forumUri.conversation .. path .. "&p=" .. totalPages)
	for _ in string.gmatch(lastPage, enum.htmlChunk.post) do
		counter = counter + 1
	end

	local totalMessages = ((totalPages - 1) * 20) + counter

	local firstMessage
	if not ignoreFirstMessage then
		if not isPoll then
			firstMessage, err = self.getMessage(self, '1', location)
			if not firstMessage then
				return nil, err .. " (0x4)"
			end
		end
	end

	return {
		co = location.co,
		firstMessage = firstMessage,
		invitedUsers = invitedUsers,
		isDiscussion = isDiscussion,
		isLocked = isLocked,
		isPoll = isPoll,
		isPrivateMessage = isPrivateMessage,
 		pages = totalPages,
		poll = poll,
		title = title,
		totalMessages = totalMessages
	}
end

--[[@
	@file Inbox
	@desc Creates a new private message.
	@param destinatary<string> The user who is going to receive the private message.
	@param subject<string> The subject of the private message.
	@param message<string> The message content of the private message.
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.createPrivateMessage = function(self, destinatary, subject, message)
	extensions.assertion("createPrivateMessage", "string", 1, destinatary)
	extensions.assertion("createPrivateMessage", "string", 2, subject)
	extensions.assertion("createPrivateMessage", "string", 3, message)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.create_dialog, {
		{ "destinataire", destinatary },
		{ "objet", subject },
		{ "message", message }
	}, enum.forumUri.new_dialog)
	return redirect(result, err)
end

--[[@
	@file Inbox
	@desc Creates a new private discussion.
	@param destinataries<table> The users who are going to be invited to the private discussion.
	@param subject<string> The subject of the private discussion.
	@param message<string> The message content of the private discussion.
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.createPrivateDiscussion = function(self, destinataries, subject, message)
	extensions.assertion("createPrivateDiscussion", "table", 1, destinataries)
	extensions.assertion("createPrivateDiscussion", "string", 2, subject)
	extensions.assertion("createPrivateDiscussion", "string", 3, message)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.create_discussion, {
		{ "destinataires", table.concat(destinataries, enum.separator.forum_data) },
		{ "objet", subject },
		{ "message", message }
	}, enum.forumUri.new_discussion)
	return redirect(result, err)
end

--[[@
	@file Inbox
	@desc Creates a new private poll.
	@param destinataries<table> The users who are going to be invited to the private poll.
	@param subject<string> The subject of the private poll.
	@param message<string> The message content of the private poll.
	@param pollResponses<table> The poll response options.
	@param settings?<table> The poll settings.
	@paramstruct settings {
		multiple?<boolean> If users are allowed to select more than one option.
		public?<boolean> If users can see the results of the poll.
	}
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.createPrivatePoll = function(self, destinataries, subject, message, pollResponses, settings)
	extensions.assertion("createPrivatePoll", "table", 1, destinataries)
	extensions.assertion("createPrivatePoll", "string", 2, subject)
	extensions.assertion("createPrivatePoll", "string", 3, message)
	extensions.assertion("createPrivatePoll", "table", 4, pollResponses)
	extensions.assertion("createPrivatePoll", { "table", "nil" }, 5, settings)

	if #pollResponses < 2 then
		return nil, enum.errorString.no_poll_responses
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local postData = {
		{ "destinataires", table.concat(destinataries, enum.separator.forum_data) },
		{ "objet", subject },
		{ "message", message },
		{ "sondage", "on" },
		{ "reponses", table.concat(pollResponses, enum.separator.forum_data) }
	}
	if settings then
		if settings.multiple then
			postData[#postData + 1] = { "multiple", "on" }
		end
		if settings.public then
			postData[#postData + 1] = { "publique", "on" }
		end
	end

	local result, err = performAction(self, enum.forumUri.create_discussion, postData, enum.forumUri.new_private_poll)
	return redirect(result, err)
end

--[[@
	@file Inbox
	@desc Answers a conversation.
	@param conversationId<int,string> The conversation id.
	@param answer<string> The answer message content.
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.answerConversation = function(self, conversationId, answer)
	extensions.assertion("answerConversation", { "number", "string" }, 1, conversationId)
	extensions.assertion("answerConversation", "string", 2, answer)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.answer_conversation, {
		{ "co", conversationId },
		{ "message_reponse", answer }
	}, enum.forumUri.conversation .. "?co=" .. conversationId)
	return redirect(result, err)
end

--[[@
	@file Inbox
	@desc Moves private conversations to the inbox or bin.
	@param inboxLocale<string,int> Where the conversation will be located. An enum from @see inboxLocale. (index or value)
	@param conversationId?<int,table> The id(s) of the conversation(s) to be moved. Use `nil` for all.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.moveConversation = function(self, inboxLocale, conversationId)
	conversationId = tonumber(conversationId) or conversationId
	extensions.assertion("movePrivateConversation", { "string", "number" }, 1, inboxLocale)

	local err
	inboxLocale, err = enum._isValid(inboxLocale, "inboxLocale", "#1")
	if err then return nil, err end

	local moveAll = false
	if inboxLocale == enum.inboxLocale.bin and not conversationId then
		conversationId = { }
		moveAll = true
	end

	extensions.assertion("movePrivateConversation", { "number", "table" }, 2, conversationId)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if type(conversationId) == "number" then
		conversationId = { conversationId }
	end

	return performAction(self, (moveAll and enum.forumUri.move_all_conversations or enum.forumUri.move_conversation), (not moveAll and {
		{ "conversations", table.concat(conversationId, enum.separator.forum_data) },
		{ "location", inboxLocale }
	} or nil), enum.forumUri.conversations .. "?location=" .. inboxLocale)
end

--[[@
	@file Inbox
	@desc Changes the conversation state (open, closed).
	@param displayState<string,int> The conversation display state. An enum from @see displayState. (index or value)
	@param conversationId<int,string> The conversation id.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.changeConversationState = function(self, displayState, conversationId)
	extensions.assertion("changeConversationState", { "string", "number" }, 1, displayState)
	extensions.assertion("changeConversationState", { "number", "string" }, 2, conversationId)

	local err
	displayState, err = enum._isValid(displayState, "displayState", "#1", nil, true)
	if err then return nil, err end

	if displayState == enum.contentState.deleted then
		return nil, enum.errorString.unaivalable_enum
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, (displayState == enum.displayState.active and enum.forumUri.reopen_discussion or enum.forumUri.close_discussion), {
		{ "co", conversationId }
	}, enum.forumUri.conversation .. "?co=" .. conversationId)
end

--[[@
	@file Inbox
	@desc Leaves a private conversation.
	@param conversationId<int,string> The conversation id.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.leaveConversation = function(self, conversationId)
	extensions.assertion("leaveConversation", { "number", "string" }, 1, conversationId)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.leave_discussion, {
		{ "co", conversationId }
	}, enum.forumUri.conversation .. "?co=" .. conversationId)
end

--[[@
	@file Inbox
	@desc Invites an user to a private conversation.
	@param conversationId<int,string> The conversation id.
	@param userName<string> The name of the user to be invited.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.conversationInvite = function(self, conversationId, userName)
	extensions.assertion("conversationInvite", { "number", "string" }, 1, conversationId)
	extensions.assertion("conversationInvite", "string", 2, userName)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.invite_discussion, {
		{ "co", conversationId },
		{ "destinataires", userName }
	}, enum.forumUri.conversation .. "?co=" .. conversationId)
end

--[[@
	@file Inbox
	@desc Removes a user from a conversation.
	@param conversationId<int,string> The conversation id.
	@param userId<int,string> User name or user id.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.kickConversationMember = function(self, conversationId, userId)
	extensions.assertion("kickConversationMember", { "number", "string" }, 1, conversationId)
	extensions.assertion("kickConversationMember", { "number", "string" }, 1, userId)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if type(userId) == "string" then
		local err
		userId, err = self.getProfile(userId)
		if err then
			return nil, err
		end
		userId = userId.id
	end

	return performAction(self, enum.forumUri.kick_member, {
		{ "co", conversationId },
		{ "pr", userId }
	}, enum.forumUri.conversation .. "?co=" .. conversationId)
end

	--[[ Forum ]]--
--[[@
	@file Forum
	@desc Gets the data of a message.
	@param postId<int,string> The post id. (note: not the message id, but the #mID)
	@param location<table> The post topic or conversation location.
	@paramstruct location {
		f<int> The forum id. (needed for forum message)
		t<int> The topic id. (needed for forum message)
		co<int> The private conversation id. (needed for private conversation message)
	}
	@returns table,nil The message data.
	@returns nil,string Error message.
	@struct {
		author = "", -- The user name of the message author.
		canLike = true, -- Whether the message can be liked or not. (forum message only)
		co = 0, -- The conversation id. (private message only)
		content = "", -- The message content.
		contentHtml = "", -- The HTML of the message content.
		editionTimestamp = 0, -- The timestamp of the last edition. (forum message only)
		f = 0, -- The forum id.
		id = 0, -- The message id.
		isEdited = false, -- Whether the message was edited or not. (forum message only)
		isModerated = false, -- Whether the message is moderated or not. (forum message only)
		moderatedBy = "", -- The name of the sentinel that moderated the message. (forum message only)
		p = 0, -- The page where the message is located.
		post = "", -- The post id.
		prestige = 0, -- The quantity of prestiges that the message has. (forum message only)
		reason = "", -- The moderation reason. (forum message only)
		t = 0, -- The topic id. (forum message only)
		timestamp = 0 -- The timestamp of when the message was created.
	}
]]
client.getMessage = function(self, postId, location)
	extensions.assertion("getMessage", { "number", "string" }, 1, postId)
	extensions.assertion("getMessage", "table", 2, location)

	local pageNumber = math.ceil(tonumber(postId) / 20)

	local body = getPage(self, (location.co and (enum.forumUri.conversation .. "?co=" .. location.co) or (enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)) .. "&p=" .. pageNumber)

	local id, post
	if not location.co then
		-- Forum message
		id, post = string.match(body, string.format(enum.htmlChunk.message, postId))
		if not id then
			return nil, enum.errorString.internal .. " (0x1)"
		end

		local isModerated, moderatedBy, reason = false
		local timestamp, author, authorDiscriminator, _, prestige, contentHtml = string.match(post, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.nickname .. ".-" .. enum.htmlChunk.message_data)
		if not timestamp then
			timestamp, author, authorDiscriminator, _, moderatedBy, reason = string.match(post, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.nickname .. ".-" .. enum.htmlChunk.moderated_message)
			if not timestamp then
				return nil, enum.errorString.internal .. " (0x2)"
			end
			isModerated = true
		end

		local editTimestamp = string.match(post, enum.htmlChunk.edition_timestamp)

		local content = string.match(body, string.format(enum.htmlChunk.message_content, enum.forumUri.edit, id))

		local canLike = not not string.find(post, string.format(enum.htmlChunk.hidden_value, 'm'))

		return {
			author = author .. authorDiscriminator,
			canLike = canLike,
			content = content,
			contentHtml = contentHtml,
			editionTimestamp = tonumber(editTimestamp),
			f = location.f,
			id = tonumber(id),
			isEdited = not not editTimestamp,
			isModerated = isModerated,
			moderatedBy = moderatedBy,
			p = pageNumber,
			post = postId,
			prestige = tonumber(prestige),
			reason = reason,
			t = location.t,
			timestamp = tonumber(timestamp)
		}
	else
		-- Private message
		post = string.match(body, string.format(enum.htmlChunk.private_message, postId))
		if not post then
			return nil, enum.errorString.internal .. " (0x3)"
		end

		local timestamp, author, authorDiscriminator, _, id, contentHtml = string.match(post, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.nickname .. ".-" .. enum.htmlChunk.private_message_data)
		if not timestamp then
			return nil, enum.errorString.internal .. " (0x4)"
		end

		local content = string.match(body, string.format(enum.htmlChunk.message_content, enum.forumUri.quote, id))

		return {
			author = author .. authorDiscriminator,
			co = location.co,
			content = content,
			contentHtml = contentHtml,
			f = 0,
			id = tonumber(id),
			post = tostring(postId),
			timestamp = tonumber(timestamp),
 			p = pageNumber
		}
	end
end

--[[@
	@file Forum
	@desc Gets the data of a topic.
	@param location<table> The topic location.
	@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. If the topic is a poll, it will ignore the poll data if `true`. @default false
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns table,nil The topic data.
	@returns nil,string Error message.
	@struct {
		community = enum.community, -- The community where the topic is located.
		elementId = 0, -- The element id of the topic.
		f = 0, -- The forum id.
		favoriteId = 0, -- The favorite id of the topic, if 'isFavorited'.
		firstMessage = getMessage, -- The message object of the first message of the topic. (It's ignored when 'isPoll')
		isDeleted = false, -- Whether the topic is deleted or not.
		isFavorited = false, -- Whether the topic is favorited or not.
		isFixed = false, -- Whether the topic is fixed in the section or not.
		isLocked = false, -- Whether the topic is locked or not.
		isPoll = false, -- If the conversation is a poll.
		navbar = {
			[n] = {
				location = parseUrlData, -- The parsed-url location object.
				name = "" -- The name of the location.
			}
		}, -- A list of locations of the navigation bar.
		pages = 0, -- The quantity of pages in the topic.
		poll = getPoll, -- The poll object if 'isPoll'.
		t = 0, -- The topic id.
		title = "", -- The name of the topic.
		totalMessages = 0 -- The total of messages in the topic.
	}
]]
client.getTopic = function(self, location, ignoreFirstMessage)
	extensions.assertion("getTopic", "table", 1, location)
	extensions.assertion("getTopic", { "boolean", "nil" }, 2, ignoreFirstMessage)

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	local path = "?f=" .. location.f .. "&t=" .. location.t
	local body = getPage(self, enum.forumUri.topic .. path)

	local isPoll, poll = not not string.find(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.poll_id)) -- Whether it's a poll or not
	if isPoll and not ignoreFirstMessage then
		poll, err = self.getPoll(self, location)
		if not poll then
			return nil, err .. " (0x1)"
		end
	end

	local firstMessage
	if not ignoreFirstMessage then
		if not isPoll then
			firstMessage, err = self.getMessage(self, '1', location)
			if not firstMessage then
				return nil, err .. " (0x2)"
			end
		end
	end

	local navigation_bar, lastHtml, community = getNavbar(body)
	if not navigation_bar then
		return nil, lastHtml .. " (0x3)"
	end

	local isFixed = not not string.find(lastHtml, enum.topicIcon.postit)
	local isLocked = not not string.find(lastHtml, enum.topicIcon.locked)
	local isDeleted = not not string.find(lastHtml, enum.topicIcon.deleted)

	local ie = tonumber(string.match(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.element_id))) -- Element id
	local fa = tonumber(string.match(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.favorite_id)))

	-- Get total of pages and total of messages
	local totalPages = tonumber(string.match(body, enum.htmlChunk.total_pages)) or 1

	local counter = 0
	local lastPage = getPage(self, enum.forumUri.topic .. path .. "&p=" .. totalPages)
	string.gsub(lastPage, enum.htmlChunk.post, function()
		counter = counter + 1
	end)

	local totalMessages = ((totalPages - 1) * 20) + counter

	return {
		community = (community and enum.community[community] or nil),
		elementId = ie,
		f = location.f,
		favoriteId = fa,
		firstMessage = firstMessage,
		isDeleted = isDeleted,
		isFavorited = not not fa,
		isFixed = isFixed,
		isLocked = isLocked,
		isPoll = isPoll,
		navbar = navigation_bar,
		pages = totalPages,
		poll = poll,
		t = location.t,
		title = navigation_bar[#navigation_bar].name,
		totalMessages = totalMessages
	}
end

--[[@
	@file Forum
	@desc Gets the data of a poll.
	@param location<table> The poll location.
	@paramstruct location {
		f<int> The forum id. (needed for forum topic)
		t<int> The topic id. (needed for forum topic)
		co<int> The private conversation id. (needed for private conversation)
	}
	@returns table,nil The poll data.
	@returns nil,string Error message.
	@struct {
		allowsMultiple = false, -- Whether the poll allows multiple selections or not.
		author = "", -- The user name of the poll author.
		co = 0, -- The conversation id. (private poll only)
		contentHtml = "", -- The HTML of the poll content.
		f = 0, -- The forum id.
		id = 0, -- The poll id.
		isPublic = 0, -- Whether the users are allowed to see the results of the poll.
		options = {
			[n] = {
				id = 0, -- The id of the option.
				value = "", -- The option string field.
				votes = 0, -- The total of votes for the option. (-1 if it can't be calculated)
			}
		}, -- The poll options.
		t = 0, -- The topic id. (forum poll only)
		timestamp = 0, -- The timestamp of when the poll was created.
		totalVotes = 0 -- The total of votes in the poll. (-1 if it can't be calculated)
	}
]]
client.getPoll = function(self, location)
	extensions.assertion("getPoll", "table", 1, location)

	local isPrivatePoll = not not location.co
	if not isPrivatePoll and (not location.f or not location.t) then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'") .. " " .. enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_url_location_private, "'co'")
	end

	local body = getPage(self, (isPrivatePoll and (enum.forumUri.conversation .. "?co=" .. location.co) or (enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))

	local timestamp, nickname, discriminator, _, id, contentHtml = string.match(body, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.nickname .. ".-" .. string.format(enum.htmlChunk.hidden_value, enum.forumUri.poll_id) .. ".-" .. enum.htmlChunk.poll_content)
	if not timestamp then
		return nil, enum.errorString.internal
	end

	local options = { }
	local multiple = false
	local totalVotes = -1

	local counter = 0
	for t, id, value in string.gmatch(body, enum.htmlChunk.poll_option) do
		if not multiple and t == "checkbox" then
			multiple = true
		end

		counter = counter + 1
		options[counter] = {
			id = tonumber(id),
			value = value,
			votes = -1
		}
	end
	if counter > 0 then
		-- Gets the percentage, if there's any
		local counter = 0
		local votes = 0
		for number in string.gmatch(body, enum.htmlChunk.poll_percentage) do
			number = tonumber(number)
			counter = counter + 1
			votes = votes + number
			options[counter].votes = number
		end
		totalVotes = votes
	else
		return nil, enum.errorString.not_poll
	end

	return {
		allowsMultiple = multiple,
		author = nickname .. discriminator,
		co = location.co,
		contentHtml = contentHtml,
		f = location.f or 0,
		id = tonumber(id),
		isPublic = totalVotes > 0,
		options = options,
		t = location.t,
		timestamp = tonumber(timestamp),
		totalVotes = totalVotes
	}
end

--[[@
	@file Forum
	@desc Gets the data of a section.
	@param location<table> The section location.
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns table,nil The section data.
	@returns nil,string Error message.
	@struct {
		community = enum.community, -- The community where the section is located.
		f = 0, -- The forum id.
		hasSubsections = false, -- Whether the section has subsections or not.
		icon = enum.sectionIcon, -- The icon of the section.
		isSubsection = false, -- Whether the section is a subsection or not.
		name = "", -- The name of the section.
		navbar = {
			[n] = {
				location = parseUrlData, -- The parsed-url location object.
				name = "" -- The name of the location.
			}
		}, -- A list of locations of the navigation bar.
		pages = 0, -- The quantity of pages in the section.
		parent = {
			location = parseUrlData, -- The parsed-url location object.
			name = "" -- The name of the parent section.
		}, -- The parent section of the subsection
		s = 0, -- The section id.
		subsections = {
			[n] = {
				location = parseUrlData, -- The parsed-url location object.
				name = "" -- The name of the subsection.
			}
		}, -- A list of subsections of the section.
		totalFixedTopics = 0, -- Total of topics that are fixed in the section.
		totalSubsections = 0, -- Total of subsections in the section.
		totalTopics = 0 -- Total of topics in the section.
	}
]]
client.getSection = function(self, location)
	extensions.assertion("getSection", "table", 1, location)

	if not location.f or not location.s then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	local path = "?f=" .. location.f .. "&s=" .. location.s
	local body = getPage(self, enum.forumUri.section .. path)

	local navigation_bar, lastHtml, community = getNavbar(body)
	if not navigation_bar then
		return nil, lastHtml .. " (0x1)"
	end
	if not lastHtml then
		return nil, enum.errorString.internal .. " (0x2)"
	end

	local icon = string.match(lastHtml, enum.htmlChunk.section_icon)
	icon = enum.sectionIcon(icon)
	if not icon then
		return nil, enum.errorString.internal .. " (0x3)"
	end

	local totalPages = tonumber(string.match(body, enum.htmlChunk.total_pages)) or 1
	local lastPage = getPage(self, enum.forumUri.section .. path .. "&p=" .. totalPages)

	local counter = 0
	local subsections, totalSubsections, err = { }, 0
	for href, name in string.gmatch(lastPage, enum.htmlChunk.subsection) do
		counter = counter + 1
		href, err = parseUrlData(href)
		if err then
			return nil, err .. " (0x4)"
		end

		subsections[counter] = {
			location = href,
			name = name
		}
	end
	if counter == 0 then
		subsections = nil
	else
		totalSubsections = counter
	end
	local isSubsection = #navigation_bar > 3

	counter = 0
	local totalTopics
	if string.find(lastPage, enum.htmlChunk.empty_section) then
		totalTopics = 0
	else
		for _ in string.gmatch(lastPage, enum.htmlChunk.topic_div) do
			counter = counter + 1
		end

		totalTopics = ((totalPages - 1) * 30) + (counter - (totalSubsections and 1 or 0))
	end

	local totalFixedTopics = 0
	for _ in string.gmatch(body, enum.topicIcon.postit) do
		totalFixedTopics = totalFixedTopics + 1
	end

	return {
		community = (community and enum.community[community] or nil),
		f = location.f,
		hasSubsections = totalSubsections > 0,
		icon = icon,
		isSubsection = isSubsection,
		name = navigation_bar[#navigation_bar].name,
		navbar = navigation_bar,
		pages = totalPages,
		parent = (isSubsection and (navigation_bar[#navigation_bar - 1]) or nil),
		s = location.s,
		subsections = subsections,
		totalFixedTopics = totalFixedTopics,
		totalSubsections = totalSubsections,
		totalTopics = totalTopics
	}
end

--[[@
	@file Forum
	@desc Gets the messages of a topic or conversation.
	@desc /!\ self.function may take several minutes to return the values depending on the total of pages of the topic.
	@param location<table> The topic or conversation location.
	@param getAllInfo?<boolean> Whether the message data should be simple (see return structure) or complete (@see getMessage). @default true
	@param pageNumber?<int> The topic page. To list ALL messages, use `0`. @default 1
	@paramstruct location {
		f<int> The forum id. (needed for topic)
		t<int> The topic id. (needed for topic)
		co<int> The private conversation id. (needed for private conversation)
	}
	@returns table,nil The list of message datas.
	@returns nil,string Error Message.
	@struct {
		-- Structure if not 'getAllInfo'
		[n] = {
			co = 0, -- The private conversation id.
			f = 0, -- The forum id.
			id = 0, -- The message id.
			p = 0, -- The page where the message is located.
			post = "", -- The post id.
			t = 0, -- The topic id.
			timestamp = 0 -- The timestamp of when the message was created.
		},
		_pages = 0 -- The total pages of the topic or conversation.
	}
]]
client.getAllMessages = function(self, location, getAllInfo, pageNumber)
	extensions.assertion("getAllMessages", "table", 1, location)
	extensions.assertion("getAllMessages", { "boolean", "nil" }, 2, getAllInfo)
	extensions.assertion("getAllMessages", { "number", "nil" }, 3, pageNumber)

	getAllInfo = (getAllInfo == nil and true or getAllInfo)
	pageNumber = pageNumber or 1

	local isPrivatePoll = not not location.co
	if not isPrivatePoll and (not location.f or not location.t) then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'") .. " " .. enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_url_location_private, "'co'")
	end

	return getBigList(self, pageNumber, (isPrivatePoll and (enum.forumUri.conversation .. "?co=" .. location.co) or (enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)), function(messages, body, pageNumber, totalPages)
		local post = math.max(1, pageNumber) * 20
		local counter = 0
		if getAllInfo then
			for i = (post - 19), post do
				local msg, err = self.getMessage(self, tostring(i), location)
				if not msg then
					break -- End of the page
				end
				counter = counter + 1
				messages[counter] = msg
			end
		else
			post = (post - 20)
			for timestamp, id in string.gmatch(body, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.message_id) do
				counter = counter + 1
				messages[counter] = {
					co = location.co,
					f = location.f,
					id = tonumber(id),
					p = pageNumber,
					post = tostring(post + counter),
					t = location.t,
					timestamp = tonumber(timestamp)
				}
			end
		end
	end, true)
end

--[[@
	@file Forum
	@desc Gets the topics of a section.
	@desc /!\ self.function may take several minutes to return the values depending on the total of pages of the section.
	@param location<table> The section location.
	@param getAllInfo?<boolean> Whether the topic data should be simple (ids only) or complete (@see getTopic). @default true
	@param pageNumber?<int> The section page. To list ALL topics, use `0`. @default 1
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns table,nil The list of topic datas.
	@returns nil,string Error Message.
	@struct {
		-- Structure if not 'getAllInfo'
		[n] = {
			author = "", -- The name of the topic author, without discriminator.
			f = 0, -- The forum id.
			s = 0, -- The section id.
			t = 0, -- The topic id.
			timestamp = 0, -- The timestamp of when the topic was created.
			title = "" -- The name of the topic.
		},
		_pages = 0 -- The total pages of the section.
	}
]]
client.getSectionTopics = function(self, location, getAllInfo, pageNumber)
	extensions.assertion("getSectionTopics", "table", 1, location)
	extensions.assertion("getSectionTopics", { "boolean", "nil" }, 2, getAllInfo)
	extensions.assertion("getSectionTopics", { "number", "nil" }, 1, pageNumber)

	getAllInfo = (getAllInfo == nil and true or getAllInfo)
	pageNumber = pageNumber or 1

	if not location.f or not location.s then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	return getList(self, pageNumber, enum.forumUri.section .. "?f=" .. location.f .. "&s=" .. location.s, function(id, title, author, timestamp)
		id = tonumber(id)

		if getAllInfo then
			local tpc, err = self.getTopic(self, { f = location.f, t = id }, true)
			if not tpc then
				return nil, err
			end
			return tpc
		else
			return {
				author = author,
				f = location.f,
				s = location.s,
				t = id,
				timestamp = tonumber(timestamp),
				title = title
			}
		end
	end, enum.htmlChunk.section_topic .. ".-" .. enum.htmlChunk.sec_topic_author .. " on .-" .. enum.htmlChunk.ms_time, nil, true)
end

--[[@
	@file Forum
	@desc Creates a topic.
	@param title<string> The title of the topic
	@param message<string> The initial message content of the topic.
	@param location<table> The location where the topic should be created.
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.createTopic = function(self, title, message, location)
	extensions.assertion("createTopic", "string", 1, title)
	extensions.assertion("createTopic", "string", 2, message)
	extensions.assertion("createTopic", "table", 3, location)

	if not location.f or not location.s then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.create_topic, {
		{ 'f', location.f },
		{ 's', location.s },
		{ "titre", title },
		{ "message", message }
	}, enum.forumUri.new_topic .. "?f=" .. location.f .. "&s=" .. location.s)
	if not result then
		return nil, err
	end

	result, err = redirect(result, err)
	if result then
		result.data.s = location.s
		return result, err
	end

	return nil, err
end

--[[@
	@file Forum
	@desc Answers a topic.
	@param message<string> The answer message content.
	@param location<table> The topic location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.answerTopic = function(self, message, location)
	extensions.assertion("answerTopic", "string", 1, message)
	extensions.assertion("answerTopic", "table", 2, location)

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local result, err = performAction(self, enum.forumUri.answer_topic, {
		{ 'f', location.f },
		{ 't', location.t },
		{ "message_reponse", message }
	}, enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
	return redirect(result, err)
end

--[[@
	@file Forum
	@desc Edits the content of a message.
	@param messageId<int,string> The message id. Use `string` if it's the post number.
	@param message<string> The new message content.
	@param location<table> The message location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.editAnswer = function(self, messageId, message, location)
	extensions.assertion("editAnswer", { "number", "string" }, 1, messageId)
	extensions.assertion("editAnswer", "string", 2, message)
	extensions.assertion("editAnswer", "table", 3, location)

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if type(messageId) == "string" then
		local err
		messageId, err = self.getMessage(self, messageId, location)
		if messageId then
			messageId = messageId.id
		else
			return nil, err
		end
	end

	return performAction(self, enum.forumUri.edit_message, {
		{ 'f', location.f },
		{ 't', location.t },
		{ 'm', messageId },
		{ "message", message }
	}, enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
end

--[[@
	@file Forum
	@desc Creates a new poll.
	@param title<string> The title of the poll.
	@param message<string> The message content of the poll.
	@param pollResponses<table> The poll response options.
	@param location<table> The location where the topic should be created.
	@param settings?<table> The poll settings.
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@paramstruct settings {
		multiple?<boolean> If users are allowed to select more than one option.
		public?<boolean> If users can see the results of the poll.
	}
	@returns table,nil A parsed-url location object.
	@returns nil,string Error message.
]]
client.createPoll = function(self, title, message, pollResponses, location, settings)
	extensions.assertion("createPoll", "string", 1, title)
	extensions.assertion("createPoll", "string", 2, message)
	extensions.assertion("createPoll", "table", 3, pollResponses)
	extensions.assertion("createPoll", "table", 4, location)
	extensions.assertion("createPoll", { "table", "nil" }, 5, settings)

	if #pollResponses < 2 then
		return nil, enum.errorString.no_poll_responses
	end

	if not location.f or not location.s then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local postData = {
		{ 'f', location.f },
		{ 's', location.s },
		{ "titre", title },
		{ "message", message },
		{ "sondage", "on" },
		{ "reponses", table.concat(pollResponses, enum.separator.forum_data) }
	}
	if settings then
		if settings.multiple then
			postData[#postData + 1] = { "multiple", "on" }
		end
		if settings.public then
			postData[#postData + 1] = { "publique", "on" }
		end
	end

	local result, err = performAction(self, enum.forumUri.create_topic, postData, enum.forumUri.new_poll .. "?f=" .. location.f .. "&s=" .. location.s)
	return redirect(result, err)
end

--[[@
	@file Forum
	@desc Answers a poll.
	@param option<int,table,string> The poll option to be selected. You can insert its id (highly recommended) or its text value. For multiple options, use a table with `ints` or `strings`.
	@param location<table> The location where the poll answer should be recorded.
	@param pollId?<int> The poll id. It's obtained automatically if no value is given.
	@paramstruct location {
		f<int> The forum id. (needed for forum poll)
		t<int> The topic id. (needed for forum poll)
		co<int> The private conversation id. (needed for private poll)
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.answerPoll = function(self, option, location, pollId)
	extensions.assertion("answerPoll", { "number", "table", "string" }, 1, option)
	extensions.assertion("answerPoll", "table", 2, location)
	extensions.assertion("answerPoll", { "number", "nil" }, 3, pollId)

	local isPrivatePoll = not not location.co
	if not isPrivatePoll and (not location.f or not location.t) then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'") .. " " .. enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_url_location_private, "'co'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not pollId then
		local body = getPage(self, (isPrivatePoll and (enum.forumUri.conversation .. "?co=" .. location.co) or (enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))

		pollId = tonumber(string.match(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.poll_id)))
		if not pollId then
			return nil, enum.errorString.not_poll
		end
	end

	local optionIsString = type(option) == "string"
	if optionIsString or (type(option) == "table" and type(option[1]) == "string") then
		local options, err = self.getPoll(self, location)
		if err then
			return nil, err
		end
		options = options.options

		if optionIsString then
			local index = table.search(options, option, "value")
			if not index then
				return nil, enum.errorString.poll_option_not_found
			end
			option = options[index].id
		else
			local tmpSet = table.createSet(options, "value")
			for i = 1, #option do
				if tmpSet[option[i]] then
					option[i] = tmpSet[option[i]].id
				else
					return nil, enum.errorString.poll_option_not_found
				end
			end
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
	if type(option) == "number" then
		postData[#postData + 1] = { "reponse_", option }
	else
		local len = #postData
		for i = 1, #option do
			postData[len + i] = { ("reponse_" .. option[i]), option[i] }
		end
	end

	return performAction(self, (isPrivatePoll and enum.forumUri.answer_private_poll or enum.forumUri.answer_poll), postData, (isPrivatePoll and (enum.forumUri.conversation .. "?co=" .. location.co) or (enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))
end

--[[@
	@file Forum
	@desc Likes a message.
	@param messageId<int,string> The message id. Use `string` if it's the post number.
	@param location<table> The topic location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.likeMessage = function(self, messageId, location)
	extensions.assertion("likeMessage", { "number", "string" }, 1, messageId)
	extensions.assertion("likeMessage", "table", 2, location)

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if type(messageId) == "string" then
		local err
		messageId, err = self.getMessage(self, messageId, location)
		if messageId then
			messageId = messageId.id
		else
			return nil, err
		end
	end

	return performAction(self, enum.forumUri.like_message, {
		{ 'f', location.f },
		{ 't', location.t },
		{ 'm', messageId }
	}, enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
end

	--[[ Moderation ]]--
--[[@
	@file Moderation
	@desc Gets the edition logs of a message.
	@param messageId<int,string> The message id. Use `string` if it's the post number.
	@param location<table> The message location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns table,nil The edition logs.
	@returns nil,string Error message.
	@struct {
		[n] = {
			bbcode = "", -- The bbcode of the edited message.
			timestamp = 0 -- The timestamp of the edited message.
		}
	}
]]
client.getMessageHistory = function(self, messageId, location)
	extensions.assertion("getMessageHistory", { "number", "string" }, 1, messageId)
	extensions.assertion("getMessageHistory", "table", 2, location)

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if type(messageId) == "string" then
		local err
		messageId, err = self.getMessage(self, messageId, location)
		if messageId then
			messageId = messageId.id
		else
			return nil, err
		end
	end

	local body = getPage(self, enum.forumUri.message_history .. "?forum=" .. location.f .. "&message=" .. messageId)

	local history, counter = { }, 0
	for bbcode, timestamp in string.gmatch(body, enum.htmlChunk.message_history_log .. ".-" .. enum.htmlChunk.ms_time) do
		counter = counter + 1
		history[counter] = {
			bbcode = bbcode,
			timestamp = tonumber(timestamp)
		}
	end

	return history
end

--[[@
	@file Moderation
	@desc Updates a topic state, location, and parameters.
	@param location<table> The location where the topic is located.
	@param data?<table> The new topic data.
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
		t<int> The topic id.
	}
	@paramstruct data {
		title?<string> The new title of the topic. @default Current title
		fixed?<boolean> Whether the topic should be fixed or not. @default false
		state?<string,int> The state of the topic. An enum from 'enum.displayState'. (index or value)
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateTopic = function(self, location, data)
	extensions.assertion("updateTopic", "table", 1, location)
	extensions.assertion("updateTopic", { "table", "nil" }, 2, data)

	data = data or { }

	if not location.f or not location.s or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local topic, err = self.getTopic(self, location, true)
	if not topic then
		return nil, err
	end

	local postit = data.fixed
	if postit == nil then
		postit = topic.isFixed
	end

	if data.state then
		local err
		data.state, err = enum._isValid(data.state, "displayState", "data.state")
		if err then return nil, err end
	end

	return performAction(self, enum.forumUri.update_topic, {
		{ 'f', location.f },
		{ 't', location.t },
		{ "titre", (data.title or topic.title) },
		{ "postit", (postit and "on" or '') },
		{ "etat", (data.state or enum.displayState.active) },
		{ 's', location.s }
	}, enum.forumUri.edit_topic .. "?f=" .. location.f .. "&t=" .. location.t)
end

--[[@
	@file Moderation
	@desc Reports an element. (e.g: message, profile)
	@param element<string,int> The element type. An enum from @see element. (index or value)
	@param elementId<int,string> The element id.
	@param reason<string> The report reason.
	@param location?<table> The location of the report.
	@paramstruct location {
		f<int> The forum id. (needed for forum element)
		t<int> The topic id. (needed for forum element)
		co<int> The private conversation id. (needed for private element)
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.reportElement = function(self, element, elementId, reason, location)
	extensions.assertion("reportElement", { "string", "number" }, 1, element)
	extensions.assertion("reportElement", { "number", "string" }, 2, elementId)
	extensions.assertion("reportElement", "string", 3, reason)
	extensions.assertion("reportElement", { "table", "nil" }, 4, location)

	local err
	element, err = enum._isValid(element, "element")
	if err then return nil, err end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	location = location or { }
	local link, err
	if element == enum.element.message then
		-- Message ID
		if not location.f or not location.t then
			return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
		end
		if type(elementId) == "string" then
			elementId, err = self.getMessage(self, elementId, location)
			if elementId then
				elementId = elementId.id
			else
				return nil, err .. " (0x1)"
			end
		end
		link = enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
	elseif element == enum.element.tribe then
		-- Tribe ID
		link = enum.forumUri.tribe .. "?tr=" .. elementId
	elseif element == enum.element.profile then
		-- User ID
		if type(elementId) == "string" then
			local err
			elementId, err = self.getProfile(self, elementId)
			if err then
				return nil, err .. " (0x2)"
			end
			elementId = elementId.id
		end
		link = enum.forumUri.profile .. "?pr=" .. elementId -- (Can be the ID too)
	elseif element == enum.element.private_message then
		-- Private Message, Message ID
		if not location.co then
			return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'co'")
		end
		if type(elementId) == "string" then
			elementId, err = self.getMessage(self, elementId, location)
			if elementId then
				elementId = elementId.id
			else
				return nil, err .. " (0x3)"
			end
		end
		link = enum.forumUri.conversation .. "?co=" .. location.co
	elseif element == enum.element.poll then
		-- Poll ID
		if not location.f or not location.t then
			return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
		end
		if type(elementId) == "string" then
			return nil, enum.errorString.poll_id
		end
		link = enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
	elseif element == enum.element.image then
		-- Image ID
		if type(elementId) == "number" then
			return nil, enum.errorString.image_id
		end
		link = enum.forumUri.view_user_image .. "?im=" .. elementId
	else
		return nil, enum.errorString.unaivalable_enum
	end

	return performAction(self, enum.forumUri.report, {
		{ 'f', (location.f or 0) },
		{ "te", element },
		{ "ie", elementId },
		{ "raison", reason }
	}, link)
end

--[[@
	@file Moderation
	@desc Changes the state of a message. (e.g: active, moderated)
	@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message ids, use a table with `ints` or `strings`.
	@param messageState<string,int> The message state. An enum from @see messageState. (index or value)
	@param location<table> The message location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@param reason?<string> The state change reason.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.changeMessageState = function(self, messageId, messageState, location, reason)
	extensions.assertion("changeMessageState", { "number", "table", "string" }, 1, messageId)
	extensions.assertion("changeMessageState", { "string", "number" }, 2, messageState)
	extensions.assertion("changeMessageState", "table", 3, location)
	extensions.assertion("changeMessageState", { "string", "nil" }, 4, reason)

	local err
	messageState, err = enum._isValid(messageState, "messageState")
	if err then return nil, err end

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local message
	local messageIdIsString = type(messageId) == "string"
	if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
		if messageIdIsString then
			message, err = self.getMessage(self, messageId, location)
			if not message then
				return nil, err .. " (0x1)"
			end
			messageId = { message.id }
		else
			for i = 1, #messageId do
				message, err = self.getMessage(self, messageId, location)
				if not message then
					return nil, err .. " (0x2)"
				end
				messageId[i] = message.id
			end
		end
	end

	return performAction(self, enum.forumUri.moderate, {
		{ 'f', location.f },
		{ 't', location.t },
		{ "messages", table.concat(messageId, enum.separator.forum_data) },
		{ "etat", messageState },
		{ "raison", (reason or '') }
	}, enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
end

--[[@
	@file Moderation
	@desc Changes the restriction state of a message.
	@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message ids, use a table with `ints` or `strings`.
	@param contentState<string> An enum from @see contentState (index or value)
	@param location<table> The topic location.
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.changeMessageContentState = function(self, messageId, contentState, location)
	extensions.assertion("changeMessageContentState", { "number", "table", "string" }, 1, messageId)
	extensions.assertion("changeMessageContentState", "string", 2, contentState)
	extensions.assertion("changeMessageContentState", "table", 3, location)

	local err
	contentState, err = enum._isValid(contentState, "contentState", nil, nil, true)
	if err then return nil, err end

	if not location.f or not location.t then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
	end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local message
	local messageIdIsString = type(messageId) == "string"
	if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
		if messageIdIsString then
			message, err = self.getMessage(self, messageId, location)
			if not message then
				return nil, err .. " (0x1)"
			end
			messageId = { message.id }
		else
			for i = 1, #messageId do
				message, err = self.getMessage(self, messageId, location)
				if not message then
					return nil, err .. " (0x2)"
				end
				messageId[i] = message.id
			end
		end
	end

	return performAction(self, enum.forumUri.manage_message_restriction, {
		{ 'f', location.f },
		{ 't', location.t },
		{ "messages", table.concat(messageId, enum.separator.forum_data) },
		{ "restreindre", contentState }
	}, enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
end

	--[[ Tribe ]]--
--[[@
	@file Tribe
	@desc Gets the data of a tribe.
	@param tribeId?<int> The tribe id. @default = Account's tribe id
	@returns table,nil The tribe data.
	@returns nil,string Error message.
	@struct {
		community = enum.community, -- The tribe community.
		creationDate = "", -- The date of the tribe creation.
		favoriteId = 0, -- The favorite id of the tribe, if 'isFavorited'.
		greetingMessage = "", -- The tribe greeting messages string field.
		id = 0, -- The tribe id.
		isFavorited = false, -- Whether the tribe is favorited or not.
		leaders = { "" }, -- The list of tribe leaders.
		name = "", -- The name of the tribe.
		presentation = "", -- The tribe presentation string field.
		recruitment = enum.recruitmentState -- The current recruitment state of the tribe.
	}
]]
client.getTribe = function(self, tribeId)
	extensions.assertion("getTribe", { "number", "nil" }, 1, tribeId)

	if not tribeId then
		if not self.isConnected then
			return nil, enum.errorString.not_connected
		end

		if not self.tribeId then
			return nil, enum.errorString.no_tribe
		end
		tribeId = self.tribeId
	end

	local body = getPage(self, enum.forumUri.tribe .. "?tr=" .. tribeId)

	local fa = tonumber(string.match(body, string.format(enum.htmlChunk.hidden_value, enum.forumUri.favorite_id)))

	local name = string.match(body, enum.htmlChunk.title)
	local creationDate, community = string.match(body, enum.htmlChunk.date .. ".-" .. enum.htmlChunk.community)
	local recruitment = string.match(body, enum.htmlChunk.recruitment)

	local leaders, counter = { }, 0
	-- Some tribes may have more than one leader
	for name, discriminator in string.gmatch(body, enum.htmlChunk.nickname) do
		counter = counter + 1
		leaders[counter] = name .. discriminator
	end

	counter = 0
	local tmp, greetingMessage, presentation = { }
	for data in string.gmatch(body, enum.htmlChunk.tribe_presentation) do
		counter = counter + 1
		tmp[counter] = data
	end
	if counter == 2 then
		greetingMessage = string.match(tmp[1], enum.htmlChunk.greeting_message)
		presentation = tmp[2]
	elseif counter == 1 then
		local data = string.match(tmp[1], enum.htmlChunk.greeting_message)
		if data then
			greetingMessage = data
		else
			presentation = tmp[1]
		end
	end

	return {
		community = enum.community[community],
		creationDate = creationDate,
		favoriteId = fa,
		greetingMessage = greetingMessage,
		id = tribeId,
		isFavorited = not not fa,
		leaders = leaders,
		name = name,
		presentation = presentation,
		recruitment = enum.recruitmentState[string.lower(recruitment)]
	}
end

--[[@
	@file Tribe
	@desc Gets the members of a tribe.
	@param tribeId?<int> The tribe id. @default = Accounts's tribe id
	@param pageNumber?<int> The list page (if the tribe has more than 30 members). To list ALL members, use `0`. @default 1
	@returns table,nil The names of the tribe ranks.
	@returns nil,string Error message.
	@struct {
		[n] = {
			community = enum.community, -- The community of the member.
			name = "", -- The name of the member.
			rank = "", -- The name of the rank assigned to the member. (needs tribe permissions or to be a tribe member)
			timestamp = 0 -- The timestamp of when the member joined the tribe. (needs to be a tribe member)
		},
		_pages = 0, -- The total pages of the member list.
		_count = 0 -- The total of members in the tribe.
	}
]]
client.getTribeMembers = function(self, tribeId, pageNumber)
	extensions.assertion("getTribeMembers", { "number", "nil" }, 1, tribeId)
	extensions.assertion("getTribeMembers", { "number", "nil" }, 2, pageNumber)

	pageNumber = pageNumber or 1

	if not tribeId then
		if not self.isConnected then
			return nil, enum.errorString.not_connected
		end

		if not self.tribeId then
			return nil, enum.errorString.no_tribe
		end
		tribeId = self.tribeId
	end

	local uri = enum.forumUri.tribe_members .. "?tr=" .. tribeId
	local totalPages, lastPageQuantity
	local members = getBigList(self, pageNumber, uri, function(members, body, _pageNumber, _totalPages)
		local counter = 0
		if tribeId == self.tribeId then
			for community, name, discriminator, _, rank, jointDate in string.gmatch(body, enum.htmlChunk.community .. ".-" .. enum.htmlChunk.nickname .. ".-" .. enum.htmlChunk.tribe_rank .. ".-" .. enum.htmlChunk.ms_time) do
				counter = counter + 1
				members[counter] = {
					community = enum.community[community],
					name = name .. discriminator,
					rank = rank,
					timestamp = tonumber(jointDate)
				}
			end
		else
			local displaysRanks = not not string.find(body, enum.htmlChunk.tribe_rank_list)
			if displaysRanks then
				for community, name, discriminator, _, rank in string.gmatch(body, enum.htmlChunk.community .. ".-" .. enum.htmlChunk.nickname .. ".-" .. enum.htmlChunk.tribe_rank) do
					counter = counter + 1
					members[counter] = {
						community = enum.community[community],
						name = name .. discriminator,
						rank = rank
					}
				end
			else
				for community, name, discriminator in string.gmatch(body, enum.htmlChunk.community .. ".-" .. enum.htmlChunk.nickname) do
					counter = counter + 1
					members[counter] = {
						community = enum.community[community],
						name = name .. discriminator,
					}
				end
			end
		end

		if not totalPages then
			totalPages = _totalPages
		end
		if _pageNumber == _totalPages then
			lastPageQuantity = counter
		end
	end, true)

	totalPages = totalPages or 1

	-- Get total of members
	if not lastPageQuantity then
		lastPageQuantity = 0
		local body = getPage(self, uri .. "&p=" .. totalPages)
		for _ in string.gmatch(body, enum.htmlChunk.total_members) do
			lastPageQuantity = lastPageQuantity + 1
		end
		if lastPageQuantity == 0 then
			return nil, enum.errorString.internal
		end
	end

	members._count = ((totalPages - 1) * 30) + lastPageQuantity
	return members
end

--[[@
	@file Tribe
	@desc Gets the ranks of a tribe.
	@param tribeId?<int,table> The tribe id. If the rank ids are necessary, send a location table from any forum in your own tribe instead (if it's from another tribe it will not affect the behavior of self.function). @default Account's tribe id
	@paramstruct tribeId {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns table,nil The names of the tribe ranks
	@returns nil,string Error message.
	@struct {
		-- If 'tribeId' is not a location table, the struct is a string array.
		[n] = {
			id = 0, -- The role id.
			name = "" -- The role name.
		}
	}
]]
client.getTribeRanks = function(self, tribeId)
	extensions.assertion("getTribeRanks", { "number", "table", "nil" }, 1, tribeId)

	local location
	if type(tribeId) == "table" then
		location = tribeId
		tribeId = self.tribeId
	end

	if location and (not location.f or not location.s) then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	if not self.isConnected and (not tribeId or location) then
		return nil, enum.errorString.not_connected
	end

	if not tribeId then
		if not self.tribeId then
			return nil, enum.errorString.no_tribe
		end
		tribeId = self.tribeId
	end

	if location and tribeId ~= self.tribeId then
		location = nil
	end

	local body = getPage(self, (location and (enum.forumUri.edit_section_permissions .. "?f=" .. location.f .. "&s=" .. location.s) or (enum.forumUri.tribe_members .. "?tr=" .. tribeId)))

	local ranks, counter = { }, 0

	if not location then
		local data = string.match(body, enum.htmlChunk.tribe_rank_list)
		if not data then
			return nil, enum.errorString.no_right
		end

		for name in string.gmatch(data, enum.htmlChunk.tribe_rank) do
			counter = counter + 1
			ranks[counter] = name
		end
	else
		for id, name in string.gmatch(body, enum.htmlChunk.tribe_rank_id) do
			counter = counter + 1
			ranks[counter] = {
				id = id,
				name = name
			}
		end
	end

	return ranks
end

do
	local getRegistry = function(timestamp, log)
		return {
			log = log,
			timestamp = tonumber(timestamp)
		}
	end

	--[[@
		@file Tribe
		@desc Gets the history logs of a tribe.
		@param tribeId?<int> The tribe id. @default Account's tribe id
		@param pageNumber?<int> The page number of the history list. To list ALL the history, use `0`. @default 1
		@returns table,nil The history logs.
		@returns nil,string Error message.
		@struct {
			[n] = {
				log = "", -- The log value.
				timestamp = 0 -- The timestamp of the log.
			},
			_pages = 0 -- The total pages of the history list.
		}
	]]
	self.getTribeHistory = function(self, tribeId, pageNumber)
		extensions.assertion("getTribeHistory", { "number", "nil" }, 1, tribeId)
		extensions.assertion("getTribeHistory", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not tribeId then
			if not self.isConnected then
				return nil, enum.errorString.not_connected
			end

			if not self.tribeId then
				return nil, enum.errorString.no_tribe
			end
			tribeId = self.tribeId
		end

		return getList(self, pageNumber, enum.forumUri.tribe_history .. "?tr=" .. tribeId, getRegistry, enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.tribe_log)
	end
end

--[[@
	@file Tribe
	@desc Gets the sections of a tribe forum.
	@param location?<table> The location of the tribe forum. @default Account's tribe forum
	@paramstruct location {
		f?<int> The forum id. (needed if sub-forum)
		s?<int> The section id. (needed if sub-forum)
		tr?<int> The tribe id. (needed if forum)
	}
	@returns table,nil The data of each section.
	@returns nil,string Error message.
	@struct {
		[n] = {
			f = 0, -- The forum id.
			name = "", -- The section name.
			s = 0, -- The section id.
			tr = 0 -- The tribe id.
		}
	}
]]
client.getTribeForum = function(self, location)
	extensions.assertion("getTribeForum", { "table", "nil" }, 1, location)

	location = location or { tr = self.tribeId }

	if not location.tr and (not location.f or not location.s) then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's' / 'tr'")
	end

	local body = getPage(self, enum.forumUri.tribe_forum .. (location.s and ("?f=" .. location.f .. "&s=" .. location.s) or ("?tr=" .. location.tr)))

	local sections, counter = { }, 0
	for f, s, name in string.gmatch(body, enum.htmlChunk.tribe_section_id) do
		counter = counter + 1
		sections[counter] = {
			f = tonumber(f),
			name = name,
			s = tonumber(s),
			tr = location.tr
		}
	end

	return sections
end

--[[@
	@file Tribe
	@desc Updates the account's tribe's greetings message string field.
	@param message<string> The new message content.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateTribeGreetingMessage = function(self, message)
	extensions.assertion("updateTribeGreetingMessage", "string", 1, message)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	return performAction(self, enum.forumUri.update_tribe_message, {
		{ "tr", self.tribeId },
		{ "message_jour", message }
	}, enum.forumUri.tribe .. "?tr=" .. self.tribeId)
end

--[[@
	@file Tribe
	@desc Updates the account's tribe's profile parameters.
	@param parameters<table> The parameters.
	@paramstruct parameters {
		displayGreetings?<boolean> Whether the tribe's profile should display the tribe's greetings message or not.
		displayRanks?<boolean> Whether the tribe's profile should display the tribe ranks or not.
		displayLogs?<boolean> Whether the tribe's profile should display the history logs or not.
		displayLeaders?<boolean> Whether the tribe's profile should display the tribe leaders or not.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateTribeParameters = function(self, parameters)
	extensions.assertion("updateTribeParameters", "table", 1, parameters)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	local postData = {
		{ "tr", self.tribeId }
	}
	if type(parameters.displayGreetings) == "boolean" and parameters.displayGreetings then
		postData[#postData + 1] = { "message_jour_public", "on" }
	end
	if type(parameters.displayRanks) == "boolean" and parameters.displayRanks then
		postData[#postData + 1] = { "rangs_publics", "on" }
	end
	if type(parameters.displayLogs) == "boolean" and parameters.displayLogs then
		postData[#postData + 1] = { "historique_public", "on" }
	end
	if type(parameters.displayLeaders) == "boolean" and parameters.displayLeaders then
		postData[#postData + 1] = { "chefs_publics", "on" }
	end

	return performAction(self, enum.forumUri.update_tribe_parameters, postData, enum.forumUri.tribe .. "?tr=" .. self.tribeId)
end

--[[@
	@file Tribe
	@desc Updates the account's tribe's profile.
	@param data<table> The data
	@paramstruct data {
		community?<string,int> Tribe's community. An enum from @see community. (index or value) @default xx
		recruitment?<string,int> Tribe's recruitment state. An enum from @see recruitmentState. (index or value)
		presentation?<string> Tribe's profile's presentation string field.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateTribeProfile = function(self, data)
	extensions.assertion("updateTribeProfile", "table", 1, data)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	local postData = {
		{ "tr", self.tribeId }
	}

	local err
	if data.community then
		data.community, err = enum._isValid(data.community, "community", "data.community")
		if err then return nil, err end

		postData[#postData + 1] = { "communaute", data.community }
	else
		postData[#postData + 1] = { "communaute", enum.community.xx }
	end
	if data.recruitment then
		data.recruitment, err = enum._isValid(data.recruitment, "recruitmentState", "data.recruitment")
		if err then return nil, err end

		postData[#postData + 1] = { "recrutement", data.recruitment }
	end
	if data.presentation then
		postData[#postData + 1] = { "b_presentation", "on" }
		postData[#postData + 1] = { "presentation", data.presentation }
	end

	return performAction(self, enum.forumUri.update_tribe, postData, enum.forumUri.tribe .. "?tr=" .. self.tribeId)
end

--[[@
	@file Tribe
	@desc Changes the logo of the account's tribe.
	@param image<string> The new image. An URL or file name.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.changeTribeLogo = function(self, image)
	extensions.assertion("changeTribeLogo", "string", 1, image)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	local extension = fileManager.getExtension(image)
	if not extension then
		return nil, enum.errorString.invalid_extension
	end

	image = fileManager.getFile(image)
	if not image then
		return nil, enum.errorString.invalid_file
	end

	local file = fileManager.buildFileContent("tr", self.tribeId, extension, image)
	return performAction(self, enum.forumUri.upload_logo, nil, enum.forumUri.tribe .. "?tr=" .. self.tribeId, table.concat(file, enum.separator.file))
end

--[[@
	@file Tribe
	@desc Removes the logo of the account's tribe.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.removeTribeLogo = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	return performAction(self, enum.forumUri.remove_logo, {
		{ "tr", self.tribeId }
	}, enum.forumUri.tribe .. "?tr=" .. self.tribeId)
end

--[[@
	@file Tribe
	@desc Creates a section.
	@param data<table> The new section data.
	@param location?<table> The location where the section will be created.
	@paramstruct data {
		name<string> Section's name.
		icon<string> Section's icon. An enum from @see sectionIcon. (index or value)
		description?<string> Section's description. @default Section name
		min_characters?<int> Minimum characters needed to send a message in the section. @default 4
	}
	@paramstruct location {
		f<int> The forum id.
		s?<int> The section id. (needed if sub-section)
	}
	@returns table,nil The location of the new section.
	@returns nil,string Error message.
	@struct {
		f = 0, -- The forum id.
		s = 0 -- The section id.
	}
]]
client.createSection = function(self, data, location)
	extensions.assertion("createSection", "table", 1, data)
	extensions.assertion("createSection", { "table", "nil" }, 2, location)

	if not data.name or not data.icon then
		return nil, string.format(enum.errorString.no_required_fields, "data { 'name', 'icon' }")
	end

	local err
	data.icon, err = enum._isValid(data.icon, "sectionIcon", "data.icon", nil, true)
	if err then return nil, err end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	if not location then
		local body = getPage(self, enum.forumUri.tribe_forum .. "?tr=" .. self.tribeId)
		location = {
			f = tonumber(string.match(body, "%?f=(%d+)"))
		}
	end

	if not location.f then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f'")
	end

	-- Gets all the ids, then create the section, then get again all the ids and get the only one that did not appear in oldSections
	local oldSections, err = self.getTribeForum(self, {
		f = location.f,
		s = location.s,
		tr = self.tribeId
	})
	if not oldSections then
		return nil, err .. " (0x1)"
	end
	oldSections = table.createSet(oldSections, 's')

	local result, err = performAction(self, enum.forumUri.create_section, {
		{ 'f', location.f },
		{ 's', (location.s or 0) },
		{ "tr", (location.s and 0 or self.tribeId) },
		{ "nom", data.name },
		{ "icone", data.icon },
		{ "description", (data.description or data.name) },
		{ "caracteres", (data.min_characters or 4) }
	}, enum.forumUri.new_section .. "?f=" .. location.f .. (location.s and ("&s=" .. location.s) or ("&tr=" .. self.tribeId)))

	if result then
		local currentSections
		currentSections, err = self.getTribeForum({
			f = location.f,
			s = location.s,
			tr = self.tribeId
		})
		if not currentSections then
			return nil, err .. " (0x2)"
		end

		local id
		for i = 1, #currentSections do
			if not oldSections[currentSections[i].s] then
				id = currentSections[i].s
				break
			end
		end

		return {
			f = location.f,
			s = id
		}
	end

	return nil, err
end

--[[@
	@file Tribe
	@desc Updates a section.
	@param data<table> The updated section data
	@param location<table> The section location. Fields 'f' and 's' are needed.
	@paramstruct data {
		name<string> The name of the section.
		icon<string> The icon of the section. An enum from @see sectionIcon. (index or value)
		description<string> The section's description string field.
		min_characters<int> Minimum characters needed for a message in the new section
		state<string,int> The section's state (e.g.: open, closed). An enum from @see displayState. (index or value)
		parent<int> The parent section if the updated section is a sub-section. @default 0
	}
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.updateSection = function(self, data, location)
	extensions.assertion("updateSection", "table", 1, data)
	extensions.assertion("updateSection", "table", 2, location)

	if not location.f or not location.s then
		return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 's'")
	end

	if not data.state then
		return nil, string.format(enum.errorString.no_required_fields, "'data.state'")
	end

	local err
	if data.icon then
		data.icon, err = enum._isValid(data.icon, "sectionIcon", "data.icon", nil, true)
		if err then return nil, err end
	end

	data.state, err = enum._isValid(data.state, "displayState", "data.state")
	if err then return nil, err end

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	local section, err = self.getSection(self, location)
	if not section then
		return nil, err
	end

	return performAction(self, enum.forumUri.update_section, {
		{ 'f', location.f },
		{ 's', location.s },
		{ "nom", (data.name or section.name) },
		{ "icone", (data.icon or section.icon) },
		{ "description", (data.description or '') },
		{ "caracteres", (data.min_characters or 4) },
		{ "etat", data.state },
		{ "parent", (data.parent or (section.parent and section.parent.location.s) or 0) }
	}, enum.forumUri.edit_section .. "?f=" .. location.f .. "&s=" .. location.s)
end

--[[@
	@file Tribe
	@desc Sets the permissions of each rank for a specific section on the account's tribe's forum.
	@desc To allow _non-members_, use `enum.misc.non_member` or `"non_member"` in the permissions list.
	@param permissions<table> The permissions of the section.
	@param location<table> The section location.
	@paramstruct permissions {
		canRead?<table> A list of role names or ids that should be allowed to read the topics of the section.
		canAnswer?<table> A list of role names or ids that should be allowed to send messages in the topics of the section.
		canCreateTopic?<table> A list of role names or ids that should be allowed to create topics in the section.
		canModerate?<table> A list of role names or ids that should be allowed to moderate in the section.
		canManage?<table> A list of role names or ids that should be allowed to manage the section.
	}
	@paramstruct location {
		f<int> The forum id.
		s<int> The section id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.setTribeSectionPermissions = function(self, permissions, location)
	extensions.assertion("setTribeSectionPermissions", "table", 1, permissions)
	extensions.assertion("setTribeSectionPermissions", "table", 2, location)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	if not self.tribeId then
		return nil, enum.errorString.no_tribe
	end

	local ranks, err = self.getTribeRanks(self, nil, location)
	if not ranks then
		return nil, err
	end

	local ranks_by_id = table.createSet(ranks, "id")
	local ranks_by_name = table.createSet(ranks, "name")

	local indexes = { "canRead", "canAnswer", "canCreateTopic", "canModerate", "canManage" }

	local defaultPermission = { ranks[1].id }

	-- Checks for duplicates, transform strings in IDs, adds the leader id if necessary
	for i = 1, #indexes do
		if permissions[indexes[i]] then
			local perms, permsSet = { }, { }
			local hasLeader = false

			for j = 1, #permissions[indexes[i]] do
				if type(permissions[indexes[i]][j]) == "string" then
					if permissions[indexes[i]][j] == "non_member" then
						permissions[indexes[i]][j] = enum.misc.non_member
					else
						permissions[indexes[i]][j] = ranks_by_name[permissions[indexes[i]][j]].id
					end
					if not permissions[indexes[i]][j] then
						return nil, enum.errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
					end
				end

				if not hasLeader and permissions[indexes[i]][j] == ranks[1].id then
					hasLeader = true
				end

				if not ranks_by_id[permissions[indexes[i]][j]] then
					if permissions[indexes[i]][j] ~= enum.misc.non_member then
						return nil, enum.errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
					end
				end
				if not permsSet[permissions[indexes[i]][j]] then
					permsSet[permissions[indexes[i]][j]] = true
					perms[#perms + 1] = permissions[indexes[i]][j]
				end
			end
			if not hasLeader then
				permissions[indexes[i]][#permissions[indexes[i]] + 1] = ranks[1].id
			end
		else
			permissions[indexes[i]] = defaultPermission
		end
	end

	return performAction(self, enum.forumUri.update_section_permissions, {
		{ 'f', location.f },
		{ 's', location.s },
		{ "tr", self.tribeId },
		{ "droitLire", table.concat(permissions.canRead, enum.separator.forum_data) },
		{ "droitRepondre", table.concat(permissions.canAnswer, enum.separator.forum_data) },
		{ "droitCreerSujet", table.concat(permissions.canCreateTopic, enum.separator.forum_data) },
		{ "droitModerer", table.concat(permissions.canModerate, enum.separator.forum_data) },
		{ "droitGerer", table.concat(permissions.canManage, enum.separator.forum_data) }
	}, enum.forumUri.edit_section_permissions .. "?f=" .. location.f .. "&s=" .. location.s)
end

	--[[ Others ]]--
do
	local getTitleObj = function(community, post, title, timestamp, author)
		return {
			author = self.formatNickname(author),
			community = enum.community[community],
			location = parseUrlData(post),
			timestamp = tonumber(timestamp),
			title = title
		}
	end

	local getMessageObj = function(community, post, title, postId, contentHtml, timestamp, author)
		return {
			author = self.formatNickname(author),
			community = enum.community[community],
			contentHtml = contentHtml,
			location = parseUrlData(post),
			post = postId,
			timestamp = tonumber(timestamp),
			title = title
		}
	end

	local getTribeObj = function(name, id)
		return {
			id = tonumber(id),
			name = name
		}
	end

	local getTribeListObj = function(head, body)
		for i = 1, #head do
			if head[i][1] == "Location" then
				return {
					[1] = {
						id = tonumber(string.match(head[i][2], "(%d+)$")),
						name = search -- Assuming that's the name of the tribe
					},
					_page = 0
				}
			end
		end
	end

	local getPlayerObj = function(community, name, discriminator)
		return {
			community = enum.community[community],
			name = name .. discriminator
		}
	end

	--[[@
		@file Miscellaneous
		@desc Performs a deep search on forums.
		@desc /!\ This function may take several minutes to return the values depending on the settings.
		@param searchType<string,int> The type of the search (e.g.: player, message). An enum from @see searchType. (index or value)
		@param search<string> The value to be searched.
		@param pageNumber?<int> The page number of the search results. To list ALL the matches, use `0`. @default 1
		@param data?<table> Additional data to be used in the `message_topic` search type.
		@paramstruct data {
			author?<string> The name of the message or topic author that the search system needs to look for.
			community?<string,int> The community to perform the search. An enum from @see community. (index or value)
			f<int> The forum id.
			s?<int> The section id.
			searchLocation<string,int > The specific search location. An enum from @see searchLocation. (index or value)
		}
		@returns table,nil The search matches. Total pages at `_pages`.
		@returns nil,string Error message.
		@struct {
			[n] = {
				author = "", -- The author of the topic or message matched. (When 'searchType' is 'message_topic')
				community = enum.community, -- The community of the topic or player matched. (When 'searchType' is not 'tribe')
				contentHtml = "", -- The HTML of the message content. (When 'searchType' is 'message_topic' and 'searchLocation' is not 'titles')
				id = 0, -- The id of the tribe found. (When 'searchType' is 'tribe')
				location = parseUrlData, -- The location of the message or topic. (When 'searchType' is 'message_topic')
				name = "", -- The name of the player or tribe. (When 'searchType' is not 'message_topic')
				post = "", -- The post id of the message. (When 'searchType' is 'message_topic' and 'searchLocation' is not 'titles')
				timestamp = 0, -- The timestamp of when the message or topic was created.
				title = "" -- The topic title. (When 'searchType' is 'message_topic')
			},
			_pages = 0 -- The total pages of available matches for the search.
		}
	]]
	self.search = function(self, searchType, search, pageNumber, data)
		if type(search) == "number" then
			search = tostring(search)
		end

		extensions.assertion("search", { "string", "number" }, 1, searchType)
		extensions.assertion("search", "string", 2, search)
		extensions.assertion("search", { "number", "nil" }, 4, pageNumber)

		pageNumber = pageNumber or 1

		local err
		searchType, err = enum._isValid(searchType, "searchType", "searchType")
		if err then return nil, err end

		if not self.isConnected then
			return nil, enum.errorString.not_connected
		end

		local d, html, f, inif = ''
		if searchType == enum.searchType.message_topic then
			extensions.assertion("search", "table", 3, data)

			if not data.searchLocation or not data.f then
				return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "data { 'searchLocation', 'f' }")
			end
			data.author = data.author or ''
			data.community = data.community or 0
			data.s = data.s or 0

			if data.searchLocation == enum.searchLocation.titles then
				html = enum.htmlChunk.topic_div .. ".-" .. enum.htmlChunk.community .. ".-" .. enum.htmlChunk.search_list .. ".-" .. enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.profile_id
				f = getTitleObj
			else
				html = enum.htmlChunk.topic_div .. ".-" .. enum.htmlChunk.community .. ".-" .. enum.htmlChunk.search_list .. ".-" .. enum.htmlChunk.message_post_id .. ".-" .. enum.htmlChunk.message_html .. ".-" .. enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.profile_id
				f = getMessageObj
			end

			d = "&ou=" .. data.searchLocation .. "&pr=" .. data.author .. "&f=" .. data.f .. "&c=" .. data.community .. "&s=" .. data.s, pageNumber
		else
			if searchType == enum.searchType.tribe then
				html = enum.htmlChunk.tribe_list
				f = getTribeObj
				inif = getTribeListObj
			else
				html = enum.htmlChunk.community .. ".-" .. enum.htmlChunk.nickname
				f = getPlayerObj
			end
		end

		return getList(self, pageNumber, enum.forumUri.search .. "?te=" .. searchType .. "&se=" .. extesions.encodeUrl(search) .. d, f, html, inif)
	end
end

--[[@
	@file Miscellaneous
	@desc Gets the topics created by a user.
	@param userName?<string,int> User name or user id. @default Account's id
	@returns table,nil The list of topics.
	@returns nil,string Error message.
	@struct {
		[n] = {
			community = enum.community, -- The community where the topic was created.
			location = parseUrlData, -- The location of the topic.
			timestamp = 0, -- The timestamp of when the topic was created.
			title = "", -- The title of the topic.
			totalMessages = 0 -- The total of messages of the topic.
		}
	}
]]
client.getCreatedTopics = function(self, userName)
	extensions.assertion("getCreatedTopics", { "string", "number", "nil" }, 1, userName)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.topics_started .. "?pr=" .. (userName and extesions.encodeUrl(userName) or self.userId))

	local topics, counter = { }, 0
	for community, topic, title, messages, timestamp in string.gmatch(body, enum.htmlChunk.topic_div .. ".-" .. enum.htmlChunk.community .. ".-" .. enum.htmlChunk.created_topic_data .. ".- on .-" .. enum.htmlChunk.ms_time) do
		counter = counter + 1
		topics[counter] = {
			community = enum.community[community],
			location = parseUrlData(topic),
			timestamp = tonumber(timestamp),
			title = title,
			totalMessages = tonumber(messages)
		}
	end

	return topics
end

--[[@
	@file Miscellaneous
	@desc Gets the last posts of a user.
	@param pageNumber?<int> The page number of the last posts list. @default 1
	@param userName?<string,int> User name or id. @default Account's id
	@param extractNavbar?<boolean> Whether the info should include the navigation bar or not. @default false
	@returns table,nil The list of posts.
	@returns nil,string Error message.
	@struct {
		[n] = {
			contentHtml = "", -- The HTML of the message content.
			location = parseUrlData, -- The location of the message.
			navbar = {
				[n] = {
					location = parseUrlData, -- The parsed-url location object.
					name = "" -- The name of the location.
				}
			}, -- A list of locations of the navigation bar. (If 'extractNavbar' is true)
			post = "", -- The post id of the message.
			timestamp = 0, -- The timestamp of when the message was created.
			topicTitle = "" -- The title of the topic where the message was posted.
		},
		_pages = 0 -- The total pages of the "last posts" list.
	}
]]
client.getLastPosts = function(self, pageNumber, userName, extractNavbar)
	extensions.assertion("getLastPosts", { "number", "nil" }, 1, pageNumber)
	extensions.assertion("getLastPosts", { "string", "number", "nil" }, 2, userName)
	extensions.assertion("getLastPosts", { "boolean", "nil" }, 3, extractNavbar)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.posts .. "?pr=" .. (userName and extesions.encodeUrl(userName) or self.userId) .. "&p=" .. (pageNumber or 1))

	local totalPages = tonumber(string.match(body, enum.htmlChunk.total_pages)) or 1

	local posts, counter = {
		_pages = totalPages
	}, 0
	for navBar, post, topicTitle, postId, contentHtml, timestamp in string.gmatch(body, enum.htmlChunk.last_post .. enum.htmlChunk.message_html .. ".-" .. enum.htmlChunk.ms_time) do
		counter = counter + 1
		posts[counter] = {
			contentHtml = contentHtml,
			location = parseUrlData(post),
			navbar = (extractNavbar and getNavbar(navBar, true) or nil),
			post = postId,
			timestamp = tonumber(timestamp),
			topicTitle = topicTitle
		}
	end

	return posts
end

--[[@
	@file Miscellaneous
	@desc Gets the account's favorite topics.
	@returns table,nil The list of topics.
	@returns nil,string Error message.
	@struct {
		[n] = {
			community = enum.community, -- The community where the topic is located.
			favoriteId = 0, -- The favorite id of the topic.
			navbar = {
				[n] = {
					location = parseUrlData, -- The parsed-url location object.
					name = "" -- The name of the location.
				}
			}, -- A list of locations of the navigation bar.
			timestamp = 0 -- The timestamp of when the topic was created.
		}
	}
]]
client.getFavoriteTopics = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.favorite_topics)

	local topics, counter = { }, 0
	local navigation_bar, _, community

	for navBar, favoriteId, timestamp in string.gmatch(body, enum.htmlChunk.favorite_topics .. ".-" .. string.format(enum.htmlChunk.hidden_value, enum.forumUri.favorite_id) .. ".- on .-" .. enum.htmlChunk.ms_time) do
		navigation_bar, _, community = getNavbar(navBar, true)
		if not navigation_bar then
			return nil, err .. " (0x1)"
		end

		counter = counter + 1
		topics[counter] = {
			community = (community and enum.community[community] or nil),
			favoriteId = tonumber(favoriteId),
			navbar = navigation_bar,
			timestamp = tonumber(timestamp)
		}
	end

	return topics
end

--[[@
	@file Miscellaneous
	@desc Gets the account's friendlist.
	@returns table,nil The list of friends.
	@returns nil,string Error message.
]]
client.getFriendlist = function(self, )
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.friends .. "?pr=" .. self.userId)

	local friends, counter = { }, 0
	for name, discriminator in string.gmatch(body, enum.htmlChunk.nickname) do
		counter = counter + 1
		friends[counter] = name .. discriminator
	end

	return friends
end

--[[@
	@file Miscellaneous
	@desc Gets the account's blacklist.
	@returns table,nil The list of ignored users.
	@returns nil,string Error message.
]]
client.getBlacklist = function(self)
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.blacklist .. "?pr=" .. self.userId)

	local blacklist, counter = { }, 0
	for name in string.gmatch(body, enum.htmlChunk.blacklist_name) do
		counter = counter + 1
		blacklist[counter] = name
	end

	return blacklist
end

--[[@
	@file Miscellaneous
	@desc Gets the account's favorite tribes.
	@returns table,nil The list of tribes.
	@returns nil,string Error message.
	@struct {
		[n] = {
			id = 0, -- The id of the tribe.
			name = "" -- The name of the tribe.
		}
	}
]]
client.getFavoriteTribes = function(self, )
	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local body = getPage(self, enum.forumUri.favorite_tribes)

	local tribes, counter = { }, 0

	for name, tribeId in string.gmatch(body, enum.htmlChunk.profile_tribe) do
		counter = counter + 1
		tribes[counter] = {
			id = tonumber(tribeId),
			name = name
		}
	end

	return tribes
end

--[[@
	@file Miscellaneous
	@desc Gets the latest messages sent by admins.
	@returns table,nil The list of posts.
	@returns nil,string Error message.
	@struct {
		[n] = {
			author = "", -- The name of the admin that posted the message.
			contentHtml = "", -- The HTML of the message content.
			navbar = {
				[n] = {
					location = parseUrlData, -- The parsed-url location object.
					name = "" -- The name of the location.
				}
			}, -- A list of locations of the navigation bar.
			post = "", -- The post id of the message.
			timestamp = 0 -- The timestamp of when the message was created.
		}
	}
]]
client.getDevTracker = function(self, )
	local body = getPage(self, enum.forumUri.tracker)

	local posts, counter = { }, 0
	for content in string.gmatch(body, enum.htmlChunk.topic_div .. enum.htmlChunk.tracker) do
		local navigation_bar, err = getNavbar(content)
		if not navigation_bar then
			return nil, err .. " (0x1)"
		end

		local navlen = #navigation_bar
		local postId = string.sub(navigation_bar[navlen].name, 2) -- #x
		navigation_bar[navlen] = nil

		local contentHtml, timestamp, admin = string.match(content, enum.htmlChunk.message_html .. ".-" .. enum.htmlChunk.ms_time .. ".-" .. enum.htmlChunk.admin_name)
		if not contentHtml then
			return nil, enum.errorString.internal .. " (0x2)"
		end

		counter = counter + 1
		posts[counter] = {
			author = admin .. "#0001",
			contentHtml = contentHtml,
			navbar = navigation_bar,
			post = postId,
			timestamp = tonumber(timestamp)
		}
	end

	return posts
end

--[[@
	@file Miscellaneous
	@desc Adds a user as friend.
	@param userName<string> The user to be added.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.addFriend = function(self, userName)
	extensions.assertion("addFriend", "string", 1, userName)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.add_friend, {
		{ "nom", userName }
	}, enum.forumUri.friends .. "?pr=" .. self.userId)
end

--[[@
	@file Miscellaneous
	@desc Adds a user in the blacklist.
	@param userName<string> The user to be blacklisted.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.blacklistUser = function(self, userName)
	extensions.assertion("blacklistUser", "string", 1, userName)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.ignore_user, {
		{ "nom", userName }
	}, enum.forumUri.blacklist .. "?pr=" .. self.userId)
end

--[[@
	@file Miscellaneous
	@desc Removes a user from the blacklist.
	@param userName<string> The user to be removed from the blacklist.
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.unblacklistUser = function(self, userName)
	extensions.assertion("unblacklistUser", "string", 1, userName)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	return performAction(self, enum.forumUri.remove_blacklisted, {
		{ "nom", userName }
	}, enum.forumUri.blacklist .. "?pr=" .. self.userId)
end

--[[@
	@file Miscellaneous
	@desc Favorites an element. (e.g: topic, tribe)
	@param element<string,int> The element type. An enum from @see element. (index or value)
	@param elementId<int> The element id.
	@param location?<table> The location of the element. (if `element` is `topic`)
	@paramstruct location {
		f<int> The forum id.
		t<int> The topic id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.favoriteElement = function(self, element, elementId, location)
	extensions.assertion("favoriteElement", { "string", "number" }, 1, element)
	extensions.assertion("favoriteElement", "number", 2, elementId)
	extensions.assertion("favoriteElement", { "table", "nil" }, 3, location)

	local err
	element, err = enum._isValid(element, "element")
	if err then return nil, err end

	location = location or { }

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local link
	if element == enum.element.topic or element == enum.element.poll then
		element = enum.element.topic
		-- Topic ID
		if not location.f or not location.t then
			return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
		end
		link = enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
	elseif element == enum.element.tribe then
		-- Tribe ID
		link = enum.forumUri.tribe .. "?tr=" .. elementId
	else
		return nil, enum.errorString.unaivalable_enum
	end

	return performAction(self, enum.forumUri.add_favorite, {
		{ 'f', (location.f or 0) },
		{ "te", element },
		{ "ie", elementId }
	}, link)
end

--[[@
	@file Miscellaneous
	@desc Unfavorites an element.
	@param favoriteId<int,string> The favorite id of the element.
	@param location?<table> The location of the element. (if `element` is `topic`)
	paramstruct location {
		int f The forum id.
		int t The topic id.
	}
	@returns string,nil Result string.
	@returns nil,string Error message.
]]
client.unfavoriteElement = function(self, favoriteId, location)
	extensions.assertion("unfavoriteElement", { "number", "string" }, 1, favoriteId)
	extensions.assertion("unfavoriteElement", { "table", "nil" }, 2, location)

	if not self.isConnected then
		return nil, enum.errorString.not_connected
	end

	local link
	if location then
		-- Forum topic
		if not location or not location.f or not location.t then
			return nil, enum.errorString.no_url_location .. " " .. string.format(enum.errorString.no_required_fields, "'f', 't'")
		end
		link = enum.forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
	else
		link = enum.forumUri.tribe .. "?tr=" .. favoriteId
	end

	return performAction(self, enum.forumUri.remove_favorite, {
		{ "fa", favoriteId }
	}, link)
end

--[[@
	@file Miscellaneous
	@desc Lists the members of a specific role.
	@param role<string,int<> The role id. An enum from @see listRole. (index or value)
	@returns table,nil The list of users.
	@returns nil,string Error message.
]]
client.getStaffList = function(self, role)
	extensions.assertion("getStaffList", { "string", "number" }, 1, role)

	local err
	role, err = enum._isValid(role, "listRole")
	if err then return nil, err end

	local result = getPage(self, enum.forumUri.staff .. "?role=" .. role)
	local data, counter = { }, 0
	for name, discriminator in string.gmatch(result, enum.htmlChunk.nickname) do
		counter = counter + 1
		data[counter] = name .. discriminator
	end

	return data
end

return client