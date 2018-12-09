--[[ Dependencies ]]--
local http = require("coro-http")
local base64 = require("deps/base64")
local enums = require("deps/enumerations")

--[[ System Enums and Sets ]]--
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
		- set -> s
		- update - u
		- edit - e
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
	topic = "topic",
	nPoll = "new-forum-poll",
	aForumPoll = "answer-forum-poll",
	apPoll = "answer-conversation-poll",
	getCert = "get-certification",
	acc = "account",
	sCert = "set-certification",
	sEmail = "set-email",
	sPw = "set-password",
	moveConv = "move-conversations",
	conversation = "conversation",
	conversations = "conversations",
	moveAll = "move-all-conversations",
	closeDisc = "close-discussion",
	reopenDisc = "reopen-discussion",
	invDisc = "invite-discussion",
	exitDisc = "quit-discussion",
	kickMember = "kick-discussion-member",
	eMsg = "edit-topic-message",
	like = "like-message",
	report = "report-element",
	userImg = "view-user-image",
	tribe = "tribe",
	remAvatar = "remove-profile-avatar",
	uParam = "update-user-parameters",
	remImg = "remove-user-image",
	remLogo = "remove-tribe-logo",
	uTribe = "update-tribe",
	uTribeMsg = "update-tribe-greeting-message",
	uTribeParam = "update-tribe-parameters",
	addFriend = "add-friend",
	friends = "friends",
	ignoreUser = "add-ignored",
	blacklist = "blacklist",
	unfav = "remove-favourite",
	favTopics = "favorite-topics",
	fav = "add-favourite",
	favTribes = "favorite-tribes",
	uTopic = "update-topic",
	eTopic = "edit-topic",
	moderate = "moderate-selected-topic-messages",
	manageRestriction = "manage-selected-topic-messages-restriction",
	cSection = "create-section",
	nSection = "new-section",
	uSection = "update-section",
	eSection = "edit-section",
	uSectionPerm = "update-section-permissions",
	eSectionPerm = "edit-section-permissions",
	staffAjax = "staff-ajax",
	section = "section",
	remBlacklist = "remove-ignored",
	tribeMembers = "tribe-members",
	tribeHistory = "tribe-history",
	messageHistory = "tribulle-frame-topic-message-history",
	gallery = "gallery-images-ajax",
	clientGallery = "user-images-grid-ajax",
	posts = "posts",
	topicStarted = "topics-started",
	tracker = "dev-tracker"
}

local htmlChunk = {
	secretKeys = '<input type="hidden" name="(.-)" value="(.-)">',
	pollOption = '<label class="(.-) "> +<input type="%1" name="reponse_" id="reponse_(%d+)" value="%2" .-/> +(.-) +</label>',
	poll = 'po',
	hidden = '<input type="hidden" name="%s" value="(%%d+)">',
	staff = '(%S+)<span.-hashtag".-(#%d+)</span>',
	forumMessage = 'edit',
	privateMessage = 'citer'
	message = 'cadre_message_sujet_(%%d+).-id="m%d"(.-"%%s_message.-</div>)',
	msTime = 'data%-afficher%-secondes.->(%d+)',
	name = '(%S+)<span class="nav%-header%-hashtag">(#(%d+))',
	forumMessageData = 'class="coeur".-(%d+).-edit_message_%d+.->(.-)</div>',
	messageEditionTimestamp = 'cadre%-message%-dates.-(%d+)',
	privateMessageData = 'data%-afficher%-secondes.->(%d+).-(%S+)<span class="nav%-header%-hashtag">(#%d+).-citer_message_(%d+).->(.-)</div>',
	navBar = 'barre%-navigation.->(.-)</ul>',
	navBarFragments = '<a href="(.-)".->%s*(.-)%s*</a>',
	navBarSplitContent = '^<(.+)>%s*(.+)%s*$',
	favorite = 'fa',
	totalPages = '"input%-pagination".-max="(%d+)"',
	comment = '<div id="m%d',
	elementId = 'ie',
	profileDateAndCommunity = '(%d+/%d+/%d+).-/(..)%.png.->',
	profileData = 'Messages: </span>(%d+).-Prestige: </span>(%d+).-Level: </span>(%d+)',
	profileGender = 'Gender :.- (.-)%s+<br>',
	profileBirthday = 'Birthday :</span> (%d+/%d+/%d+)',
	profileLocation = 'Location :</span> (.-)  <br>'
	nickname = '(%S+)<span class="fon%t-s couleur%-hashtag%-pseudo"> (#(%d+))',
	profileTribe = 'cadre%-tribu%-nom">(.-)</span>.-tr=(%d+)',
	profileAvatar = 'http://avatars%.atelier801%.com/(%d+)/(%d+)%.%a+%?(%d+)',
	subsection = '"cadre%-section%-titre%-mini.-(section.-)".- (.-) </a>',
	topic = '<div class="row">',
	commu = 'pays/(..)%.png"',
	icon = 'sections/(.-)%.png',
	title = '<title>(.-)</title>',
	navBarTitleIcon = '<img (.+)> %s',
	recruitment = 'Recruitment : (.-)<',
	tribeLeader = '(%S+)<span class="nav-header-hashtag">(#%d+)</span>',
	greetingMessage = '<h4>Greeting message</h4> (.-) </div>',
	tribePresentation = 'cadre%-presentation"> ([^>]+) </div>',
	profilePresentation = 'cadre-presentation"> (.-) </div>',
	blacklistName = 'cadre%-ignore%-nom">(.-)</span>',
	tribeRanks = '<h4>Ranks</h4>(.-)</div>%s+</div>',
	tribeRank = '<div class="rang%-tribu"> (.-) </div>',
	tribeMember = '/(..)%.png.-(%S+)<span class="nav%-header%-hashtag">(#%d+)',
	countMembers = '(%d+) entries',
	moderatedMessage = 'cadre%-message%-modere%-texte">by ([^,]+)[^:]*:?(.*)%]<',
	tribeHistory = '<td> (.-) </td>',
	messageHistory = 'class="hidden"> (.-) </div>',
	imageInfo = '?im=(%w+)".-pr=(.-)"',
	messageHref = 'href="(topic?.-)#m(%d+)">#%2</a>',
	listedTopic = 'href="(topic?[^#]+)#?m?(%d*)">%s+(.-) </a>',
	tracker = '<div class="row">(.-)</div>%s+</div>',
	msgHtml = 'Message</a></span> :%s+(.-)</div>%s+</td>%s+</tr>',
	adminName = 'cadre%-type%-auteur%-admin">(.-)</span>'
}

local errorString = {
	secret_key_not_found = "Secret keys could not be found.",
	already_connected = "This instance is already connected, disconnect first.",
	not_connected = "This instance is not connected yet, connect first.",
	no_poll_responses = "Missing poll responses. There must be at least two responses.",
	invalid_forum_url = "Invalid Atelier801's url.",
	no_url_location = "Missing location.",
	no_required_fields = "The fields %s are needed.",
	no_url_location_private = "The fields %s are needed if the object is private.",
	not_poll = "Invalid topic. Poll not detected.",
	internal = "Internal error.",
	poll_option_not_found = "Invalid poll option.",
	not_verified = "This instance has not a certificate yet. Valid the account first.",
	enum_out_of_range = "Enum value out of range.",
	invalid_enum = "Invalid enum.",
	poll_id = "A poll id can not be a string.",
	image_id = "An image id can not be a number.",
	invalid_date = "Invalid date format. Expected: dd/mm/yyyy",
	unaivalable_enum = "This function does not accept this enum.",
	invalid_id = "Invalid id.",
	no_tribe = "This instance does not have a tribe.",
	no_right = "You don't have rights to see this info."
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

	local j = true
	for k, v in next, tbl do
		local i
		if index then
			i = v[index]
			j = v
		else
			i = v
		end

		out[i] = j
	end
	return out
end

table.add = function(src, list)
	local len = #src
	for i = 1, #list do
		src[len + i] = list[i]
	end
end

--[[ Class ]]--
return function()
	-- Internal
	local this = {
		-- Whether the account is connected or not
		isConnected = false,
		-- The nickname of the account, if it's connected.
		userName = '',
		userId = nil,
		tribeId = nil,
		cookieState = cookieState.login,
		-- account cookies
		cookies = { },
		-- Whether the account has validated its account with a code
		hasCertificate = false
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
			return false, errorString.secret_key_not_found
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
		return http.request("GET", url, forumLink .. this:getHeaders())
	end

	--[[ Static Functions ]]--
	-- > Tool
	--[[@
		@desc Parses the URL data.
		@param href<string> The uri and data to be parsed
		@returns table|nil Parsed data. The available indexes are: `uri`, `raw_data` and `data`
		@returns nil|string Error message
	]]
	self.parseUrlData = function(href)
		assertion("parseUrlData", "string", 1, href)

		local uri, data = string.match(url, "^/?(.*)%?(.-)$")
		if not uri then
			data = ''
			valid, uri = string.match(url, "^/?(.-)$")
		end

		if valid then
			local raw_data = data

			local data = { }
			string.gsub(raw_data, "([^&]+)=([^&#]+)", function(name, value)
				data[name] = value
			end)

			return {
				uri = uri,
				raw_data = raw_data,
				data = data
			}
		end

		return nil, errorString.invalid_forum_url
	end
	--[[@
		@desc Formats a nickname.
		@param nickname<string> The nickname to be formated
		@returns string Formated nickname
	]]
	self.formatNickname = function(nickname)
		assertion("normalizeNickname", "string", 1, nickname)

		nickname = string.lower(nickname)
		nickname = string.gsub(nickname, "%%23", '#', 1)
		nickname = string.gsub(nickname, "%a", string.upper, 1)
		return nickname
	end

	--[[ Functions ]]
	-- > Settings
	--[[@
		@desc Connects to an account on Atelier801's forums.
		@param userName<string> account's user name
		@param userPassword<string> account's password
		@returns boolean Whether the account connected or not
		@returns string Result string
	]]
	self.connect = function(self, userName, userPassword)
		assertion("connect", "string", 1, userName)
		assertion("connect", "string", 2, userPassword)

		if this.isConnected then
			return false, errorString.already_connected
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
				local pr = self:getProfile()
				this.userId = pr.id
				this.tribeId = pr.tribeId
			end
		end
		return success, data
	end
	--[[@
		@desc Disconnects from an account on Atelier801's forums.
		@returns boolean Whether the account disconnected or not
		@returns string Result string
	]]
	self.disconnect = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		local success, data = this:performAction(forumUri.logout, nil, forumUri.acc)
		if string.sub(body, 3, 13) == "redirection" then
			this.isConnected = false
			this.userName = ''
			this.cookieState = cookieState.login
			this.cookies = { }
			this.userId = nil
			this.tribeId = nil
		end
		return success, data
	end
	--[[@
		@desc Sends a validation code to the account's e-mail.
		@returns boolean Whether the validation code was sent or not
		@returns string `Result string` or `Error message`
	]]
	self.requestValidationCode = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		return this:performAction(forumUri.getCert, nil, forumUri.acc)
	end
	--[[@
		@desc Submits the validation code to the forum to be validated.
		@param code<string> The validation code.
		@returns boolean Whether the validation code was sent to be validated or not
		@returns string `Result string` (Empty for success) or `Error message`
	]]
	self.submitValidationCode = function(self, code)
		assertion("submitValidationCode", "string", 1, code)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local success, data = this:performAction(forumUri.sCert, {
			{ "code", code }
		}, forumUri.acc)
		if success then
			this.hasCertificate = true
		end

		return success, data
	end
	--[[@
		@desc Sets the new account's e-mail.
		@param email<string> The e-mail
		@returns boolean Whether the validation code was sent or not
		@returns string `Result string` or `Error message`
	]]
	self.setEmail = function(self, email)
		assertion("setEmail", "string", 1, email)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.hasCertificate then
			return false, errorString.not_verified
		end

		return this:performAction(forumUri.sEmail, {
			{ "mail", email }
		}, forumUri.acc)
	end
	--[[@
		@desc Sets the new account's password.
		@param password<string> The new password
		@param disconnect?<boolean> Whether the account should be disconnect from all the dispositives or not. (default = false)
		@returns boolean Whether the new password was set or not
		@returns string `Result string` or `Error message`
	]]
	self.setPassword = function(self, password, disconnect)
		assertion("setPassword", "string", 1, password)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.hasCertificate then
			return false, errorString.not_verified
		end

		local postData = {
			{ "mdp3", getPasswordHash(password) }
		}
		if disconnect then
			postData[2] = { "deco", "on" }
		end

		return this:performAction(forumUri.sPw, postData, forumUri.acc)
	end

	-- > Profile
	--[[@
		@desc Gets an user profile.
		@param userName?<string,int> User name or id. (default = Client's account name)
		@returns table|nil The profile data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getProfile = function(self, userName)
		assertion("getProfile", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		userName = userName or this.userName
		local head, body = this:getPage(forumUri.profile .. "?pr=" .. userName)

		local id = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.elementId))) -- Element id
		local name, hashtag, discriminator = string.match(body, htmlChunk.name)
		
		local highestRole = tonumber(discriminator)
		if highestRole == 0 then
			highestRole = nil
		end

		local registrationDate, community, messages, prestige, level = string.match(body, htmlChunk.profileDateAndCommunity .. htmlChunk.profileData)
		level = tonumber(level)
		
		local gender = string.match(body, htmlChunk.profileGender)
		gender = gender and (enums.gender[string.lower(gender)]) or enums.gender.none
		
		local location = string.match(body, htmlChunk.profileLocation)

		local birthday = string.match(body, htmlChunk.profileBirthday)

		local presentation = string.match(body, htmlChunk.profilePresentation)
		
		local soulmate, soulmateDiscriminator = string.match(body, htmlChunk.nickname)
		if soulmate then
			soulmate = soulmate .. soulmateDiscriminator
		end
		
		local tribeName, tribeId = string.match(body, htmlChunk.profileTribe)

		local avatar = string.match(body, htmlChunk.profileAvatar)

		return {
			id = tonumber(id),
			highestRole = highestRole,
			registrationDate = registrationDate,
			community = enums.community[community],
			totalMessages = tonumber(messages),
			totalPrestige = tonumber(prestige),
			level = level,
			title = enums.forumTitle[level],
			gender = gender,
			birthday = birthday,
			location = location,
			soulmate = soulmate,
			tribe = tribeName,
			tribeId = tonumber(tribeId),
			avatarUrl = avatar,
			presentation = presentation
		}
	end
	--[[@
		@desc Updates the account parameters.
		@desc The available parameters are:
		@desc boolean `online` -> Whether the account should display if it's online or not
		@param parameters<table> The parameters.
		@returns boolean Whether the new parameter settings were set or not
		@returns string `Result string` or `Error message`
	]]
	self.updateParameters = function(self, parameters)
		assertion("updateParameters", "table", 1, parameters)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "pr", this.userId }
		}
		if type(parameters.online) == "boolean" and parameters.online then
			postData[#postData + 1] = { "afficher_en_ligne", "on" }
		end

		return this:performAction(forumUri.uParam, postData, forumUri.profile .. "?tr=" .. this.userId)
	end
	--[[@
		@desc Updates the account's profile.
		@desc The available data are:
		@desc string|int `community` -> Account's community. An enum from `enums.community` (index or value)
		@desc string `birthday` -> The birthday date (dd/mm/yyyy)
		@desc string `location` -> The location
		@desc string|int `gender` -> Account's gender. An enum from `enums.gender` (index or value)
		@desc string `presentation` -> Profile's presentation
		@param data<table> The data
		@returns boolean Whether the profile was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateProfile = function(self, data)
		assertion("updateProfile", "table", 1, data)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "pr", this.userId }
		}

		if data.community then
			if type(data.community) == "string" then
				-- Check if community is valid first
			end
			postData[#postData + 1] = { "communaute", data.community }
		else
			postData[#postData + 1] = { "communaute", 1 } -- xx
		end
		if data.birthday then
			if not isValidDate(data.birthday) then
				return false, errorString.invalid_date .. " (birthday)"
			end
			postData[#postData + 1] = { "b_anniversaire", "on" }
			postData[#postData + 1] = { "anniversaire", data.birthday }
		end
		if data.location then
			postData[#postData + 1] = { "b_localisation", "on" }
			postData[#postData + 1] = { "localisation", data.location }
		end
		if data.gender then
			if type(data.gender) == "string" then
				if not enums.gender[data.gender] then
					return false, errorString.invalid_enum .. " (gender)"
				end
				data.gender = enums.gender[data.gender]
			else
				if not table.search(enums.gender, data.gender) then
					return false, errorString.enum_out_of_range .. " (gender)"
				end
			end
			postData[#postData + 1] = { "b_genre", "on" }
			postData[#postData + 1] = { "genre", data.gender }
		end
		if data.presentation then
			postData[#postData + 1] = { "b_presentation", "on" }
			postData[#postData + 1] = { "presentation", data.presentation }
		end

		return this:performAction(forumUri.remImg, postData, forumUri.tribe .. "?tr=" .. this.userId)
	end
	--[[@
		@desc Removes the account's avatar.
		@returns boolean Whether the avatar was removed or not
		@returns string `Result string` or `Error message`
	]]
	self.removeAvatar = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "pr", this.userId }
		}
		return this:performAction(forumUri.remAvatar, postData, forumUri.profile .. "?tr=" .. this.userId)
	end

	-- > Private
	--[[@
		@desc Gets the data of a conversation.
		@param location<table> The conversation location. Field 'co' is needed.
		@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. (default = false)
		@returns table|nil The conversation data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getConversation = function(self, location)
		assertion("getConversation", "table", 1, location)

		if not location.co then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local path = "?co=" .. location.co
		local head, body = this:getPage(forumUri.conversation .. path)

		local po, pollOptions = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.poll))) -- Poll id
		if po then
			pollOptions = self:getPollOptions(location)
		end

		local title = string.match(body, htmlChunk.title)
		if not title then
			return nil, errorString.internal
		end

		local isPoll, isDiscussion, isPrivateMessage = not not po, false, false
		local titleIcon = string.match(body, string.format(htmlChunk.navBarTitleIcon, title))
		if not titleIcon then
			return nil, errorString.internal
		end
		if not isPoll then
			isDiscussion = not not string.find(titleIcon, enums.topicIcon.private_discussion)
			isPrivateMessage = not isDiscussion
		end

		local isLocked = false
		if not isPrivateMessage then
			isLocked = not not string.find(titleIcon, enums.topicIcon.locked)
		end

		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.totalPages))
		if not totalPages then
			return nil, errorString.internal
		end

		local _, lastPage = this:getPage(forumUri.topic .. path .. "&p=" .. totalPages)
		local counter = 0
		string.gsub(lastPage, htmlChunk.comment, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		local firstMessage
		if not ignoreFirstMessage then
			firstMessage = self:getMessage('1', location)
		end

		return {
			f = location.f,
			t = location.t,
			title = title,
			isPrivateMessage = isPrivateMessage,
			isDiscussion = isDiscussion,
			isPoll = isPoll,
			pollId = po,
			pollOptions = pollOptions,
			isLocked = isLocked,
 			pages = totalPages,
			totalMessages = totalMessages,
			firstMessage = firstMessage
		}
	end
	--[[@
		@desc Creates a new private message.
		@param destinatary<string> The user who is going to receive the private message
		@param subject<string> The subject of the private message
		@param message<string> The content of the private message
		@returns boolean Whether the private message was created or not
		@returns string if #1, `private message's url`, else `Result string` or `Error message`
	]]
	self.createPrivateMessage = function(self, destinatary, subject, message)
		assertion("createPrivateMessage", "string", 1, destinatary)
		assertion("createPrivateMessage", "string", 2, subject)
		assertion("createPrivateMessage", "string", 3, message)

		if not this.isConnected then
			return false, errorString.not_connected
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
		@returns string if #1, `private discussion's url`, else `Result string` or `Error message`
	]]
	self.createPrivateDiscussion = function(self, destinataries, subject, message)
		assertion("createPrivateDiscussion", "table", 1, destinataries)
		assertion("createPrivateDiscussion", "string", 2, subject)
		assertion("createPrivateDiscussion", "string", 3, message)

		if not this.isConnected then
			return false, errorString.not_connected
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
		@returns string if #1, `private poll's url`, else `Result string` or `Error message`
	]]
	self.createPrivatePoll = function(self, destinataries, subject, message, pollResponses, settings)
		assertion("createPrivatePoll", "table", 1, destinataries)
		assertion("createPrivatePoll", "string", 2, subject)
		assertion("createPrivatePoll", "string", 3, message)
		assertion("createPrivatePoll", "table", 4, pollResponses)
		assertion("createPrivatePoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return false, errorString.no_poll_responses
		end

		if not this.isConnected then
			return false, errorString.not_connected
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
		@param conversationId<int,string> The conversation id
		@param answer<string> The answer
		@returns boolean Whether the answer was posted or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.answerConversation = function(self, conversationId, answer)
		assertion("answerConversation", { "number", "string" }, 1, conversationId)
		assertion("answerConversation", "string", 2, answer)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "co", conversationId },
			{ "message_reponse", answer }
		}
		local success, data = this:performAction(forumUri.answer, postData, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Moves private conversations to the inbox or bin.
		@desc To empty trash, `@conversationId` must be `nil` and `@location` must be `bin`
		@param inboxLocale<string,int> Where the conversation will be located. An enum from `enums.inboxLocale` (index or value)
		@param conversationId?<int,table> The id or IDs of the conversation(s) to be moved
		@returns boolean Whether the conversation was moved or not
		@returns string if #1, `location's url`, else `Result string` or `Error message`
	]]
	self.movePrivateConversation = function(self, inboxLocale, conversationId)
		conversationId = tonumber(conversationId) or conversationId
		assertion("movePrivateConversation", { "string", "number" }, 1 inboxLocale)

		if type(inboxLocale) == "string" then
			if not enums.inboxLocale[inboxLocale] then
				return false, errorString.invalid_enum
			end
			inboxLocale = enums.inboxLocale[inboxLocale]
		else
			if not table.search(enums.inboxLocale, inboxLocale) then
				return false, errorString.enum_out_of_range
			end
		end

		local moveAll = false
		if inboxLocale == enums.inboxLocale.bin and not conversationId then
			conversationId = { }
			moveAll = true
		end
		
		assertion("movePrivateConversation", { "number", "table" }, 2, conversationId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if type(conversationId) == "number" then
			conversationId = { conversationId }
		end

		local postData = (not moveAll and {
			{ "co", table.concat(conversationId, separator.forumData) },
			{ "inboxLocale", inboxLocale }
		} or nil)
		local success, data = this:performAction((moveAll and forumUri.moveAll or forumUri.moveConv), postData, forumUri.conversations .. "?inboxLocale=" .. inboxLocale)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Changes the conversation state (open, closed).
		@param displayState<string,int> The conversation display state. An enum from `enums.displayState` (index or value)
		@param conversationId<int,string> The conversation id
		@returns boolean Whether the conversation display state was changed or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.changeConversationState = function(self, displayState, conversationId)
		assertion("changeConversationState", { "string", "number" }, 1 displayState)
		assertion("changeConversationState", { "number", "string" }, 2, conversationId)

		if type(displayState) == "string" then
			if not enums.displayState[displayState] then
				return false, errorString.invalid_enum
			end
			displayState = enums.displayState[displayState]
		else
			if not table.search(enums.displayState, displayState) then
				return false, errorString.enum_out_of_range
			end
		end

		if displayState == enums.contentState.deleted then
			return false, errorString.unaivalable_enum
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "co", conversationId }
		}
		local success, data = this:performAction((displayState == enums.displayState.open and forumUri.reopenDisc or forumUri.closeDisc), postData, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Leaves a private conversation.
		@param conversationId<int,string> The conversation id
		@returns boolean Whether the account left the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.leaveConversation = function(self, conversationId)
		assertion("leaveConversation", { "number", "string" }, 1, conversationId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "co", conversationId }
		}
		local success, data = this:performAction(forumUri.exitDisc, postData, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Invites an user to a private conversation.
		@param conversationId<int,string> The conversation id
		@param userName<string> The username to be invited
		@returns boolean Whether the username was added in the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.conversationInvite = function(self, conversationId, userName)
		assertion("conversationInvite", { "number", "string" }, 1, conversationId)
		assertion("conversationInvite", "string", 2, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "co", conversationId },
			{ "destinataires", userName }
		}
		local success, data = this:performAction(forumUri.invDisc, postData, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Excludes a user from a conversation.
		@param conversationId<int,string> The conversation id
		@param userId<int,string> The user id or nickname
		@returns boolean Whether the user was excluded from the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.kickConversationMember = function(self, conversationId, userId)
		assertion("kickConversationMember", { "number", "string" }, 1, conversationId)
		assertion("kickConversationMember", { "number", "string" }, 1, userId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if type(userId) == "string" then
			local err
			userId, err = self:getProfile(userId)
			if err then
				return false, err
			end
			userId = userId.id
		end

		local postData = {
			{ "co", conversationId },
			{ "pr", userId }
		}
		local success, data = this:performAction(forumUri.kickMember, postData, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end

	-- > Forum
	--[[@
		@desc Gets the data of a message.
		@param postId<int,string> The post id (note: not the message id, but the #mID)
		@param location<table> The post topic or conversation location. Fields 'f' and 't' are needed for forum messages, field 'co' is needed for private message.
		@returns table|nil The message data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getMessage = function(self, postId, location)
		assertion("getMessage", { "number", "string" }, 1, postId)
		assertion("getMessage", "table", 2, location)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		postId = tonumber(postId)
		local pageNumber = math.ceil(postId / 20)

		local head, body = this:getPage(forumUri.topic .. (location.co and (forumUri.conversation .. "?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t)) .. "&p=" .. pageNumber)

		local post, id
		if not location.co then
			-- Forum message
			id, post = string.match(body, string.format(htmlChunk.message, postId, htmlChunk.forumMessage))
			if not id then
				return nil, errorString.internal
			end

			local isModerated, moderatedBy, reason = false
			local timestamp, author, authorDiscriminator, _, prestige, content = string.match(post, htmlChunk.msTime .. ".-" .. htmlChunk.name .. ".-" .. htmlChunk.forumMessageData)
			if not timestamp then
				timestamp, author, authorDiscriminator, _, moderatedBy, reason = string.match(post, htmlChunk.msTime .. ".-" .. htmlChunk.name .. ".-" .. htmlChunk.moderatedMessage)
				if not timestamp then
					return nil, errorString.internal
				end
				isModerated = true
			end
			local editTimestamp = string.match(post, htmlChunk.messageEditionTimestamp)

			return {
				f = location.f,
				t = location.t,
				p = pageNumber,
				post = postId,
				timestamp = tonumber(timestamp),
				author = author .. authorDiscriminator,
				id = tonumber(id),
				prestige = tonumber(prestige),
				content = content,
				edit_timestamp = tonumber(editTimestamp),
				isModerated = isModerated,
				moderatedBy = moderatedBy,
				reason = reason
			}
		else
			-- Private message
			id, post = string.match(body, string.format(htmlChunk.message, postId, htmlChunk.privateMessage))
			if not post then
				return nil, errorString.internal
			end

			local timestamp, author, authorDiscriminator, content = string.match(post, htmlChunk.messageTimeAndAuthor .. htmlChunk.privateMessageData)
			if not timestamp then
				return nil, errorString.internal
			end

			return {
				f = 0,
				co = location.co,
 				p = pageNumber,
				post = postId,
				timestamp = tonumber(timestamp),
				author = author .. authorDiscriminator,
				id = tonumber(id),
				content = content
			}
		end
	end
	--[[@
		@desc Gets the edition logs of a message, if possible.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param location<table> The message location. Fields 'f' and 't' are needed.
		@returns table|nil The edition logs
		@returns nil|string The message error, if any occurred
	]]
	self.getMessageHistory = function(self, messageId, location)
		assertion("getMessageHistory", { "number", "string" }, 1, messageId)
		assertion("getMessageHistory", "table", 2, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self:getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return false, err
			end
		end

		local head, body = this:getPage(forumUri.messageHistory .. "?forum=" .. location.f .. "&message=" .. messageId)

		local history, counter = { }, 0

		string.gsub(body, htmlChunk.messageHistory .. ".-" .. htmlChunk.msTime, function(bbcode, timestamp)
			counter = counter + 1
			history[counter] = {
				bbcode = bbcode,
				timestamp = tonumber(timestamp)
			}
		end)

		return history
	end
	--[[@
		@desc Gets the data of a topic.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. (default = false)
		@returns table|nil The topic data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getTopic = function(self, location, ignoreFirstMessage)
		assertion("getTopic", "table", 1, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local path = "?f=" .. location.f .. "&t=" .. location.t
		local head, body = this:getPage(forumUri.topic .. path)

		local ie = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.elementId))) -- Element id
		local po, pollOptions = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.poll))) -- Poll id
		if po then
			pollOptions = self:getPollOptions(location)
		end

		local navBar = string.match(body, htmlChunk.navBar)
		if not navBar then
			return nil, errorString.internal
		end

		local isFixed, isLocked, isDeleted = false, false, false
		local navigation_bar, community = { }
		
		local counter, lastHtml = 0, ''

		local err
		string.gsub(navBar, htmlChunk.navBarFragments, function(href, code)
			href, err = self.parseUrlData(href)
			if err then
				return false, err
			end
			
			counter = counter + 1
			local html, name = string.match(code, htmlChunk.navBarSplitContent)
			if html then
				lastHtml = html
				navigation_bar[counter] = {
					location = href,
					name = name
				}

				if not community then
					community = string.match(html, htmlChunk.commu)
				end
			else
				navigation_bar[counter] = {
					location = href,
					name = code
				}
			end
		end)

		isFixed = not not string.find(lastHtml, enums.topicIcon.postit)
		isLocked = not not string.find(lastHtml, enums.topicIcon.locked)
		isDeleted = not not string.find(lastHtml, enums.topicIcon.deleted)

		local fa = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.favorite)))
		
		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.totalPages))
		if not totalPages then
			return nil, errorString.internal
		end

		local _, lastPage = this:getPage(forumUri.topic .. path .. "&p=" .. totalPages)
		local counter = 0
		string.gsub(lastPage, htmlChunk.comment, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		local firstMessage
		if not ignoreFirstMessage then
			firstMessage = self:getMessage('1', location)
		end

		return {
			f = location.f,
			t = location.t,
			elementId = ie,
			navbar = navigation_bar,
			title = navigation_bar[#navigation_bar][2],
			isFixed = isFixed,
			isLocked = isLocked,
			isDeleted = isDeleted,
			isFavorited = not not fa,
			favoriteId = fa,
			pages = totalPages,
			totalMessages = totalMessages,
			firstMessage = firstMessage,
			community = (community and enums.community[community] or nil),
			isPoll = not not po,
			pollId = po,
			pollOptions = pollOptions
		}
	end
	--[[@
		@desc Gets the data of a section.
		@param location<table> The section location. Fields 'f' and 's' are needed.
		@returns table|nil The section data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getSection = function(self, location)
		assertion("getSection", "table", 1, location)

		if not location.f or not location.s then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local path = "?f=" .. location.f .. "&s=" .. location.s
		local head, body = this:getPage(forumUri.section .. path)

		local navBar = string.match(body, htmlChunk.navBar)
		if not navBar then
			return nil, errorString.internal
		end

		local navigation_bar, community = { }
		local counter = 0

		local err
		string.gsub(navBar, htmlChunk.navBarFragments, function(href, code)
			href, err = self.parseUrlData(href)
			if err then
				return false, err
			end

			counter = counter + 1
			local html, name = string.match(code, htmlChunk.navBarSplitContent)
			if html then
				navigation_bar[counter] = {
					location = href,
					name = name
				}

				if not community then
					community = string.match(html, htmlChunk.commu)
				end
			else
				navigation_bar[counter] = {
					location = href,
					name = code
				}
			end
		end)

		local subsections, counter, totalSubsections = { }, 0
		string.gsub(lastPage, htmlChunk.subsection, function(href, name)
			counter = counter + 1
			href, err = self.parseUrlData(href)
			if err then
				return false, err
			end

			subsections[counter] = { href, name }
		end)
		if counter == 0 then
			subsections = nil
		else
			totalSubsections = counter
		end
		local isSubsection = #navigation_bar > 3

		local totalPages = tonumber(string.match(body, htmlChunk.totalPages))
		if not totalPages then
			return nil, errorString.internal
		end

		counter = 0
		_, lastPage = this:getPage(forumUri.section .. path .. "&p=" .. totalPages)
		string.gsub(lastPage, htmlChunk.topic, function()
			counter = counter + 1
		end)

		local totalTopics = ((totalPages - 1) * 30) + (counter - (totalSubsections and 1 or 0))

		local fixedTopics = 0
		string.gsub(lastPage, enums.topicIcon.postit, function()
			fixedTopics = fixedTopics + 1
		end)

		local icon = string.match(body, htmlChunk.icon)
		icon = enums.sectionIcon(icon) or icon

		return {
			f = location.f,
			s = location.s,
			navbar = navigation_bar,
			name = navigation_bar[#navigation_bar][2],
			hasSubsections = not not totalSubsections,
			totalSubsections = totalSubsections,
			subsections = subsections,
			isSubsection = isSubsection,
			parent = (isSubsection and (navigation_bar[#navigation_bar - 1]) or nil),
			pages = totalPages,
			totalTopics = totalTopics,
			fixedTopics = fixedTopics,
			community = (community and enums.community[community] or nil),
			icon = icon
		}
	end
	--[[@
		@desc Creates a topic.
		@param title<string> The title of the topic
		@param message<string> The initial message of the topic
		@param location<table> The location where the topic should be created. Fields 'f' and 's' are needed.
		@returns boolean Whether the topic was created or not
		@returns string if #1, `topic's url`, else `Result string` or `Error message`
	]]
	self.createTopic = function(self, title, message, location)
		assertion("createTopic", "string", 1, title)
		assertion("createTopic", "string", 2, message)
		assertion("createTopic", "table", 3, location)

		if not location.f or not location.s then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
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
		@desc Answers a topic.
		@param message<string> The answer
		@param location<table> The location where the message is. Fields 'f' and 't' are needed.
		@returns boolean Whether the post was created or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.answerTopic = function(self, message, location)
		assertion("answerTopic", "string", 1, message)
		assertion("answerTopic", "table", 2, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ "message_reponse", message }
		}
		local success, data = this:performAction(forumUri.cTopic, postData, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Edits a message content.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param message<string> The new message
		@param location<table> The location where the message should be edited. Fields 'f' and 't' are needed.
		@returns boolean Whether the message content was edited or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.editTopicAnswer = function(self, messageId, message, location)
		assertion("editTopicAnswer", { "number", "string" }, 1, messageId)
		assertion("editTopicAnswer", "string", 2, message)
		assertion("editTopicAnswer", "table", 3, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self:getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return false, err
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ 'm', messageId },
			{ "message", message }
		}
		local success, data = this:performAction(forumUri.eMsg, postData, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
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
		@returns string if #1, `poll's url`, else `Result string` or `Error message`
	]]
	self.createPoll = function(self, title, message, pollResponses, location, settings)
		assertion("createPoll", "string", 1, title)
		assertion("createPoll", "string", 2, message)
		assertion("createPoll", "table", 3, pollResponses)
		assertion("createPoll", "table", 4, location)
		assertion("createPoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return false, errorString.no_poll_responses
		end

		if not location.f or not location.s then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
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

		local success, data = this:performAction(forumUri.cTopic, postData, forumUri.nPoll .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Gets all the options of a poll.
		@param location<table> The location of the poll. Fields 'f' and 't' are needed.
		@returns table|nil Poll options, if any is found. The indexes are `id` and `value`.
		@returns string|nil Error message
	]]
	self.getPollOptions = function(self, location)
		assertion("getPollOptions", "table", 1, location)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_required_fields_private, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this:getPage((isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t)))
		
		local options = { }

		if string.find(body, "\"po\"") then -- Check if the topic is a poll
			local counter = 0
			string.gsub(body, htmlChunk.pollOption, function(t, id, value)
				if t == "radio" or t == "checkbox" then
					counter = counter + 1
					options[counter] = {
						id = id
						value = value
					}
				end
			end)

			return options
		end
		return nil, errorString.not_poll
	end
	--[[@
		@desc Answers a poll.
		@param option<int,table,string> The poll option to be selected. You can insert its ID or its text (highly recommended). For multiple options polls, use a table with `ints` or `strings`.
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
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_required_fields_private, "'co'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local url = (isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t))

		local optionIsString = type(option) == "string"
		if optionIsString or (type(option) == "table" and type(option[1]) == "string") then
			local options, err = self:getPollOptions(location)
			if err then
				return false, err
			end

			if optionIsString then
				local index = table.search(options, option, "value")
				if not index then
					return false, errorString.poll_option_not_found
				end
				option = options[index].id
			else
				local tmpSet = table.createSet(options, "value")
				for i = 1, #option do
					if tmpSet[options[i]] then
						options[i] = tmpSet[options[i]].id
					else
						return false, errorString.poll_option_not_found
					end
				end
			end
		end

		if not pollId then
			local head, body = this:getPage(pollId)

			pollId = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.poll))
			if not pollId then
				return false, errorString.not_poll
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
	--[[@
		@desc Likes a message.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@returns boolean Whether the like was recorded or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.likeMessage = function(self, messageId, location)
		assertion("likeMessage", { "number", "string" }, 1, messageId)
		assertion("likeMessage", "table", 2, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self:getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return false, err
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ 'm', messageId }
		}
		local success, data = this:performAction(forumUri.like, postData, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end

	-- > Moderation
	--[[@
		@desc Updates a topic state, location and parameters.
		@desc The available data are:
		@desc string `title` -> Topic's title
		@desc boolean `postit` -> Whether the topic should be fixed or not
		@desc string|int `state` -> The topic's state. An enum from `enums.displayState` (index or value)
		@param data<table> The new topic data
		@param location<table> The location where the topic is. Fields 'f' and 't' are needed.
		@returns boolean Whether the topic was updated or not
		@returns string if #1, `topic's url`, else `Result string` or `Error message`
	]]
	self.updateTopic = function(self, data, location)
		assertion("updateTopic", "table", 1, data)
		assertion("updateTopic", "table", 2, location)

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local topic = this:getTopic(location)
		local postit = data.postit
		if postit == nil then
			postit = topic.postit
		end
		if data.state then
			if type(data.state) == "string" then
				if not enums.displayState[data.state] then
					return false, errorString.invalid_enum .. " (data.state)"
				end
				data.state = enums.displayState[data.state]
			else
				if not table.search(enums.displayState, data.state) then
					return false, errorString.enum_out_of_range .. " (data.state)"
				end
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ "titre", (data.title or topic.title) },
			{ "postit", (postit and "on" or '') }
			{ "etat", (data.state or topic.state) },
			{ 's', (data.s or topic.s) }
		}
		local success, data = this:performAction(forumUri.uTopic, postData, forumUri.eTopic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Reports an element. (e.g: message, profile)
		@param element<string,int> The element type. An enum from `enums.element` (index or value)
		@param elementId<int,string> The element id.
		@param reason<string> The report reason.
		@param location?<table> The location of the report. If it's a forum message the field 'f' is needed, if it's a private message the field 'co' is needed.
		@returns boolean Whether the report was recorded or not
		@returns string `Result string` or `Error message`
	]]
	self.reportElement = function(self, element, elementId, reason, location)
		assertion("reportElement", { "string", "number" }, 1, element)
		assertion("reportElement", { "number", "string" }, 2, elementId)
		assertion("reportElement", "string", 3, reason)
		assertion("reportElement", { "table", "nil" }, 4, location)

		if type(element) == "string" then
			if not enums.element[element] then
				return false, errorString.invalid_enum
			end
			element = enums.element[element]
		else
			if not table.search(enums.element, element) then
				return false, errorString.enum_out_of_range
			end
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		location = location or { }
		local link, err
		if element == enums.element.message then
			-- Message ID
			if not location.f or not location.t then
				return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			if type(elementId) == "string" then
				elementId, err = self:getMessage(elementId, location)
				if elementId then
					elementId = elementId.id
				else
					return false, err
				end
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		elseif element == enums.element.tribe then
			-- Tribe ID
			link = forumUri.tribe .. "?tr=" .. elementId
		elseif element == enums.element.profile then
			-- User ID
			if type(elementId) == "string" then
				local err
				elementId, err = self:getProfile(elementId)
				if err then
					return false, err
				end
				elementId = elementId.id
			end
			link = forumUri.profile .. "?pr=" .. elementId -- (Can be the ID too)
		elseif element == enums.element.private_message then
			-- Private Message, Message ID
			if not location.co then
				return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'co'")
			end
			if type(elementId) == "string" then
				elementId, err = self:getMessage(elementId, location)
				if elementId then
					elementId = elementId.id
				else
					return false, err
				end
			end
			link = forumUri.conversation .. "?co=" .. location.co
		elseif element == enums.element.poll then
			-- Poll ID
			if not location.f then
				return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			if type(elementId) == "string" then
				return false, errorString.poll_id
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		elseif element == enums.element.image then
			-- Image ID
			if type(elementId) == "number" then
				return false, errorString.image_id
			end
			link = forumUri.userImg .. "?im=" .. elementId
		else
			return false, errorString.unaivalable_enum 
		end

		location.f = (location.f or 0)
		local postData = {
			{ 'f', location.f },
			{ "te", element },
			{ "ie", elementId },
			{ "raison", reason }
		}
		return this:performAction(forumUri.report, postData, link)
	end
	--[[@
		@desc Changes the state of the message. (e.g: active, moderated)
		@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`.
		@param messageState<string,int> The message state. An enum from `enums.messageState` (index or value)
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param reason?<string> The reason for changing the message state
		@returns boolean Whether the message(s) state was(were) changed or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.changeMessageState = function(self, messageId, messageState, location, reason)
		assertion("changeMessageState", { "number", "table", "string" }, 1, messageId)
		assertion("changeMessageState", { "string", "number" }, 2, messageState)
		assertion("changeMessageState", "table", 3, location)
		assertion("changeMessageState", { "string", "nil" }, 4, reason)

		if type(messageState) == "string" then
			if not enums.messageState[messageState] then
				return false, errorString.invalid_enum
			end
			messageState = enums.messageState[messageState]
		else
			if not table.search(enums.messageState, messageState) then
				return false, errorString.enum_out_of_range
			end
		end

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				messageId = { self:getMessage(messageId, location).id }
			end

			for i = 1, #messageId do
				messageId[i] = self:getMessage(messageId[i], location).id
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ "messages", table.concat(messageId, separator.forumData) },
			{ "etat", messageState },
			{ "raison", (reason or '') }
		}
		local success, data = this:performAction(forumUri.moderate, postData, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Changes the restriction state for a message.
		@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`.
		@param contentState<string> An enum from `enums.contentState` (index or value)
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@returns boolean Whether the message content state was changed or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.changeMessageContentState = function(self, messageId, contentState, location)
		assertion("changeMessageContentState", { "number", "table", "string" }, 1, messageId)
		assertion("changeMessageContentState", "string", 2, contentState)
		assertion("changeMessageContentState", "table", 3, location)

		if type(contentState) == "string" then
			if not enums.contentState[contentState] then
				return false, errorString.invalid_enum
			end
			contentState = enums.contentState[contentState]
		else
			if not table.search(enums.contentState, contentState) then
				return false, errorString.enum_out_of_range
			end
		end

		if not location.f or not location.t then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				messageId = { self:getMessage(messageId, location).id }
			end

			for i = 1, #messageId do
				messageId[i] = self:getMessage(messageId[i], location).id
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 't', location.t },
			{ "messages", table.concat(messageId, separator.forumData) },
			{ "restreindre", contentState }
		}
		local success, data = this:performAction(forumUri.manageRestriction, postData, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end

	-- > Tribe
	--[[@
		@desc Gets the data of a tribe.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@returns table|nil The tribe data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getTribe = function(self, tribeId)
		assertion("getTribe", { "number", "nil" }, 1, tribeId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return false, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local head, body = this:getPage(forumUri.tribe .. "?tr=" .. tribeId)

		local fa = tonumber(string.match(body, string.format(htmlChunk.hidden, htmlChunk.favorite)))

		local name = string.match(body, htmlChunk.title)
		local creationDate, community = string.match(body, htmlChunk.profileDateAndCommunity)
		local recruitment = string.match(body, htmlChunk.recruitment)
		
		local leaders, counter = { }, 0
		-- Some tribes may have more than one leader
		string.gsub(body, htmlChunk.tribeLeader, function(name, discriminator)
			counter = counter + 1
			leaders[counter] = name .. discriminator
		end)

		local greetingMessage = string.match(body, htmlChunk.greetingMessage)
		if greetingMessage then
			greetingMessage = string.gsub(greetingMessage, "<br ?/?>", '\n')
		end
		local presentation = string.match(body, htmlChunk.tribePresentation)

		return {
			id = tribeId,
			name = name,
			creationDate = creationDate,
			community = enums.community[community],
			recruitment = enums.recruitmentState[string.lower(recruitment)],
			leaders = leaders,
			greetingMessage = greetingMessage,
			presentation = presentation,
			isFavorited = not not fa,
			favoriteId = fa
		}
	end
	--@ Private function
	local getTribeMembers
	getTribeMembers = function(self, tribeId, pageNumber, _countMembers)
		local head, body = this:getPage(forumUri.tribeMembers .. "?tr=" .. tribeId .. "&p=" .. math.max(1, pageNumber))

		local count, totalPages
		if _countMembers then
			count, totalPages = tonumber(string.match(body, htmlChunk.countMembers)), 1
			if not count then
				return false, errorString.internal
			end

			if count == 30 then
				totalPages = tonumber(string.match(body, htmlChunk.totalPages)) or 1
				if totalPages > 1 then
					local _, data = this:getPage(forumUri.tribeMembers .. "?tr=" .. tribeId .. "&p=" .. totalPages)
					count = tonumber(string.match(body, htmlChunk.countMembers))
					if not count then
						return false, errorString.internal
					end
					count = count + ((totalPages - 1) * 30)
				end
			end
		end

		local members = {
			_pages = totalPages,
			_count = count
		}
		if pageNumber == 0 then
			local tmp, err
			for i = 1, totalPages do
				tmp, err = getTribeMembers(tribeId, i)
				if err then
					return false, err
				end

				table.add(members, tmp)
			end

			return members
		end

		local counter = 0
		if tribeId == this.tribeId then
			string.gsub(body, htmlChunk.tribeMember .. ".-" .. htmlChunk.tribeRank .. ".-" .. htmlChunk.msTime, function(community, name, discriminator, rank, jointDate)
				counter = counter + 1
				members[counter] = {
					name = name .. discriminator,
					community = enums.community[community],
					rank = rank,
					jointTime = jointDate
				}
			end)
		else
			local displaysRanks = not not string.find(body, htmlChunk.tribeRanks)
			if displaysRanks then
				string.gsub(body, htmlChunk.tribeMember .. ".-" .. htmlChunk.tribeRank, function(community, name, discriminator, rank)
					counter = counter + 1
					members[counter] = {
						name = name .. discriminator,
						community = enums.community[community],
						rank = rank
					}
				end)
			else
				string.gsub(body, htmlChunk.tribeMember, function(community, name, discriminator)
					counter = counter + 1
					members[counter] = {
						name = name .. discriminator,
						community = enums.community[community]
					}
				end)
			end
		end

		return members
	end
	--[[@
		@desc Gets the members of a tribe.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@param pageNumber?<int> The list page (case the tribe has more than 30 members). To list ALL members, use `0`. (default = 1)
		@returns table|nil The names of the tribe ranks. Total pages at `_pages`, total members at `_count`.
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeMembers = function(self, tribeId, pageNumber)
		assertion("getTribeMembers", { "number", "nil" }, 1, tribeId)
		assertion("getTribeMembers", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return false, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		return getTribeMembers(self, tribeId, pageNumber, true)
	end
	--[[@
		@desc Gets the ranks of a tribe, if possible.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@returns table|nil The names of the tribe ranks
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeRanks = function(self, tribeId)
		assertion("getTribeRanks", { "number", "nil" }, 1, tribeId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return false, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local head, body = this:getPage(forumUri.tribeMembers .. "?tr=" .. tribeId)

		local data = string.match(body, htmlChunk.tribeRanks)
		if not data then
			return false, errorString.no_right
		end

		local ranks, counter = { }, 0
		string.gsub(data, htmlChunk.tribeRank, function(name)
			counter = counter + 1
			ranks[counter] = name
		end)

		return ranks
	end
	--@ Private function
	local getTribeHistory
	getTribeHistory = function(self, tribeId, pageNumber, _getPageNumber)
		local head, body = this:getPage(forumUri.tribeHistory .. "?tr=" .. tribeId .. "&p=" .. math.max(1, pageNumber))

		local totalPages
		if _getPageNumber then
			totalPages = tonumber(string.match(body, htmlChunk.totalPages)) or 1
		end

		local history = {
			_pages = totalPages
		}
		if pageNumber == 0 then
			local tmp, err
			for i = 1, totalPages do
				tmp, err = getTribeHistory(tribeId, i)
				if err then
					return false, err
				end

				table.add(history, tmp)
			end

			return history
		end

		local counter = 0
		string.gsub(body, htmlChunk.msTime .. ".-" .. htmlChunk.tribeHistory, function(timestamp, log)
			counter = counter + 1
			history[counter] = {
				log = log,
				timestamp = tonumber(timestamp)
			}
		end)

		return history
	end
	--[[@
		@desc Gets the history logs of a tribe, if possible.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@param pageNumber?<int> The page number of the history. To list ALL the history, use `0`. (default = 1)
		@returns table|nil The history logs. Total pages at `_pages`.
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeHistory = function(self, tribeId, pageNumber)
		assertion("getTribeHistory", { "number", "nil" }, 1, tribeId)
		assertion("getTribeHistory", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return false, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		return getTribeHistory(self, tribeId, pageNumber, true)
	end
	--[[@
		@desc Updates the account's tribe greeting message.
		@param message<string> The new message
		@returns boolean Whether the tribe's greeting message was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateTribeGreetingMessage = function(self, message)
		assertion("updateTribeGreetingMessage", "string", 1, message)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.tribeId then
			return false, errorString.no_tribe
		end

		local postData = {
			{ "tr", this.tribeId },
			{ "message_jour", message }
		}
		return this:performAction(forumUri.uTribeMsg, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@desc Updates the account's tribe's parameters.
		@desc The available parameters are:
		@desc boolean `greeting_message` -> Whether the tribe's profile should display the tribe's greeting message or not
		@desc boolean `ranks` -> Whether the tribe's profile should display the tribe ranks or not
		@desc boolean `logs` -> Whether the tribe's profile should display the history logs or not
		@desc boolean `leader` -> Whether the tribe's profile should display the tribe leaders message or not
		@param parameters<table> The parameters.
		@returns boolean Whether the new tribe parameter settings were set or not
		@returns string `Result string` or `Error message`
	]]
	self.updateTribeParameters = function(self, parameters)
		assertion("updateTribeParameters", "table", 1, parameters)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.tribeId then
			return false, errorString.no_tribe
		end

		local postData = {
			{ "tr", this.tribeId }
		}
		if type(parameters.greeting_message) == "boolean" and parameters.greeting_message then
			postData[#postData + 1] = { "message_jour_public", "on" }
		end
		if type(parameters.ranks) == "boolean" and parameters.ranks then
			postData[#postData + 1] = { "rangs_publics", "on" }
		end
		if type(parameters.logs) == "boolean" and parameters.logs then
			postData[#postData + 1] = { "historique_public", "on" }
		end
		if type(parameters.leader) == "boolean" and parameters.leader then
			postData[#postData + 1] = { "chefs_publics", "on" }
		end

		return this:performAction(forumUri.uTribeParam, postData, forumUri.profile .. "?tr=" .. this.tribeId)
	end
	--[[@
		@desc Updates the account's tribe profile.
		@desc The available data are:
		@desc string|int `community` -> Account's tribe community. An enum from `enums.community` (index or value)
		@desc string|int `recruitment` -> Account's tribe recruitment state. An enum from `enums.recruitmentState` (index or value)
		@desc string `presentation` -> Account's tribe profile's presentation
		@param data<table> The data
		@returns boolean Whether the tribe's profile was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateTribeProfile = function(self, data)
		assertion("updateTribeProfile", "table", 1, data)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.tribeId then
			return false, errorString.no_tribe
		end

		local postData = {
			{ "tr", this.tribeId }
		}

		if data.community then
			if type(data.community) == "string" then
				-- Check if community is valid first
			end
			postData[#postData + 1] = { "communaute", data.community }
		else
			postData[#postData + 1] = { "communaute", 1 } -- xx
		end
		if data.recruitment then
			if type(data.recruitment) == "string" then
				if not enums.recruitmentState[data.recruitment] then
					return false, errorString.invalid_enum .. " (recruitment)"
				end
				data.recruitment = enums.recruitmentState[data.recruitment]
			else
				if not table.search(enums.recruitmentState, data.recruitment) then
					return false, errorString.enum_out_of_range .. " (recruitment)"
				end
			end
			postData[#postData + 1] = { "recrutement", data.recruitment }
		end
		if data.presentation then
			postData[#postData + 1] = { "b_presentation", "on" }
			postData[#postData + 1] = { "presentation", data.presentation }
		end

		return this:performAction(forumUri.uTribe, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@desc Removes the logo of the account's tribe.
		@returns boolean Whether the logo was removed or not
		@returns string `Result string` or `Error message`
	]]
	self.removeTribeLogo = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.tribeId then
			return false, errorString.no_tribe
		end

		local postData = {
			{ "tr", this.tribeId }
		}
		return this:performAction(forumUri.remLogo, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@desc Creates a section.
		@desc The available data are:
		@desc string `name` -> Section's name
		@desc string `icon` -> Section's icon. An enum from `enums.sectionIcon` (index or value)
		@desc string `description` -> Section's description
		@desc int `min_characters` -> Minimum characters needed for a message in the new section
		@param data<table> The new section data
		@param location<table> The location where the section will be created. Field 'f' is needed, 's' is needed if it's a sub-section.
		@returns boolean Whether the section was created or not
		@returns string if #1, `section's url`, else `Result string` or `Error message`
	]]
	self.createSection = function(self, data, location)
		assertion("createSection", "table", 1, data)
		assertion("createSection", "table", 2, location)

		if not location.f then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f'")
		end

		if not data.name or not data.icon or not data.description or not data.min_characters then
			return false, string.format(errorString.no_required_fields, "data { 'name', 'icon', 'description', 'min_characters' }")
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if type(data.icon) == "string" then
			if not enums.sectionIcon[data.icon] then
				return false, errorString.invalid_enum
			end
			data.icon = enums.sectionIcon[data.icon]
		else
			if not table.search(enums.sectionIcon, data.icon) then
				return false, errorString.enum_out_of_range
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 's', (location.s or '') },
			{ "tr" (location.s and '' or this.tribeId) },
			{ "nom", data.name },
			{ "icone", data.icon },
			{ "description", data.description },
			{ "caracteres", data.min_characters }
		}
		local success, data = this:performAction(forumUri.cSection, postData, forumUri.nSection .. "?f=" .. location.f .. (location.s and ("&s=" .. location.s) or ("&tr=" .. this.tribeId)))
		return returnRedirection(success, data)
	end
	--[[@
		@desc Updates a section.
		@desc The available data are:
		@desc string `name` -> Section's name
		@desc string `icon` -> The section's icon. An enum from `enums.sectionIcon` (index or value)
		@desc string `description` -> Section's description
		@desc int `min_characters` -> Minimum characters needed for a message in the new section
		@desc string|int `state` -> The section's state (e.g.: open, closed). An enum from `enums.displayState` (index or value)
		@desc int `parent` -> The parent section if the updated section is a sub-section. (default = 0)
		@param data<table> The updated section data
		@param location<table> The section location. Fields 'f' and 's' are needed.
		@returns boolean Whether the section was updated or not
		@returns string if #1, `section's url`, else `Result string` or `Error message`
	]]
	self.updateSection = function(self, data, location)
		assertion("updateSection", "table", 1, data)
		assertion("updateSection", "table", 2, location)

		if not location.f or not location.s then
			return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not data.min_characters or not data.state then
			return false, string.format(errorString.no_required_fields, "data { 'min_characters', 'state' }")
		end

		if data.icon then
			if type(data.icon) == "string" then
				if not enums.sectionIcon[data.icon] then
					return false, errorString.invalid_enum .. " (data.icon)"
				end
				data.icon = enums.sectionIcon[data.icon]
			else
				if not table.search(enums.sectionIcon, data.icon) then
					return false, errorString.enum_out_of_range .. " (data.icon)"
				end
			end
		end
		
		if type(data.state) == "string" then
			if not enums.displayState[data.state] then
				return false, errorString.invalid_enum .. " (data.state)"
			end
			data.state = enums.displayState[data.state]
		else
			if not table.search(enums.displayState, data.state) then
				return false, errorString.enum_out_of_range .. " (data.state)"
			end
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local section = self:getSection(location)
		local postData = {
			{ 'f', location.f },
			{ 's', location.s },
			{ "nom", (data.name or section.name) },
			{ "icone", (data.icon or section.icon) },
			{ "description", data.description },
			{ "caracteres", data.min_characters },
			{ "etat", data.state },
			{ "parent", (data.parent or section.parent.s or location.s) }
		}
		local success, data = this:performAction(forumUri.uSection, postData, forumUri.eSection .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end
	--[[@
		@desc Sets the permissions of each rank for a specific section on the tribe forums.
		@desc The available permissions are `canRead`, `canAnswer`, `canCreateTopic`, `canModerate`, and `canManage`.
		@desc Each one of them must be a table of IDs (`int` or `string`) of the ranks that this permission should be allowed.
		@desc To allow _non-members_, use `enums.misc.non_member` or `"non_member"`.
		@param permissions<table> The permissions
		@param location<table> The section location. The fields 'f', 't' and 'tr' are needed.
		@returns boolean Whether the new permissions were set or not
		@returns string `Result string` or `Error message`
	]]
	self.setTribeSectionPermissions = function(self, permissions, location)
		assertion("setTribeSectionPermissions", "table", 1, permissions)
		assertion("setTribeSectionPermissions", "table", 2, location)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		if not this.tribeId then
			return false, errorString.no_tribe
		end

		local ranks = this:getTribeRank(location) -- [i] = { id, name }
		local ranks_by_id = table.createSet(ranks, 1) -- [id] = { id, name }
		local ranks_by_name = table.createSet(ranks, 2) -- [name] = { id, name }

		local indexes = { "canRead", "canAnswer", "canCreateTopic", "canModerate", "canManage" }

		local defaultPermission = { ranks[1][1] }

		-- Checks for duplicates, transform strings in IDs, adds the leader id if necessary
		for i = 1, #indexes do
			if permissions[indexes[i]] then
				local perms, permsSet = { }, { }
				local hasLeader = false

				for j = 1, #permissions[indexes[i]] do
					if type(permissions[indexes[i]][j]) == "string" then
						if permissions[indexes[i]][j] == "non_member" then
							permissions[indexes[i]][j] = enums.misc.non_member
						else
							permissions[indexes[i]][j] = ranks_by_name[permissions[indexes[i]][j]][1]
						end
						if not permissions[indexes[i]][j] then
							return false, errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
						end
					end

					if not hasLeader and permissions[indexes[i]][j] == ranks[1][1] then
						hasLeader = true
					end

					if not ranks_by_id[permissions[indexes[i]][j]] then
						if permissions[indexes[i]][j] ~= enums.misc.non_member then
							return false, errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
						end
					end
					if not permsSet[permissions[indexes[i]][j]] then
						permsSet[permissions[indexes[i]][j]] = true
						perms[#perms + 1] = permissions[indexes[i]][j]
					end
				end
				if not hasLeader then
					permissions[indexes[i]][#permissions[indexes[i]] + 1] = ranks[1][1]
				end
			else
				permissions[indexes[i]] = defaultPermission
			end
		end

		local postData = {
			{ 'f', location.f },
			{ 's', location.s },
			{ "tr", this.tribeId },
			{ "droitLire", table.concat(permissions.canRead, separator.forumData) },
			{ "droitRepondre", table.concat(permissions.canAnswer, separator.forumData) },
			{ "droitCreerSujet", table.concat(permissions.canCreateTopic, separator.forumData) },
			{ "droitModerer", table.concat(permissions.canModerate, separator.forumData) },
			{ "droitGerer", table.concat(permissions.canManage, separator.forumData) }
		}
		return this:performAction(forumUri.uSectionPerm, postData, forumUri.eSectionPerm .. "?f=" .. location.f .. "&s=" .. location.s)
	end

	-- > Micepix
	--@ Private function
	local getAccountImages
	getAccountImages = function(self, pageNumber, _getPageNumber)
		local head, body = this:getPage(forumUri.clientGallery .. "?pr=" .. this.userId .. "&p=" .. pageNumber)

		local totalPages
		if _getPageNumber then
			totalPages = tonumber(string.match(body, htmlChunk.totalPages)) or 1
		end

		local images = {
			_pages = totalPages
		}
		if pageNumber == 0 then
			local tmp, err
			for i = 1, totalPages do
				tmp, err = getAccountImages(i)
				if err then
					return false, err
				end

				table.add(images, tmp)
			end

			return images
		end

		local images, counter = { }, 0
		string.gsub(body, htmlChunk.imageInfo .. ".-" .. htmlChunk.msTime, function(code, _, timestamp)
			counter = counter + 1
			images[counter] = {
				imageId = code,
				timestamp = tonumber(timestamp)
			}
		end)

		return images
	end
	--[[@
		@desc Gets the images that were hosted in your account.
		@param pageNumber?<int> The page number of the gallery. To list ALL the gallery, use `0`. (default = 1)
		@returns table|nil The data of the images. Total pages at `_pages`.
		@returns nil|string The message error, if any occurred
	]]
	self.getAccountImages = function(self, pageNumber)
		assertion("getImages", { "number", "nil" }, 1, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return false, errorString.not_connected
		end

		return getAccountImages(self, pageNumber, true)
	end
	--[[@
		@desc Gets the latest images that were hosted on Micepix.
		@param quantity?<int> The quantity of images needed. Must be a number multiple of 16. (default = 16)
		@returns table|nil The data of the images.
		@returns nil|string The message error, if any occurred
	]]
	self.getLatestImages = function(self, quantity)
		assertion("getLatestImages", { "number", "nil" }, 1, quantity)

		quantity = quantity or 16

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local r = quantity % 16
		if r > 0 then
			quantity = quantity - r + 16
		end

		local head, body, lastImage
		local pat = htmlChunk.imageInfo .. ".-" .. htmlChunk.msTime

		local images, counter = { }, 0
		for i = 1, quantity, 16 do
			head, body = this:getPage(forumUri.gallery .. (lastImage and ("?im=" .. lastImage) or ""))

			string.gsub(body, pat, function(code, name, timestamp)
				counter = counter + 1
				images[counter] = {
					imageId = code,
					author = self.formatNickname(name),
					timestamp = tonumber(timestamp)
				}
				lastImage = code
			end)
		end

		return images
	end
	--[[@
		@desc Deletes an image from the account's micepix.
		@param imageId<string> The image id
		@returns boolean Whether the image was deleted or not
		@returns string `Result string` or `Error message`
	]]
	self.deleteMicepixImage = function(self, imageId)
		assertion("deleteMicepixImage", "string", 1, imageId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "im", imageId }
		}
		return this:performAction(forumUri.remImg, postData, forumUri.userImg .. "?im=" .. imageId)
	end

	-- > Miscellaneous
	--[[@
		@desc Gets the topics created by a user.
		@param userName?<string,int> User name or id. (default = Client's account id)
		@returns table|nil The list of topics, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getCreatedTopics = function(self, userName)
		assertion("getCreatedTopics", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local head, body = this:getPage(forumUri.topicStarted .. "?pr=" .. (userName or this.userId))

		local topics, counter = { }, 0
		string.gsub(body, htmlChunk.commu .. ".-" .. htmlChunk.listedTopic .. ".- on " .. htmlChunk.msTime, function(community, topic, lastMessage, creationDate)
			counter = counter + 1
			topics[counter] = {
				location = self.parseUrlData(topic),
				totalMessages = tonumber(lastMessage),
				community = enums.community[community],
				creationDate = tonumber(creationDate)
			}
		end)

		return topics
	end
	--[[@
		@desc Gets the last posts of a user.
		@param pageNumber?<int> The page number of the last posts list. (default = 1)
		@param userName?<string,int> User name or id. (default = Client's account id)
		@returns table|nil The list of posts, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getLastPosts = function(self, pageNumber, userName)
		assertion("getLastPosts", { "number", "nil" }, 1, pageNumber)
		assertion("getLastPosts", { "string", "number", "nil" }, 2, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local head, body = this:getPage(forumUri.posts .. "?pr=" .. (userName or this.userId) .. "&p=" .. (pageNumber or 1))

		local totalPages = tonumber(string.match(body, htmlChunk.totalPages)) or 1

		local posts, counter = {
			_pages = totalPages
		}, 0
		string.gsub(body, htmlChunk.messageHref .. htmlChunk.msTime, function(post, postId, timestamp)
			counter = counter + 1
			posts[counter] = {
				location = self.parseUrlData(post),
				post = tonumber(postId),
				timestamp = tonumber(timestamp)
			}
		end)

		return posts
	end
	--[[@
		@desc Gets the account's friendlist.
		@returns table|nil The friendlist, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getFriendlist = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		local head, body = this:getPage(forumUri.friends .. "?pr=" .. this.userId)

		local friends, counter = { }, 0
		string.gsub(body, htmlChunk.nickname, function(name, discriminator)
			counter = counter + 1
			friends[counter] = name .. discriminator
		end)

		return friends
	end
	--[[@
		@desc Gets the account's blacklist.
		@returns table|nil The blacklist, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getBlacklist = function(self)
		if not this.isConnected then
			return false, errorString.not_connected
		end

		local head, body = this:getPage(forumUri.blacklist .. "?pr=" .. this.userId)

		local blacklist, counter = { }, 0
		string.gsub(body, htmlChunk.blacklistName, function(name, discriminator)
			counter = counter + 1
			blacklist[counter] = name .. discriminator
		end)

		return blacklist
	end
	--[[@
		@desc Gets the latest messages sent by admins.
		@returns table|nil The list of posts, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getDevTracker = function(self)
		local head, body = this:getPage(forumUri.tracker)

		local posts, counter = { }, 0
		string.gsub(body, htmlChunk.tracker, function(content)
			local navBar = string.match(content, htmlChunk.navBar)
			if not navBar then
				return nil, errorString.internal
			end

			local navigation_bar, community = { }
			local _counter = 0

			local err
			string.gsub(navBar, htmlChunk.navBarFragments, function(href, code)
				href, err = self.parseUrlData(href)
				if err then
					return false, err
				end
				
				_counter = _counter + 1
				local html, name = string.match(code, htmlChunk.navBarSplitContent)
				if html then
					navigation_bar[_counter] = {
						location = href,
						name = name
					}

					if not community then
						community = string.match(html, htmlChunk.commu)
					end
				else
					navigation_bar[_counter] = {
						location = href,
						name = code
					}
				end
			end)

			local postId = tonumber(string.sub(navigation_bar[_counter].name, 2))
			navigation_bar[_counter] = nil

			local messageHtml, timestamp, admin = string.match(content, htmlChunk.msgHtml .. ".-" .. htmlChunk.msTime .. ".-" .. htmlChunk.adminName)

			counter = counter + 1
			posts[counter] = {
				navbar = navigation_bar,
				post = postId,
				messageHtml = messageHtml,
				timestamp = tonumber(timestamp),
				author = admin .. "#0001"
			}
		end)

		return posts
	end
	--[[@
		@desc Adds a user as friend.
		@param userName<string> The user to be added
		@returns boolean Whether the user was added or not
		@returns string `Result string` or `Error message`
	]]
	self.addFriend = function(self, userName)
		assertion("addFriend", "string", 1, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "nom", userName }
		}
		return this:performAction(forumUri.addFriend, postData, forumUri.friends .. "?pr=" .. this.userId)
	end
	--[[@
		@desc Adds a user in the blacklist.
		@param userName<string> The user to be blacklisted
		@returns boolean Whether the user was blacklisted or not
		@returns string `Result string` or `Error message`
	]]
	self.blacklistUser = function(self, userName)
		assertion("blacklistUser", "string", 1, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "nom", userName }
		}
		return this:performAction(forumUri.ignoreUser, postData, forumUri.blacklist .. "?pr=" .. this.userId)
	end
	--[[@
		@desc Adds a user in the blacklist.
		@param userName<string> The user to be blacklisted
		@returns boolean Whether the user was blacklisted or not
		@returns string `Result string` or `Error message`
	]]
	self.unblacklistUser = function(self, userName)
		assertion("unblacklistUser", "string", 1, userName)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "nom", userName }
		}
		return this:performAction(forumUri.remBlacklist, postData, forumUri.blacklist .. "?pr=" .. this.userId)
	end
	--[[@
		@desc Favorites an element. (e.g: topic, tribe)
		@param element<string,int> The element type. An enum from `enums.element` (index or value)
		@param elementId<int> The element id.
		@param location?<table> The location of the report. If it's a forum topic the fields 'f' and 't' are needed.
		@returns boolean Whether the element was favorited or not
		@returns string `Result string` or `Error message`
	]]
	self.favoriteElement = function(self, element, elementId, location)
		assertion("favoriteElement", { "string", "number" }, 1, element)
		assertion("favoriteElement", "number", 2, elementId)
		assertion("favoriteElement", "table", 3, location)

		if type(element) == "string" then
			if not enums.element[element] then
				return false, errorString.invalid_enum
			end
			element = enums.element[element]
		else
			if not table.search(enums.element, element) then
				return false, errorString.enum_out_of_range
			end
		end

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local link
		if element == enums.element.topic then
			-- Topic ID
			if not location.f or not location.t then
				return false, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			link = forumUri.topic .. forumUri.favTopics
		elseif element == enums.element.tribe then
			-- Tribe ID
			link = forumUri.tribe .. forumUri.favTribes
		else
			return false, errorString.unaivalable_enum
		end

		location.f = (location.f or 0)
		local postData = {
			{ 'f', location.f },
			{ "te", element },
			{ "ie", elementId }
		}
		return this:performAction(forumUri.fav, postData, link)
	end
	--[[@
		@desc Unfavorites an element.
		@param favoriteId<int,string> The element favorite-id.
		@returns boolean Whether the element was unfavorited or not
		@returns string `Result string` or `Error message`
	]]
	self.unfavoriteElement = function(self, favoriteId)
		assertion("unfavoriteElement", { "number", "string" }, 1, favoriteId)

		if not this.isConnected then
			return false, errorString.not_connected
		end

		local postData = {
			{ "fa", favoriteId }
		}
		return this:performAction(forumUri.unfav, postData, forumLink .. forumUri.favTopics)
	end
	--[[@
		@desc Lists the members of a specific role.
		@param role<string,int<> The role id. An enum from `enums.listRole` (index or value)
		@returns table|nil The list, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getStaffList = function(self, role)
		assertion("getStaffList", { "string", "number" }, 1, role)

		if type(role) == "string" then
			if not enums.listRole[role] then
				return nil, errorString.invalid_enum
			end
			role = enums.listRole[role]
		else
			if not table.search(enums.listRole, role) then
				return nil, errorString.enum_out_of_range
			end
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local sucess, result = this:getPage(forumUri.staffAjax .. "?role=" .. role)
		local data, counter = { }, 0
		string.gsub(result, htmlChunk.staff, function(name, discriminator)
			counter = counter + 1
			data[counter] = name .. discriminator
		end)

		return data
	end

	return self
end, enums