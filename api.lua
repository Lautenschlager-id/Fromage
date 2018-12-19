--[[ Dependencies ]]--
-- Performs HTTP(S) requests
local http = require("coro-http")
-- Encoding
local base64 = require("base64")
-- Necessary enumerations
local enumerations = require("enumerations")

--[[ Private Enumerations ]]--
local cookieState = {
	login       = 0, -- Get all cookies
	after_login = 1, -- Get all cookies after login
	action      = 2  -- ^, except the ones in the `nonActionCookie` set
}

local nonActionCookie = {
	["JSESSIONID"] = true,
	["token"]      = true,
	["token_date"] = true
}

local separator = {
	cookie     = "; ",
	forum_data = "§#§",
	file       = "\r\n"
}

local forumUri = {
    index                      = "index",
    acc                        = "account",
    login                      = "login",
    identification             = "identification",
    disconnection              = "deconnexion",
    get_cert                   = "get-certification",
    set_cert                   = "set-certification",
    set_email                  = "set-email",
    set_pw                     = "set-password",
    profile                    = "profile",
    update_avatar              = "update-profile-avatar",
    update_profile             = "update-profile",
    remove_avatar              = "remove-profile-avatar",
    update_parameters          = "update-user-parameters",
    conversations              = "conversations",
    conversation               = "conversation",
    new_dialog                 = "new-dialog",
    create_dialog              = "create-dialog",
    new_discussion             = "new-discussion",
    create_discussion          = "create-discussion",
    new_private_poll           = "new-private-poll",
    answer_conversation        = "answer-conversation",
    move_conversation          = "move-conversations",
    move_all_conversations     = "move-all-conversations",
    close_discussion           = "close-discussion",
    reopen_discussion          = "reopen-discussion",
    leave_discussion           = "quit-discussion",
    invite_discussion          = "invite-discussion",
    kick_member                = "kick-discussion-member",
    answer_private_poll        = "answer-conversation-poll",
    topic                      = "topic",
    new_topic                  = "new-topic",
    create_topic               = "create-topic",
    edit_message               = "edit-topic-message",
    message_history            = "tribulle-frame-topic-message-history",
    new_poll                   = "new-forum-poll",
    answer_poll                = "answer-forum-poll",
    like_message               = "like-message",
    edit_topic                 = "edit-topic",
    update_topic               = "update-topic",
    report                     = "report-element",
    moderate                   = "moderate-selected-topic-messages",
    manage_message_restriction = "manage-selected-topic-messages-restriction",
    tribe                      = "tribe",
    tribe_members              = "tribe-members",
    tribe_history              = "tribe-history",
    update_tribe_message       = "update-tribe-greeting-message",
    update_tribe_parameters    = "update-tribe-parameters",
    update_tribe               = "update-tribe",
    upload_logo                = "update-tribe-logo",
    remove_logo                = "remove-tribe-logo",
    section                    = "section",
    new_section                = "new-section",
    create_section             = "create-section",
    edit_section               = "edit-section",
    update_section             = "update-section",
    edit_section_permissions   = "edit-section-permissions",
    update_section_permissions = "update-section-permissions",
    search                     = "search",
    view_user_image            = "view-user-image",
    user_images_grid           = "user-images-grid-ajax",
    images_gallery             = "gallery-images-ajax",
    user_images                = "user-images-home",
    upload_image               = "upload-user-image",
    remove_image               = "remove-user-image",
    topics_started             = "topics-started",
    posts                      = "posts",
    favorite_topics            = "favorite-topics",
    friends                    = "friends",
    add_friend                 = "add-friend",
    blacklist                  = "blacklist",
    ignore_user                = "add-ignored",
    remove_blacklisted         = "remove-ignored",
    favorite_tribes            = "favorite-tribes",
    tracker                    = "dev-tracker",
    add_favorite               = "add-favourite",
    remove_favorite            = "remove-favourite",
    staff                      = "staff-ajax",
    edit                       = "edit",
    quote                      = "citer",
    element_id                 = "ie",
    poll_id                    = "po",
    favorite_id                = "fa",
    tribe_forum                = "tribe-forum"
}

local htmlChunk = {
    secret_keys               = '<input type="hidden" name="(.-)" value="(.-)">',
    poll_option               = '<label class="(.-) "> +<input type="%1" name="reponse_" id="reponse_(%d+)" value="%2" .-/> +(.-) +</label>',
    hidden_value              = '<input type="hidden" name="%s" value="(%%d+)">',
    community                 = 'pays/(..)%.png',
    ms_time                   = 'data%-afficher%-secondes.->(%d+)',
    nickname                  = '(%S+)<span class="nav%-header%-hashtag">(#(%d+))',
    total_pages               = '"input%-pagination".-max="(%d+)"',
    post                      = '<div id="m%d',
    message                   = 'cadre_message_sujet_(%%d+).-id="m%d"(.-"%%s_message.-</div>)',
    message_data              = 'class="coeur".-(%d+).-message_%d+">(.-)</div>%s+</div>%s+</div>%s+</td>%s+</tr>.-edit_message_%d+.->(.-)</div>',
    edition_timestamp         = 'cadre%-message%-dates.-(%d+)',
    private_message           = '<div id="m%d" (.-</div>%%s+</div>%%s+</div>%%s+</td>%%s+</tr>)',
    message_content           = 'citer_message_%d+.->(.-)',
    private_message_data      = '<.-id="message_(%d+)">(.-)</div>%s+</div>%s+</div>%s+</td>%s+</tr>',
    navigation_bar            = 'barre%-navigation.->(.-)</ul>',
    navigaton_bar_sections    = '<a.-href="(.-)".->%s*(.-)%s*</a>',
    navigaton_bar_sec_content = '^<(.+)>%s*(.+)%s*$',
    date                      = '(%d+/%d+/%d+)',
    profile_data              = 'Messages: </span>(%-?%d+).-Prestige: </span>(%d+).-Level: </span>(%d+)',
    profile_gender            = 'Gender :.- (%S+)%s+<br>',
    profile_birthday          = 'Birthday :</span> ',
    profile_location          = 'Location :</span> (.-)  <br>',
    profile_tribe             = 'cadre%-tribu%-nom">(.-)</span>.-tr=(%d+)',
    profile_avatar            = 'http://avatars%.atelier801%.com/%d+/%d+%.%a+%?%d+',
    profile_soulmate          = 'Soul mate :</span>.-',
    subsection                = '"cadre%-section%-titre%-mini.-(section.-)".- (.-) </a>',
    profile_presentation      = 'cadre%-presentation">%s*(.-)%s*</div></div></div>',
    topic_div                 = '<div class="row">',
    section_icon              = 'sections/(.-)%.png',
    title                     = '<title>(.-)</title>',
    conversation_icon         = 'cadre%-sujet%-titre"><img (.-)</span>',
    recruitment               = 'Recruitment : (.-)<',
    greeting_message          = '<h4>Greeting message</h4> (.+)$',
    tribe_presentation        = 'cadre%-presentation"> (.-) </div>',
    blacklist_name            = 'cadre%-ignore%-nom">(.-)</span>',
    tribe_rank_list           = '<h4>Ranks</h4>(.-)</div>%s+</div>',
    tribe_rank                = '<div class="rang%-tribu"> (.-) </div>',
    total_entries             = '(%d+) entries',
    moderate_message          = 'cadre%-message%-modere%-texte">by ([^,]+)[^:]*:?(.*)%]<',
    tribe_log                 = '<td> (.-) </td>',
    message_history_log       = 'class="hidden"> (.-) </div>',
    image_id                  = '?im=(%w+)"',
    last_post                 = '<a href="(topic%?.-)".->%s+(.-)%s+</a></li>.-%1.-#m(%d+)">',
    created_topic_data        = 'href="(topic%?f=%d+&t=%d+).-".->%s+([^>]+)%s+</a>.-%2.-m(%d+)',
    tracker                   = '(.-)</div>%s+</div>',
    message_html              = 'Message</a></span> :%s+(.-)%s*</div>%s+</td>%s+</tr>',
    admin_name                = 'cadre%-type%-auteur%-admin">(.-)</span>',
    favorite_topics           = '<td rowspan="2">(.-)</td>%s+<td rowspan="2">',
    section_topic             = 'href="topic.-t=(%d+).-">%s+(.-)%s+</a>%s+</td>',
    tribe_list                = '<li class="nav%-header">(.-)</li>.-%?tr=(%d+)"',
    search_list               = '<a href="(topic%?.-)".->%s+(.-)%s+</a></li>',
    message_post_id           = 'numero%-message".-#(%d+)',
    profile_id                = 'profile%?pr=(.-)"',
    tribe_section_id          = '"section%?f=(%d+)&s=(%d+)"',
    empty_section             = '<div class="aucun%-resultat">Empty</div>'
}

local errorString = {
    secret_key_not_found    = "Secret keys could not be found.",
    already_connected       = "This instance is already connected, disconnect first.",
    not_connected           = "This instance is not connected yet, connect first.",
    no_poll_responses       = "Missing poll responses. There must be at least two responses.",
    invalid_forum_url       = "Invalid Atelier801's url.",
    no_url_location         = "Missing location.",
    no_required_fields      = "The fields %s are needed.",
    no_url_location_private = "The fields %s are needed if the object is private.",
    not_poll                = "Invalid topic. Poll not detected.",
    internal                = "Internal error.",
    poll_option_not_found   = "Invalid poll option.",
    not_verified            = "This instance has not a certificate yet. Valid the account first.",
    enum_out_of_range       = "Enum value out of range.",
    invalid_enum            = "Invalid enum.",
    poll_id                 = "A poll id can not be a string.",
    image_id                = "An image id can not be a number.",
    invalid_date            = "Invalid date format. Expected: dd/mm/yyyy",
    unaivalable_enum        = "This function does not accept this enum.",
    invalid_id              = "Invalid id.",
    no_tribe                = "This instance does not have a tribe.",
    no_right                = "You don't have rights to see this info.",
    invalid_file            = "Provided file does not exist.",
    invalid_extension       = "Provided file url or name does not have a valid extension.",
    invalid_user            = "The user does not exist or was not found."
}

local fileExtensions = { "png", "jpg", "jpeg", "gif" }

local boundaries = { }
do
	boundaries[1] = "LautenschlagerAPI_" .. os.time()
	boundaries[2] = "--" .. boundaries[1]
	boundaries[3] = boundaries[2] .. "--"
end

--[[ Data and Aux Functions ]]--
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

os.readFile = function(file)
	local file = io.open(file, 'r')
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end
table.add = function(src, list)
	local len = #src
	for i = 1, #list do
		src[len + i] = list[i]
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

local assertion = function(name, etype, id, value)
	local t = type(value)

	if type(etype) == "table" then
		local names, counter = { }, 0
		for k, v in next, etype do
			if v == t then
				return
			else
				counter = counter + 1
				names[counter] = v
			end
		end
		error("bad argument #" .. id .. " to '" .. name .. "' (" .. table.concat(names, " | ") .. " expected, got " .. t .. ")")
	else
		assert(t == etype, "bad argument #" .. id .. " to '" .. name .. "' (" .. etype .. " expected, got " .. t .. ")")
	end
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
local encodeUrl = function(url)
	if url == "" then return "" end

	local out = {}

	string.gsub(url, '.', function(letter)
		out[#out + 1] = string.upper(string.format("%02x", string.byte(letter)))
	end)

	return "%" .. table.concat(out, '%')
end
local getExtension = function(f)
	local extension
	for i = 1, #fileExtensions do
		if string.find(f, "%." .. fileExtensions[i]) then
			extension = fileExtensions[i]
			break
		end
	end
	if extension == "jpg" then
		extension = "jpeg"
	end
	return extension
end
local getFile = function(f)
	if string.find(f, "https?://") then
		local head, body = http.request("GET", f)
		return body
	else
		f = os.readFile(f)
		if f then
			return f
		end
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
local isEnum = function(value, enum, showName, getIndex, stringValues)
	showName = showName and (" (" .. showName .. ")") or ''

	if not stringValues then
		if type(value) == "string" then
			if not enumerations[enum][value] then
				return nil, errorString.invalid_enum .. showName
			end
			if getIndex then
				return value
			else
				return enumerations[enum][value]
			end
		else
			if not enumerations[enum](value) then
				return nil, errorString.enum_out_of_range .. showName
			end
			if getIndex then
				return enumerations[enum](value)
			else
				return value
			end
		end
	else
		if enumerations[enum][value] then
			if getIndex then
				return value
			else
				return enumerations[enum][value]
			end
		elseif enumerations[enum](value) then
			if getIndex then
				return enumerations[enum](value)
			else
				return value
			end
		else
			return nil, errorString.invalid_enum .. showName
		end
	end
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

-- Debug function
table.tostring = function(list, depth, stop)
	depth = depth or 1
	stop = stop or 0

	local out = {}
	
	for k, v in next, list do
		out[#out + 1] = string.rep("\t", depth) .. ("["..(type(k) == "number" and k or "'" .. k .. "'").."]") .. "="
		local t = type(v)
		if t == "table" then
			out[#out] = out[#out] .. ((stop > 0 and depth > stop) and tostring(v) or table.tostring(v, depth + 1, stop - 1))
		elseif t == "number" or t == "boolean" then
			out[#out] = out[#out] .. tostring(v)
		elseif t == "string" then
			out[#out] = out[#out] .. string.format("%q", v)
		else
			out[#out] = out[#out] .. "nil"
		end
	end
	
	return "{\r\n" .. table.concat(out, ",\r\n") .. "\r\n" .. string.rep("\t", depth - 1) .. "}"
end

--[[ Class ]]--
return function()
	-- Internal
	local this = {
		-- Whether the account is connected or not
		isConnected = false,
		-- The nickname of the account, if it's connected.
		userName = nil,
		userId = nil,
		tribeId = nil,
		cookieState = cookieState.login,
		-- Account cookies
		cookies = { },
		-- Whether the account has validated its account with a code
		hasCertificate = false
	}
	-- External
	local self = { }

	--[[ System ]]--
	-- Sets the account cookies
	this.setCookies = function(header)
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
		if this.cookieState == cookieState.after_login then
			this.cookieState = cookieState.action
		end
	end

	-- Gets the default headers for every request
	this.getHeaders = function()
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
	this.getSecretKeys = function(uri)
		local head, body = http.request("GET", forumLink .. (uri or forumUri.index), this.getHeaders())

		this.setCookies(head)
		return { string.match(body, htmlChunk.secret_keys ) }
	end

	-- Performs a post action on forums
	this.performAction = function(uri, postData, ajaxUri, file)
		local secretKeys = this.getSecretKeys(ajaxUri)
		if #secretKeys == 0 then
			return nil, errorString.secret_key_not_found
		end

		postData = postData or { }
		postData[#postData + 1] = secretKeys

		local headers = this.getHeaders()
		if ajaxUri then
			headers[4] = { "Accept", "application/json, text/javascript, */*; q=0.01" }
			headers[5] = { "X-Requested-With", "XMLHttpRequest" }
			headers[6] = { "Content-Type", (file and ("multipart/form-data; boundary=" .. boundaries[1]) or "application/x-www-form-urlencoded; charset=UTF-8") }
			headers[7] = { "Referer", forumLink .. ajaxUri }
			headers[8] = { "Connection", "keep-alive" }
		end

		local body, head = { }
		for index, data in next, postData do
			body[index] = data[1] .. "=" .. encodeUrl(data[2])
		end

		head, body = http.request("POST", forumLink .. uri, headers, (file and (string.gsub(file, "/KEY(%d)/", function(id)
			return secretKeys[tonumber(id)] 
		end)) or (table.concat(body, '&'))))

		this.setCookies(head)

		return true, body
	end

	-- Gets a page using the headers of the account
	this.getPage = function(url)
		return http.request("GET", forumLink .. url, this.getHeaders())
	end

	--> Private function
	local getList, getBigList
	getBigList = function(pageNumber, uri, f, getTotalPages, _totalPages)
		local head, body = this.getPage(uri .. "&p=" .. math.max(1, pageNumber))

		if getTotalPages then
			_totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1
		end

		local out = {
			_pages = _totalPages
		}
		if pageNumber == 0 then
			local tmp, err
			for i = 1, _totalPages do
				tmp, err = getBigList(i, uri, f, false, _totalPages)
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
	getList = function(pageNumber, uri, f, html)
		return getBigList(pageNumber, uri, function(list, body)
			local counter = 0
			string.gsub(body, html, function(...)
				counter = counter + 1
				list[counter] = f(...)
			end)
		end, true)
	end

	local returnRedirection = function(success, data)
		if success then
			local link = string.match(data, '"redirection":"(.-)"')
			if link then
				return self.parseUrlData(link)
			end
		end

		return nil, data
	end

	-- > Tool
	--[[@
		@desc Parses the URL data.
		@param href<string> The uri and data to be parsed
		@returns table|nil Parsed data. The available indexes are: `uri`, `raw_data` and `data`
		@returns nil|string Error message
	]]
	self.parseUrlData = function(href)
		assertion("parseUrlData", "string", 1, href)

		local uri, data = string.match(href, "/?([^%?]+)%??(.*)$")
		if not uri then
			return nil, errorString.invalid_forum_url
		end
		
		local raw_data = data

		local data = { }
		string.gsub(raw_data, "([^&]+)=([^&#]+)", function(name, value)
			data[name] = tonumber(value) or value
		end)

		return {
			uri = uri,
			raw_data = raw_data,
			data = data
		}
	end
	--[[@
		@desc Gets the location of a section on forums based on its community.
		@param forum<int,string> The forum of the location. An enum from `enumerations.forum` (index or value)
		@param community<string,int> The location community. An enum from `enumerations.community` (index or value)
		@param section<string,int> The section of the location. An enum from `enumerations.section` (index or value)
		@returns table The location table. Fields `f` and `s`.
	]]
	self.getLocation = function(forum, community, section)
		assertion("getLocation", { "number", "string" }, 1, forum)
		assertion("getLocation", { "string", "number" }, 2, community)
		assertion("getLocation", { "string", "number" }, 3, section)

		local err
		forum, err = isEnum(forum, "forum", "#1")
		if err then return nil, err end
		community, err = isEnum(community, "community", "#2", true)
		if err then return nil, err end
		section, err = isEnum(section, "section", "#3", true)
		if err then return nil, err end

		return {
			f = forum,
			s = enumerations.location[community][forum][section]
		}
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
	--[[@
		@desc Checks whether the instance is connected to an account or not.
		@returns boolean Whether there's already a connection or not.
		@returns string|nil If #1, the user name
		@returns int|nil If #1, the user id
	]]
	self.isConnected = function()
		return this.isConnected, this.userName, this.userId
	end

	--[[ Methods ]]
	-- > Settings
	--[[@
		@file Settings
		@desc Connects to an account on Atelier801's forums.
		@param userName<string> account's user name
		@param userPassword<string> account's password
		@returns boolean Whether the account connected or not
		@returns string Result string
	]]
	self.connect = function(userName, userPassword)
		assertion("connect", "string", 1, userName)
		assertion("connect", "string", 2, userPassword)

		if this.isConnected then
			return nil, errorString.already_connected
		end

		local success, data = this.performAction(forumUri.identification, {
			{ "rester_connecte", "on" },
			{ "id", userName },
			{ "pass", getPasswordHash(userPassword) },
			{ "redirect", string.sub(forumLink, 1, -2) }
		}, forumUri.login)

		if success and string.sub(data, 2, 15) == '"supprime":"*"' then
			this.isConnected = true
			this.userName = userName
			this.cookieState = cookieState.after_login
			local pr = self.getProfile()
			this.userId = pr.id
			this.tribeId = pr.tribeId
		end

		return success, data
	end
	--[[@
		@file Settings
		@desc Disconnects from an account on Atelier801's forums.
		@returns boolean Whether the account disconnected or not
		@returns string Result string
	]]
	self.disconnect = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.disconnection, nil, forumUri.acc)

		if success and string.sub(data, 2, 15) == '"supprime":"*"' then
			this.isConnected = false
			this.userName = nil
			this.cookieState = cookieState.login
			this.cookies = { }
			this.userId = nil
			this.tribeId = nil
		end

		return success, data
	end
	--[[@
		@file Settings
		@desc Sends a validation code to the account's e-mail.
		@returns boolean Whether the validation code was sent or not
		@returns string `Result string` or `Error message`
	]]
	self.requestValidationCode = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.get_cert, nil, forumUri.acc)
	end
	--[[@
		@file Settings
		@desc Submits the validation code to the forum to be validated.
		@param code<string> The validation code.
		@returns boolean Whether the validation code was sent to be validated or not
		@returns string `Result string` (Empty for success) or `Error message`
	]]
	self.submitValidationCode = function(code)
		assertion("submitValidationCode", "string", 1, code)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.set_cert, {
			{ "code", code }
		}, forumUri.acc)

		if success then
			this.hasCertificate = true
		end

		return success, data
	end
	--[[@
		@file Settings
		@desc Sets the new account's e-mail.
		@param email<string> The e-mail to be linked to your account
		@param registration?<boolean> Whether this is the first e-mail assigned to the account or not
		@returns boolean Whether the validation code was sent or not
		@returns string `Result string` or `Error message`
	]]
	self.setEmail = function(email, registration)
		assertion("setEmail", "string", 1, email)
		assertion("setEmail", { "boolean", "nil" }, 2, registration)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not registration then
			if not this.hasCertificate then
				return nil, errorString.not_verified
			end
		end

		return this.performAction(forumUri.set_email, {
			{ "mail", email }
		}, forumUri.acc)
	end
	--[[@
		@file Settings
		@desc Sets the new account's password.
		@param password<string> The new password
		@param disconnect?<boolean> Whether the account should be disconnect from all the dispositives or not. (default = false)
		@returns boolean Whether the new password was set or not
		@returns string `Result string` or `Error message`
	]]
	self.setPassword = function(password, disconnect)
		assertion("setPassword", "string", 1, password)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.hasCertificate then
			return nil, errorString.not_verified
		end

		local postData = {
			{ "mdp3", getPasswordHash(password) }
		}
		if disconnect then
			postData[2] = { "deco", "on" }
		end

		return this.performAction(forumUri.set_pw, postData, forumUri.acc)
	end

	-- > Profile
	--[[@
		@file Profile
		@desc Gets an user profile.
		@param userName?<string,int> User name or id. (default = Client's account name)
		@returns table|nil The profile data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getProfile = function(userName)
		assertion("getProfile", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			if not userName then
				return nil, errorString.not_connected
			end
		end

		userName = userName or this.userName
		local head, body = this.getPage(forumUri.profile .. "?pr=" .. encodeUrl(userName))

		local id = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.element_id))) -- Element id
		if not id then
			return nil, errorString.invalid_user
		end

		local name, hashtag, discriminator = string.match(body, htmlChunk.nickname)
		
		local highestRole = tonumber(discriminator)
		if highestRole == 0 then
			highestRole = nil
		end

		local registrationDate, community, messages, prestige, level = string.match(body, htmlChunk.date .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.profile_data)
		level = tonumber(level)
		
		local gender = string.match(body, htmlChunk.profile_gender)
		gender = gender and string.lower(gender) or "none"
		
		local location = string.match(body, htmlChunk.profile_location)

		local birthday = string.match(body, htmlChunk.profile_birthday .. htmlChunk.date)

		local presentation = string.match(body, htmlChunk.profile_presentation)
		
		local soulmate, soulmateDiscriminator = string.match(body, htmlChunk.profile_soulmate .. htmlChunk.nickname)
		if soulmate then
			soulmate = soulmate .. soulmateDiscriminator
		end
		
		local tribeName, tribeId = string.match(body, htmlChunk.profile_tribe)

		local avatar = string.match(body, htmlChunk.profile_avatar)

		return {
			id = tonumber(id),
			name = name .. hashtag,
			highestRole = highestRole,
			registrationDate = registrationDate,
			community = enumerations.community[community],
			totalMessages = tonumber(messages),
			totalPrestige = tonumber(prestige),
			level = level,
			title = enumerations.forumTitle[level],
			gender = enumerations.gender[gender],
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
		@file Profile
		@desc Updates the client's account profile picture.
		@param image<string> The new image. An URL or file name.
		@returns boolean Whether the new avatar was set or not
		@returns string `Result string` or `Error message`
	]]
	self.changeAvatar = function(image)
		assertion("changeAvatar", "string", 1, image)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local extension = getExtension(image)
		if not extension then
			return nil, errorString.invalid_extension
		end

		image = getFile(image)
		if not image then
			return nil, errorString.invalid_file
		end

		local file = {
			boundaries[2],
			'Content-Disposition: form-data; name="pr"',
			'',
			this.userId,
			boundaries[2],
			'Content-Disposition: form-data; name="fichier"; filename="Lautenschlager_id.' .. extension .. '"',
			"Content-Type: image/" .. extension,
			'',
			image,
			boundaries[2],
			'Content-Disposition: form-data; name="/KEY1/"',
			'',
			"/KEY2/",
			boundaries[3]
		}
		return this.performAction(forumUri.update_avatar, nil, forumUri.profile .. "?pr=" .. this.userId, table.concat(file, separator.file))
	end
	--[[@
		@file Profile
		@desc Updates the account's profile.
		@desc The available data are:
		@desc string|int `community` -> Account's community. An enum from `enumerations.community` (index or value)
		@desc string `birthday` -> The birthday date (dd/mm/yyyy)
		@desc string `location` -> The location
		@desc string|int `gender` -> Account's gender. An enum from `enumerations.gender` (index or value)
		@desc string `presentation` -> Profile's presentation
		@param data?<table> The data
		@returns boolean Whether the profile was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateProfile = function(data)
		assertion("updateProfile", { "table", "nil" }, 1, data)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local postData = {
			{ "pr", this.userId }
		}

		if data then
			local err
			if data.community then
				data.community, err = isEnum(data.community, "community", "data.community")
				if err then return nil, err end
				postData[#postData + 1] = { "communaute", data.community }
			else
				postData[#postData + 1] = { "communaute", enumerations.community.xx }
			end
			if data.birthday then
				if not isValidDate(data.birthday) then
					return nil, errorString.invalid_date .. " (data.birthday)"
				end
				postData[#postData + 1] = { "b_anniversaire", "on" }
				postData[#postData + 1] = { "anniversaire", data.birthday }
			end
			if data.location then
				postData[#postData + 1] = { "b_localisation", "on" }
				postData[#postData + 1] = { "localisation", data.location }
			end
			if data.gender then
				data.gender, err = isEnum(data.gender, "gender", "data.gender")
				if err then return nil, err end
				postData[#postData + 1] = { "b_genre", "on" }
				postData[#postData + 1] = { "genre", data.gender }
			end
			if data.presentation then
				postData[#postData + 1] = { "b_presentation", "on" }
				postData[#postData + 1] = { "presentation", data.presentation }
			end
		end

		return this.performAction(forumUri.update_profile, postData, forumUri.profile .. "?pr=" .. this.userId)
	end
	--[[@
		@file Profile
		@desc Removes the account's avatar.
		@returns boolean Whether the avatar was removed or not
		@returns string `Result string` or `Error message`
	]]
	self.removeAvatar = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.remove_avatar, {
			{ "pr", this.userId }
		}, forumUri.profile .. "?pr=" .. this.userId)
	end
	--[[@
		@file Profile
		@desc Updates the account parameters.
		@desc The available parameters are:
		@desc boolean `online` -> Whether the account should display if it's online or not
		@param parameters?<table> The parameters.
		@returns boolean Whether the new parameter settings were set or not
		@returns string `Result string` or `Error message`
	]]
	self.updateParameters = function(parameters)
		assertion("updateParameters", { "table", "nil" }, 1, parameters)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local postData = {
			{ "pr", this.userId }
		}
		if parameters and type(parameters.online) == "boolean" and parameters.online then
			postData[#postData + 1] = { "afficher_en_ligne", "on" }
		end

		return this.performAction(forumUri.update_parameters, postData, forumUri.profile .. "?pr=" .. this.userId)
	end

	-- > Private
	--[[@
		@file Private
		@desc Gets the data of a conversation.
		@param location<table> The conversation location. Field 'co' is needed.
		@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. (default = false)
		@returns table|nil The conversation data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getConversation = function(location, ignoreFirstMessage)
		assertion("getConversation", "table", 1, location)
		assertion("getConversation", { "boolean", "nil" }, 2, ignoreFirstMessage)

		if not location.co then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local path = "?co=" .. location.co
		local head, body = this.getPage(forumUri.conversation .. path)

		local po, pollOptions = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.poll_id))) -- Poll id
		if po then
			pollOptions = self.getPollOptions(location)
		end

		local title = string.match(body, htmlChunk.title)
		if not title then
			return nil, errorString.internal
		end

		local isPoll, isDiscussion, isPrivateMessage = not not po, false, false
		local titleIcon = string.match(body, htmlChunk.conversation_icon)
		if not titleIcon then
			return nil, errorString.internal
		end
		if not isPoll then
			isDiscussion = not not string.find(titleIcon, enumerations.topicIcon.private_discussion)
			isPrivateMessage = not isDiscussion
		end

		local isLocked = false
		if not isPrivateMessage then
			isLocked = not not string.find(titleIcon, enumerations.topicIcon.locked)
		end

		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local _, lastPage = this.getPage(forumUri.conversation .. path .. "&p=" .. totalPages)
		local counter = 0
		string.gsub(lastPage, htmlChunk.post, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		local firstMessage
		if not ignoreFirstMessage then
			local err
			firstMessage, err = self.getMessage('1', location)
			if not firstMessage then
				return nil, err
			end
		end

		return {
			co = location.co,
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
		@file Private
		@desc Creates a new private message.
		@param destinatary<string> The user who is going to receive the private message
		@param subject<string> The subject of the private message
		@param message<string> The content of the private message
		@returns boolean Whether the private message was created or not
		@returns string if #1, `private message's location`, else `Result string` or `Error message`
	]]
	self.createPrivateMessage = function(destinatary, subject, message)
		assertion("createPrivateMessage", "string", 1, destinatary)
		assertion("createPrivateMessage", "string", 2, subject)
		assertion("createPrivateMessage", "string", 3, message)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.create_dialog, {
			{ "destinataire", destinatary },
			{ "objet", subject },
			{ "message", message }
		}, forumUri.new_dialog)
		return returnRedirection(success, data)
	end
	--[[@
		@file Private
		@desc Creates a new private discussion.
		@param destinataries<table> The users who are going to be invited to the private discussion
		@param subject<string> The subject of the private discussion
		@param message<string> The content of the private discussion
		@returns boolean Whether the private discussion was created or not
		@returns string if #1, `private discussion's location`, else `Result string` or `Error message`
	]]
	self.createPrivateDiscussion = function(destinataries, subject, message)
		assertion("createPrivateDiscussion", "table", 1, destinataries)
		assertion("createPrivateDiscussion", "string", 2, subject)
		assertion("createPrivateDiscussion", "string", 3, message)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.create_discussion, {
			{ "destinataires", table.concat(destinataries, separator.forum_data) },
			{ "objet", subject },
			{ "message", message }
		}, forumUri.new_discussion)
		return returnRedirection(success, data)
	end
	--[[@
		@file Private
		@desc Creates a new private poll.
		@param destinataries<table> The users who are going to be invited to the private poll
		@param subject<string> The subject of the private poll
		@param message<string> The content of the private poll
		@param pollResponses<table> The poll response options
		@param settings?<table> The poll settings. The available indexes are: `multiple` and `public`.
		@returns boolean Whether the private poll was created or not
		@returns string if #1, `private poll's location`, else `Result string` or `Error message`
	]]
	self.createPrivatePoll = function(destinataries, subject, message, pollResponses, settings)
		assertion("createPrivatePoll", "table", 1, destinataries)
		assertion("createPrivatePoll", "string", 2, subject)
		assertion("createPrivatePoll", "string", 3, message)
		assertion("createPrivatePoll", "table", 4, pollResponses)
		assertion("createPrivatePoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return nil, errorString.no_poll_responses
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local postData = {
			{ "destinataires", table.concat(destinataries, separator.forum_data) },
			{ "objet", subject },
			{ "message", message },
			{ "sondage", "on" },
			{ "reponses", table.concat(pollResponses, separator.forum_data) }
		}
		if settings then
			if settings.multiple then
				postData[#postData + 1] = { "multiple", "on" }
			end
			if settings.public then
				postData[#postData + 1] = { "publique", "on" }
			end
		end

		local success, data = this.performAction(forumUri.create_discussion, postData, forumUri.new_private_poll)
		return returnRedirection(success, data)
	end
	--[[@
		@file Private
		@desc Answers a conversation.
		@param conversationId<int,string> The conversation id
		@param answer<string> The answer
		@returns boolean Whether the answer was posted or not
		@returns string if #1, `post's location`, else `Result string` or `Error message`
	]]
	self.answerConversation = function(conversationId, answer)
		assertion("answerConversation", { "number", "string" }, 1, conversationId)
		assertion("answerConversation", "string", 2, answer)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.answer_conversation, {
			{ "co", conversationId },
			{ "message_reponse", answer }
		}, forumUri.conversation .. "?co=" .. conversationId)
		return returnRedirection(success, data)
	end
	--[[@
		@file Private
		@desc Moves private conversations to the inbox or bin.
		@param inboxLocale<string,int> Where the conversation will be located. An enum from `enumerations.inboxLocale` (index or value)
		@param conversationId?<int,table> The id or IDs of the conversation(s) to be moved. `nil` for all.
		@returns boolean Whether the conversation was moved or not
		@returns string if #1, `location's url`, else `Result string` or `Error message`
	]]
	self.movePrivateConversation = function(inboxLocale, conversationId)
		conversationId = tonumber(conversationId) or conversationId
		assertion("movePrivateConversation", { "string", "number" }, 1, inboxLocale)

		local err
		inboxLocale, err = isEnum(inboxLocale, "inboxLocale", "#1")
		if err then return nil, err end

		local moveAll = false
		if inboxLocale == enumerations.inboxLocale.bin and not conversationId then
			conversationId = { }
			moveAll = true
		end
		
		assertion("movePrivateConversation", { "number", "table" }, 2, conversationId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(conversationId) == "number" then
			conversationId = { conversationId }
		end

		local postData = (not moveAll and {
			{ "conversations", table.concat(conversationId, separator.forum_data) },
			{ "location", inboxLocale }
		} or nil)
		return this.performAction((moveAll and forumUri.move_all_conversations or forumUri.move_conversation), postData, forumUri.conversations .. "?location=" .. inboxLocale)
	end
	--[[@
		@file Private
		@desc Changes the conversation state (open, closed).
		@param displayState<string,int> The conversation display state. An enum from `enumerations.displayState` (index or value)
		@param conversationId<int,string> The conversation id
		@returns boolean Whether the conversation display state was changed or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.changeConversationState = function(displayState, conversationId)
		assertion("changeConversationState", { "string", "number" }, 1, displayState)
		assertion("changeConversationState", { "number", "string" }, 2, conversationId)

		local err
		displayState, err = isEnum(displayState, "displayState", "#1", nil, true)
		if err then return nil, err end

		if displayState == enumerations.contentState.deleted then
			return nil, errorString.unaivalable_enum
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction((displayState == enumerations.displayState.active and forumUri.reopen_discussion or forumUri.close_discussion), {
			{ "co", conversationId }
		}, forumUri.conversation .. "?co=" .. conversationId)
	end
	--[[@
		@file Private
		@desc Leaves a private conversation.
		@param conversationId<int,string> The conversation id
		@returns boolean Whether the account left the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.leaveConversation = function(conversationId)
		assertion("leaveConversation", { "number", "string" }, 1, conversationId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.leave_discussion, {
			{ "co", conversationId }
		}, forumUri.conversation .. "?co=" .. conversationId)
	end
	--[[@
		@file Private
		@desc Invites an user to a private conversation.
		@param conversationId<int,string> The conversation id
		@param userName<string> The username to be invited
		@returns boolean Whether the username was added in the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.conversationInvite = function(conversationId, userName)
		assertion("conversationInvite", { "number", "string" }, 1, conversationId)
		assertion("conversationInvite", "string", 2, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.invite_discussion, {
			{ "co", conversationId },
			{ "destinataires", userName }
		}, forumUri.conversation .. "?co=" .. conversationId)
	end
	--[[@
		@file Private
		@desc Excludes a user from a conversation.
		@param conversationId<int,string> The conversation id
		@param userId<int,string> The user id or nickname
		@returns boolean Whether the user was excluded from the conversation or not
		@returns string if #1, `conversation's url`, else `Result string` or `Error message`
	]]
	self.kickConversationMember = function(conversationId, userId)
		assertion("kickConversationMember", { "number", "string" }, 1, conversationId)
		assertion("kickConversationMember", { "number", "string" }, 1, userId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(userId) == "string" then
			local err
			userId, err = self.getProfile(userId)
			if err then
				return nil, err
			end
			userId = userId.id
		end

		return this.performAction(forumUri.kick_member, {
			{ "co", conversationId },
			{ "pr", userId }
		}, forumUri.conversation .. "?co=" .. conversationId)
	end

	-- > Forum
	--[[@
		@file Forum
		@desc Gets the data of a message.
		@param postId<int,string> The post id (note: not the message id, but the #mID)
		@param location<table> The post topic or conversation location. Fields 'f' and 't' are needed for forum messages, field 'co' is needed for private message.
		@returns table|nil The message data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getMessage = function(postId, location)
		assertion("getMessage", { "number", "string" }, 1, postId)
		assertion("getMessage", "table", 2, location)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		postId = tonumber(postId)
		local pageNumber = math.ceil(postId / 20)

		local head, body = this.getPage((location.co and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)) .. "&p=" .. pageNumber)

		local id, post
		if not location.co then
			-- Forum message
			id, post = string.match(body, string.format(htmlChunk.message, postId, forumUri.edit))
			if not id then
				return nil, errorString.internal
			end

			local isModerated, moderatedBy, reason = false
			local timestamp, author, authorDiscriminator, _, prestige, msgHtml, content = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.message_data)
			if not timestamp then
				timestamp, author, authorDiscriminator, _, moderatedBy, reason = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.moderate_message)
				if not timestamp then
					return nil, errorString.internal
				end
				isModerated = true
			end
			local editTimestamp = string.match(post, htmlChunk.edition_timestamp)

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
				messageHtml = msgHtml,
				isEdited = not not editTimestamp,
				edit_timestamp = tonumber(editTimestamp),
				isModerated = isModerated,
				moderatedBy = moderatedBy,
				reason = reason
			}
		else
			-- Private message
			post = string.match(body, string.format(htmlChunk.private_message, postId))
			if not post then
				return nil, errorString.internal .. " (001)"
			end

			local timestamp, author, authorDiscriminator, _, id, msgHtml = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.private_message_data)
			if not timestamp then
				return nil, errorString.internal .. " (002)"
			end

			local content = string.match(post, htmlChunk.message_content)

			return {
				f = 0,
				co = location.co,
 				p = pageNumber,
				post = tostring(postId),
				timestamp = tonumber(timestamp),
				author = author .. authorDiscriminator,
				id = tonumber(id),
				content = content,
				messageHtml = msgHtml
			}
		end
	end
	--[[@
		@file Forum
		@desc Gets the data of a topic.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param ignoreFirstMessage?<boolean> Whether the data of the first message should be ignored or not. (default = false)
		@returns table|nil The topic data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getTopic = function(location, ignoreFirstMessage)
		assertion("getTopic", "table", 1, location)
		assertion("getTopic", { "boolean", "nil" }, 2, ignoreFirstMessage)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local path = "?f=" .. location.f .. "&t=" .. location.t
		local head, body = this.getPage(forumUri.topic .. path)

		local ie = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.element_id))) -- Element id
		local po, pollOptions = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.poll_id))) -- Poll id
		if po then
			pollOptions = self.getPollOptions(location)
		end

		local navBar = string.match(body, htmlChunk.navigation_bar)
		if not navBar then
			return nil, errorString.internal
		end

		local isFixed, isLocked, isDeleted = false, false, false
		local navigation_bar, community = { }
		
		local counter, lastHtml = 0, ''

		local err
		string.gsub(navBar, htmlChunk.navigaton_bar_sections, function(href, code)
			href, err = self.parseUrlData(href)
			if err then
				return nil, err
			end
			
			counter = counter + 1
			local html, name = string.match(code, htmlChunk.navigaton_bar_sec_content)
			if html then
				lastHtml = html
				navigation_bar[counter] = {
					location = href,
					name = name
				}

				if not community then
					community = string.match(html, htmlChunk.community)
				end
			else
				navigation_bar[counter] = {
					location = href,
					name = code
				}
			end
		end)

		isFixed = not not string.find(lastHtml, enumerations.topicIcon.postit)
		isLocked = not not string.find(lastHtml, enumerations.topicIcon.locked)
		isDeleted = not not string.find(lastHtml, enumerations.topicIcon.deleted)

		local fa = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.favorite_id)))
		
		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local _, lastPage = this.getPage(forumUri.topic .. path .. "&p=" .. totalPages)
		local counter = 0
		string.gsub(lastPage, htmlChunk.post, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		local firstMessage
		if not ignoreFirstMessage then
			firstMessage = self.getMessage('1', location)
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
			community = (community and enumerations.community[community] or nil),
			isPoll = not not po,
			pollId = po,
			pollOptions = pollOptions
		}
	end
	--[[@
		@file Forum
		@desc Gets the data of a section.
		@param location<table> The section location. Fields 'f' and 's' are needed.
		@returns table|nil The section data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getSection = function(location)
		assertion("getSection", "table", 1, location)

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local path = "?f=" .. location.f .. "&s=" .. location.s
		local head, body = this.getPage(forumUri.section .. path)

		local navBar = string.match(body, htmlChunk.navigation_bar)
		if not navBar then
			return nil, errorString.internal
		end

		local navigation_bar, community = { }
		local counter = 0

		local err
		string.gsub(navBar, htmlChunk.navigaton_bar_sections, function(href, code)
			href, err = self.parseUrlData(href)
			if err then
				return nil, err
			end

			counter = counter + 1
			local html, name = string.match(code, htmlChunk.navigaton_bar_sec_content)
			if html then
				navigation_bar[counter] = {
					location = href,
					name = name
				}

				if not community then
					community = string.match(html, htmlChunk.community)
				end
			else
				navigation_bar[counter] = {
					location = href,
					name = code
				}
			end
		end)

		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local counter, totalTopics = 0
		_, lastPage = this.getPage(forumUri.section .. path .. "&p=" .. totalPages)
		if string.find(lastPage, htmlChunk.empty_section) then
			totalTopics = 0
		else
			string.gsub(lastPage, htmlChunk.topic_div, function()
				counter = counter + 1
			end)

			local totalTopics = ((totalPages - 1) * 30) + (counter - (totalSubsections and 1 or 0))

			counter = 0
		end

		local subsections, totalSubsections = { }
		string.gsub(lastPage, htmlChunk.subsection, function(href, name)
			counter = counter + 1
			href, err = self.parseUrlData(href)
			if err then
				return nil, err
			end

			subsections[counter] = { href, name }
		end)
		if counter == 0 then
			subsections = nil
		else
			totalSubsections = counter
		end
		local isSubsection = #navigation_bar > 3

		local fixedTopics = 0
		string.gsub(lastPage, enumerations.topicIcon.postit, function()
			fixedTopics = fixedTopics + 1
		end)

		local icon = string.match(body, htmlChunk.section_icon)
		icon = enumerations.sectionIcon(icon) or icon

		return {
			f = location.f,
			s = location.s,
			navbar = navigation_bar,
			name = navigation_bar[#navigation_bar].name,
			hasSubsections = not not totalSubsections,
			totalSubsections = totalSubsections,
			subsections = subsections,
			isSubsection = isSubsection,
			parent = (isSubsection and (navigation_bar[#navigation_bar - 1]) or nil),
			pages = totalPages,
			totalTopics = totalTopics,
			fixedTopics = fixedTopics,
			community = (community and enumerations.community[community] or nil),
			icon = icon
		}
	end
	--[[@
		@file Forum
		@desc Gets the messages of a topic.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param pageNumber?<int> The topic page. To list ALL messages, use `0`. (default = 1)
		@param getAllInfo?<boolean> Whether the message data should be simple (ids only) or complete (getMessage). (default = true)
	]]
	self.getTopicMessages = function(location, pageNumber, getAllInfo)
		assertion("getTopicMessages", "table", 1, location)
		assertion("getTopicMessages", { "number", "nil" }, 2, pageNumber)
		assertion("getTopicMessages", { "boolean", "nil" }, 3, getAllInfo)

		pageNumber = pageNumber or 1
		getAllInfo = (getAllInfo == nil and true or getAllInfo)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return getBigList(pageNumber, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t, function(messages, body, pageNumber, totalPages)
			local post = (pageNumber - 1) * 20
			local counter = 0
			if getAllInfo then
				for i = post, (post + 20) do
					local msg = self.getMessage(post, location)
					if not msg then
						break -- End of the page
					end
					counter = counter + 1
					messages[counter] = msg
				end
			else
				string.gsub(body, string.format(htmlChunk.hidden_value, 'm'), function(id)
					counter = counter + 1
					messages[counter] = {
						f = location.f,
						t = location.t,
						p = pageNumber,
						post = tostring(post + counter),
						id = tonumber(id)
					}
				end)
			end
		end, true)
	end
	--[[@
		@file Forum
		@desc Gets the messages of a topic.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param pageNumber?<int> The topic page. To list ALL messages, use `0`. (default = 1)
		@param getAllInfo?<boolean> Whether the message data should be simple (ids only) or complete (getMessage). (default = true)
	]]
	self.getSectionTopics = function(location, pageNumber, getAllInfo)
		assertion("getSectionTopics", "table", 1, location)
		assertion("getSectionTopics", { "number", "nil" }, 2, pageNumber)
		assertion("getSectionTopics", { "boolean", "nil" }, 3, getAllInfo)

		pageNumber = pageNumber or 1
		getAllInfo = (getAllInfo == nil and true or getAllInfo)

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return getList(pageNumber, forumUri.section .. "?f=" .. location.f .. "&s=" .. location.s, function(id, title, timestamp)
			id = tonumber(id)

			if getAllInfo then
				local tpc, err = self.getTopic({ f = location.f, t = id }, true)
				if not tpc then
					return nil, err
				end

				return tpc
			else
				return {
					f = location.f,
					s = location.s,
					t = id,
					title = title,
					timestamp = tonumber(timestamp)
				}
			end
		end, htmlChunk.section_topic .. ".-" .. htmlChunk.ms_time)
	end
	--[[@
		@file Forum
		@desc Gets the edition logs of a message, if possible.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param location<table> The message location. Fields 'f' and 't' are needed.
		@returns table|nil The edition logs
		@returns nil|string The message error, if any occurred
	]]
	self.getMessageHistory = function(messageId, location)
		assertion("getMessageHistory", { "number", "string" }, 1, messageId)
		assertion("getMessageHistory", "table", 2, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self.getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return nil, err
			end
		end

		local head, body = this.getPage(forumUri.message_history .. "?forum=" .. location.f .. "&message=" .. messageId)

		local history, counter = { }, 0

		string.gsub(body, htmlChunk.message_history_log .. ".-" .. htmlChunk.ms_time, function(bbcode, timestamp)
			counter = counter + 1
			history[counter] = {
				bbcode = bbcode,
				timestamp = tonumber(timestamp)
			}
		end)

		return history
	end
	--[[@
		@file Forum
		@desc Creates a topic.
		@param title<string> The title of the topic
		@param message<string> The initial message of the topic
		@param location<table> The location where the topic should be created. Fields 'f' and 's' are needed.
		@returns boolean Whether the topic was created or not
		@returns string if #1, `topic's location`, else `Result string` or `Error message`
	]]
	self.createTopic = function(title, message, location)
		assertion("createTopic", "string", 1, title)
		assertion("createTopic", "string", 2, message)
		assertion("createTopic", "table", 3, location)

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.create_topic, {
			{ 'f', location.f },
			{ 's', location.s },
			{ "titre", title },
			{ "message", message }
		}, forumUri.new_topic .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end
	--[[@
		@file Forum
		@desc Answers a topic.
		@param message<string> The answer
		@param location<table> The location where the message is. Fields 'f' and 't' are needed.
		@returns boolean Whether the post was created or not
		@returns string if #1, `post's location`, else `Result string` or `Error message`
	]]
	self.answerTopic = function(message, location)
		assertion("answerTopic", "string", 1, message)
		assertion("answerTopic", "table", 2, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local success, data = this.performAction(forumUri.create_topic, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "message_reponse", message }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end
	--[[@
		@file Forum
		@desc Edits a message content.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param message<string> The new message
		@param location<table> The location where the message should be edited. Fields 'f' and 't' are needed.
		@returns boolean Whether the message content was edited or not
		@returns string if #1, `post's location`, else `Result string` or `Error message`
	]]
	self.editTopicAnswer = function(messageId, message, location)
		assertion("editTopicAnswer", { "number", "string" }, 1, messageId)
		assertion("editTopicAnswer", "string", 2, message)
		assertion("editTopicAnswer", "table", 3, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self.getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return nil, err
			end
		end

		local success, data = this.performAction(forumUri.edit_message, {
			{ 'f', location.f },
			{ 't', location.t },
			{ 'm', messageId },
			{ "message", message }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
		return returnRedirection(success, data)
	end
	--[[@
		@file Forum
		@desc Creates a new poll.
		@param title<string> The title of the poll
		@param message<string> The content of the poll
		@param pollResponses<table> The poll response options
		@param location<table> The location where the topic should be created. Fields 'f' and 's' are needed.
		@param settings?<table> The poll settings. The available indexes are: `multiple` and `public`.
		@returns boolean Whether the poll was created or not
		@returns string if #1, `poll's location`, else `Result string` or `Error message`
	]]
	self.createPoll = function(title, message, pollResponses, location, settings)
		assertion("createPoll", "string", 1, title)
		assertion("createPoll", "string", 2, message)
		assertion("createPoll", "table", 3, pollResponses)
		assertion("createPoll", "table", 4, location)
		assertion("createPoll", { "table", "nil" }, 5, settings)

		if #pollResponses < 2 then
			return nil, errorString.no_poll_responses
		end

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local postData = {
			{ 'f', location.f },
			{ 's', location.s },
			{ "titre", title },
			{ "message", message },
			{ "sondage", "on" },
			{ "reponses", table.concat(destinatary, separator.forum_data) }
		}
		if settings then
			if settings.multiple then
				postData[#postData + 1] = { "multiple", "on" }
			end
			if settings.public then
				postData[#postData + 1] = { "publique", "on" }
			end
		end

		local success, data = this.performAction(forumUri.create_topic, postData, forumUri.new_poll .. "?f=" .. location.f .. "&s=" .. location.s)
		return returnRedirection(success, data)
	end
	--[[@
		@file Forum
		@desc Gets all the options of a poll.
		@param location<table> The location of the poll. Fields 'f' and 't' are needed.
		@returns table|nil Poll options, if any is found. The indexes are `id` and `value`.
		@returns string|nil Error message
	]]
	self.getPollOptions = function(location)
		assertion("getPollOptions", "table", 1, location)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_required_fields_private, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage((isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t)))
		
		local options = { }

		if string.find(body, "\"" .. forumUri.poll_id .. "\"") then -- Check if the topic is a poll
			local counter = 0
			string.gsub(body, htmlChunk.poll_option, function(t, id, value)
				if t == "radio" or t == "checkbox" then
					counter = counter + 1
					options[counter] = {
						id = id,
						value = value
					}
				end
			end)

			return options
		end
		return nil, errorString.not_poll
	end
	--[[@
		@file Forum
		@desc Answers a poll.
		@param option<int,table,string> The poll option to be selected. You can insert its ID or its text (highly recommended). For multiple options polls, use a table with `ints` or `strings`.
		@param location<table> The location where the poll answer should be recorded. Fields 'f' and 't' are needed for forum poll, 'co' for private poll.
		@param pollId?<int> The poll id. It's obtained automatically if no value is given.
		@returns boolean Whether the poll option was recorded or not
		@returns string if #1, `poll's location`, else `Result string` or `Error message`
	]]
	self.answerPoll = function(option, location, pollId)
		assertion("answerPoll", { "number", "table", "string" }, 1, option)
		assertion("answerPoll", "table", 2, location)
		assertion("answerPoll", { "number", "nil" }, 3, pollId)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_required_fields_private, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local url = (isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or ("?f=" .. location.f .. "&t=" .. location.t))

		local optionIsString = type(option) == "string"
		if optionIsString or (type(option) == "table" and type(option[1]) == "string") then
			local options, err = self.getPollOptions(location)
			if err then
				return nil, err
			end

			if optionIsString then
				local index = table.search(options, option, "value")
				if not index then
					return nil, errorString.poll_option_not_found
				end
				option = options[index].id
			else
				local tmpSet = table.createSet(options, "value")
				for i = 1, #option do
					if tmpSet[options[i]] then
						options[i] = tmpSet[options[i]].id
					else
						return nil, errorString.poll_option_not_found
					end
				end
			end
		end

		if not pollId then
			local head, body = this.getPage(pollId)

			pollId = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.poll_id)))
			if not pollId then
				return nil, errorString.not_poll
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

		local success, data = this.performAction((isPrivatePoll and forumUri.answer_private_poll or forumUri.answer_poll), postData, url)
		return returnRedirection(success, data)
	end
	--[[@
		@file Forum
		@desc Likes a message.
		@param messageId<int,string> The message id. Use `string` if it's the post number.
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@returns boolean Whether the like was recorded or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.likeMessage = function(messageId, location)
		assertion("likeMessage", { "number", "string" }, 1, messageId)
		assertion("likeMessage", "table", 2, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(messageId) == "string" then
			local err
			messageId, err = self.getMessage(messageId, location)
			if messageId then
				messageId = messageId.id
			else
				return nil, err
			end
		end

		return this.performAction(forumUri.like_message, {
			{ 'f', location.f },
			{ 't', location.t },
			{ 'm', messageId }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
	end

	-- > Moderation
	--[[@
		@file Moderation
		@desc Updates a topic state, location and parameters.
		@desc The available data are:
		@desc string `title` -> Topic's title
		@desc boolean `postit` -> Whether the topic should be fixed or not
		@desc string|int `state` -> The topic's state. An enum from `enumerations.displayState` (index or value)
		@param data<table> The new topic data
		@param location<table> The location where the topic is. Fields 'f' and 't' are needed.
		@returns boolean Whether the topic was updated or not
		@returns string if #1, `topic's url`, else `Result string` or `Error message`
	]]
	self.updateTopic = function(data, location)
		assertion("updateTopic", "table", 1, data)
		assertion("updateTopic", "table", 2, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local topic = this.getTopic(location)
		local postit = data.postit
		if postit == nil then
			postit = topic.postit
		end

		local err
		data.state, err = isEnum(data.state, "displayState", "data.state")
		if err then return nil, err end

		return this.performAction(forumUri.update_topic, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "titre", (data.title or topic.title) },
			{ "postit", (postit and "on" or '') },
			{ "etat", (data.state or topic.state) },
			{ 's', (data.s or topic.s) }
		}, forumUri.edit_topic .. "?f=" .. location.f .. "&t=" .. location.t)
	end
	--[[@
		@file Moderation
		@desc Reports an element. (e.g: message, profile)
		@param element<string,int> The element type. An enum from `enumerations.element` (index or value)
		@param elementId<int,string> The element id.
		@param reason<string> The report reason.
		@param location?<table> The location of the report. If it's a forum message the field 'f' is needed, if it's a private message the field 'co' is needed.
		@returns boolean Whether the report was recorded or not
		@returns string `Result string` or `Error message`
	]]
	self.reportElement = function(element, elementId, reason, location)
		assertion("reportElement", { "string", "number" }, 1, element)
		assertion("reportElement", { "number", "string" }, 2, elementId)
		assertion("reportElement", "string", 3, reason)
		assertion("reportElement", { "table", "nil" }, 4, location)

		local err
		element, err = isEnum(element, "element")
		if err then return nil, err end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		location = location or { }
		local link, err
		if element == enumerations.element.message then
			-- Message ID
			if not location.f or not location.t then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			if type(elementId) == "string" then
				elementId, err = self.getMessage(elementId, location)
				if elementId then
					elementId = elementId.id
				else
					return nil, err
				end
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		elseif element == enumerations.element.tribe then
			-- Tribe ID
			link = forumUri.tribe .. "?tr=" .. elementId
		elseif element == enumerations.element.profile then
			-- User ID
			if type(elementId) == "string" then
				local err
				elementId, err = self.getProfile(elementId)
				if err then
					return nil, err
				end
				elementId = elementId.id
			end
			link = forumUri.profile .. "?pr=" .. elementId -- (Can be the ID too)
		elseif element == enumerations.element.private_message then
			-- Private Message, Message ID
			if not location.co then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'co'")
			end
			if type(elementId) == "string" then
				elementId, err = self.getMessage(elementId, location)
				if elementId then
					elementId = elementId.id
				else
					return nil, err
				end
			end
			link = forumUri.conversation .. "?co=" .. location.co
		elseif element == enumerations.element.poll then
			-- Poll ID
			if not location.f then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			if type(elementId) == "string" then
				return nil, errorString.poll_id
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		elseif element == enumerations.element.image then
			-- Image ID
			if type(elementId) == "number" then
				return nil, errorString.image_id
			end
			link = forumUri.view_user_image .. "?im=" .. elementId
		else
			return nil, errorString.unaivalable_enum 
		end

		return this.performAction(forumUri.report, {
			{ 'f', (location.f or 0) },
			{ "te", element },
			{ "ie", elementId },
			{ "raison", reason }
		}, link)
	end
	--[[@
		@file Moderation
		@desc Changes the state of the message. (e.g: active, moderated)
		@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`.
		@param messageState<string,int> The message state. An enum from `enumerations.messageState` (index or value)
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@param reason?<string> The reason for changing the message state
		@returns boolean Whether the message(s) state was(were) changed or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.changeMessageState = function(messageId, messageState, location, reason)
		assertion("changeMessageState", { "number", "table", "string" }, 1, messageId)
		assertion("changeMessageState", { "string", "number" }, 2, messageState)
		assertion("changeMessageState", "table", 3, location)
		assertion("changeMessageState", { "string", "nil" }, 4, reason)

		local err
		messageState, err = isEnum(messageState, "messageState")
		if err then return nil, err end

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				messageId = { self.getMessage(messageId, location).id }
			end

			for i = 1, #messageId do
				messageId[i] = self.getMessage(messageId[i], location).id
			end
		end

		return this.performAction(forumUri.moderate, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "messages", table.concat(messageId, separator.forum_data) },
			{ "etat", messageState },
			{ "raison", (reason or '') }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
	end
	--[[@
		@file Moderation
		@desc Changes the restriction state for a message.
		@param messageId<int,table,string> The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`.
		@param contentState<string> An enum from `enumerations.contentState` (index or value)
		@param location<table> The topic location. Fields 'f' and 't' are needed.
		@returns boolean Whether the message content state was changed or not
		@returns string if #1, `post's url`, else `Result string` or `Error message`
	]]
	self.changeMessageContentState = function(messageId, contentState, location)
		assertion("changeMessageContentState", { "number", "table", "string" }, 1, messageId)
		assertion("changeMessageContentState", "string", 2, contentState)
		assertion("changeMessageContentState", "table", 3, location)

		local err
		contentState, err = isEnum(contentState, "contentState", nil, true)
		if err then return nil, err end

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				messageId = { self.getMessage(messageId, location).id }
			end

			for i = 1, #messageId do
				messageId[i] = self.getMessage(messageId[i], location).id
			end
		end

		return this.performAction(forumUri.manage_message_restriction, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "messages", table.concat(messageId, separator.forum_data) },
			{ "restreindre", contentState }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
	end

	-- > Tribe
	--[[@
		@file Tribe
		@desc Gets the data of a tribe.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@returns table|nil The tribe data, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getTribe = function(tribeId)
		assertion("getTribe", { "number", "nil" }, 1, tribeId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local head, body = this.getPage(forumUri.tribe .. "?tr=" .. tribeId)

		local fa = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.favorite_id)))

		local name = string.match(body, htmlChunk.title)
		local creationDate, community = string.match(body, htmlChunk.date .. ".-" .. htmlChunk.community)
		local recruitment = string.match(body, htmlChunk.recruitment)
		
		local leaders, counter = { }, 0
		-- Some tribes may have more than one leader
		string.gsub(body, htmlChunk.nickname, function(name, discriminator)
			counter = counter + 1
			leaders[counter] = name .. discriminator
		end)

		counter = 0
		local tmp, greetingMessage, presentation = { }
		string.gsub(body, htmlChunk.tribe_presentation, function(data)
			counter = counter + 1
			tmp[counter] = data
		end)
		if counter == 2 then
			greetingMessage = string.match(tmp[1], htmlChunk.greeting_message)
			presentation = tmp[2]
		elseif counter == 1 then
			local data = string.match(tmp[1], htmlChunk.greeting_message)
			if data then
				greetingMessage = data
			else
				presentation = tmp[1]
			end
		end

		return {
			id = tribeId,
			name = name,
			creationDate = creationDate,
			community = enumerations.community[community],
			recruitment = enumerations.recruitmentState[string.lower(recruitment)],
			leaders = leaders,
			greetingMessage = greetingMessage,
			presentation = presentation,
			isFavorited = not not fa,
			favoriteId = fa
		}
	end
	--[[@
		@file Tribe
		@desc Gets the members of a tribe.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@param pageNumber?<int> The list page (case the tribe has more than 30 members). To list ALL members, use `0`. (default = 1)
		@returns table|nil The names of the tribe ranks. Total pages at `_pages`, total members at `_count`.
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeMembers = function(tribeId, pageNumber)
		assertion("getTribeMembers", { "number", "nil" }, 1, tribeId)
		assertion("getTribeMembers", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local uri = forumUri.tribe_members .. "?tr=" .. tribeId
		local totalPages, lastPageQuantity
		local members  = getBigList(pageNumber, uri, function(members, body, _pageNumber, _totalPages)
			local counter = 0
			if tribeId == this.tribeId then
				string.gsub(body, htmlChunk.community .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.tribe_rank .. ".-" .. htmlChunk.ms_time, function(community, name, discriminator, _, rank, jointDate)
					counter = counter + 1
					members[counter] = {
						name = name .. discriminator,
						community = enumerations.community[community],
						rank = rank,
						timestamp = tonumber(jointDate)
					}
				end)
			else
				local displaysRanks = not not string.find(body, htmlChunk.tribe_rank_list)
				if displaysRanks then
					string.gsub(body, htmlChunk.community .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.tribe_rank, function(community, name, discriminator, _, rank)
						counter = counter + 1
						members[counter] = {
							name = name .. discriminator,
							community = enumerations.community[community],
							rank = rank
						}
					end)
				else
					string.gsub(body, htmlChunk.community .. ".-" .. htmlChunk.nickname, function(community, name, discriminator)
						counter = counter + 1
						members[counter] = {
							name = name .. discriminator,
							community = enumerations.community[community]
						}
					end)
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
			local head, body = this.getPage(uri .. "&p=" .. totalPages)
			lastPageQuantity = tonumber(string.match(body, htmlChunk.total_entries))
			if not lastPageQuantity then
				return nil, errorString.internal
			end
		end

		members._count = ((totalPages - 1) * 30) + lastPageQuantity
		return members
	end
	--[[@
		@file Tribe
		@desc Gets the ranks of a tribe, if possible.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@returns table|nil The names of the tribe ranks
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeRanks = function(tribeId)
		assertion("getTribeRanks", { "number", "nil" }, 1, tribeId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local head, body = this.getPage(forumUri.tribe_members .. "?tr=" .. tribeId)

		local data = string.match(body, htmlChunk.tribe_rank_list)
		if not data then
			return nil, errorString.no_right
		end

		local ranks, counter = { }, 0
		string.gsub(data, htmlChunk.tribe_rank, function(name)
			counter = counter + 1
			ranks[counter] = name
		end)

		return ranks
	end
	--[[@
		@file Tribe
		@desc Gets the history logs of a tribe, if possible.
		@param tribeId?<int> The tribe id. (default = Client's tribe id)
		@param pageNumber?<int> The page number of the history. To list ALL the history, use `0`. (default = 1)
		@returns table|nil The history logs. Total pages at `_pages`.
		@returns nil|string The message error, if any occurred
	]]
	self.getTribeHistory = function(tribeId, pageNumber)
		assertion("getTribeHistory", { "number", "nil" }, 1, tribeId)
		assertion("getTribeHistory", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		return getList(pageNumber, forumUri.tribe_history .. "?tr=" .. tribeId, function(timestamp, log)
			return {
				log = log,
				timestamp = tonumber(timestamp)
			}
		end, htmlChunk.ms_time .. ".-" .. htmlChunk.tribe_log)
	end
	--[[@
		@desc Gets the sections of a tribe forum.
		@param location?<table> The location of the tribe forum. Field 'tr' (tribeId) is needed if it's a forum, fields 'f' and 's' are needed if it's a sub-forum. (default = Client's tribe forum)
		@returns table|nil The data of each section.
		@returns nil|string Error message, if any occurred.
	]]
	self.getTribeForum = function(location)
		assertion("getTribeForum", { "table", "nil" }, 1, location)

		location = location or { tr = this.tribeId }

		if not location.tr and (not location.f or not location.s) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's' / 'tr'")
		end

		local head, body = this.getPage(forumUri.tribe_forum .. (location.s and ("?f=" .. location.f .. "&s=" .. location.s) or ("?tr=" .. location.tr)))

		local sections, counter = { }, 0
		string.gsub(body, htmlChunk.tribe_section_id, function(f, s)
			counter = counter + 1
			sections[counter] = {
				f = tonumber(f),
				s = tonumber(s),
				tr = location.tr
			}
		end)

		return sections
	end
	--[[@
		@file Tribe
		@desc Updates the account's tribe greeting message.
		@param message<string> The new message
		@returns boolean Whether the tribe's greeting message was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateTribeGreetingMessage = function(message)
		assertion("updateTribeGreetingMessage", "string", 1, message)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		return this.performAction(forumUri.update_tribe_message, {
			{ "tr", this.tribeId },
			{ "message_jour", message }
		}, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@file Tribe
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
	self.updateTribeParameters = function(parameters)
		assertion("updateTribeParameters", "table", 1, parameters)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
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

		return this.performAction(forumUri.update_tribe_parameters, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@file Tribe
		@desc Updates the account's tribe profile.
		@desc The available data are:
		@desc string|int `community` -> Account's tribe community. An enum from `enumerations.community` (index or value)
		@desc string|int `recruitment` -> Account's tribe recruitment state. An enum from `enumerations.recruitmentState` (index or value)
		@desc string `presentation` -> Account's tribe profile's presentation
		@param data<table> The data
		@returns boolean Whether the tribe's profile was updated or not
		@returns string `Result string` or `Error message`
	]]
	self.updateTribeProfile = function(data)
		assertion("updateTribeProfile", "table", 1, data)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
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
			local err
			data.recruitment, err = isEnum(data.recruitment, "recruitmentState", "data.recruitment")
			if err then return nil, err end

			postData[#postData + 1] = { "recrutement", data.recruitment }
		end
		if data.presentation then
			postData[#postData + 1] = { "b_presentation", "on" }
			postData[#postData + 1] = { "presentation", data.presentation }
		end

		return this.performAction(forumUri.update_tribe, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@file Tribe
		@desc Changes the logo of the account's tribe.
		@param image<string> The new image. An URL or file name.
		@returns boolean Whether the new logo was set or not
		@returns string `Result string` or `Error message`
	]]
	self.changeTribeLogo = function(image)
		assertion("changeTribeLogo", "string", 1, image)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		local extension = getExtension(image)
		if not extension then
			return nil, errorString.invalid_extension
		end

		image = getFile(image)
		if not image then
			return nil, errorString.invalid_file
		end

		local file = {
			boundaries[2],
			'Content-Disposition: form-data; name="tr"',
			'',
			this.tribeId,
			boundaries[2],
			'Content-Disposition: form-data; name="fichier"; filename="Lautenschlager_id.' .. extension .. '"',
			"Content-Type: image/" .. extension,
			'',
			image,
			boundaries[2],
			'Content-Disposition: form-data; name="/KEY1/"',
			'',
			"/KEY2/",
			boundaries[3]
		}
		return this.performAction(forumUri.upload_logo, nil, forumUri.tribe .. "?tr=" .. this.tribeId, table.concat(file, separator.file))
	end
	--[[@
		@file Tribe
		@desc Removes the logo of the account's tribe.
		@returns boolean Whether the logo was removed or not
		@returns string `Result string` or `Error message`
	]]
	self.removeTribeLogo = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		return this.performAction(forumUri.remove_logo, {
			{ "tr", this.tribeId }
		}, forumUri.tribe .. "?tr=" .. this.tribeId)
	end
	--[[@
		@file Tribe
		@desc Creates a section.
		@desc The available data are:
		@desc string `name` -> Section's name
		@desc string `icon` -> Section's icon. An enum from `enumerations.sectionIcon` (index or value)
		@desc string `description` -> Section's description
		@desc int `min_characters` -> Minimum characters needed for a message in the new section
		@param data<table> The new section data
		@param location?<table> The location where the section will be created. Field 'f' is needed, 's' is needed if it's a sub-section.
		@returns boolean Whether the section was created or not
		@returns string if #1, `section's location`, else `Result string` or `Error message`
	]]
	self.createSection = function(data, location)
		assertion("createSection", "table", 1, data)
		assertion("createSection", { "table", "nil" }, 2, location)

		if not data.name or not data.icon then
			return nil, string.format(errorString.no_required_fields, "data { 'name', 'icon' }")
		end

		local err
		data.icon, err = isEnum(data.icon, "sectionIcon", "data.icon", nil, true)
		if err then return nil, err end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		if not location then
			local head, body = this.getPage(forumUri.tribe_forum .. "?tr=" .. this.tribeId)
			location = {
				f = tonumber(string.match(body, "%?f=(%d+)"))
			}
		end

		if not location.f then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f'")
		end

		-- Gets all the ids, then create the section, then get again all the ids and get the only one that did not appear in oldSections
		local oldSections, err = self.getTribeForum({
			f = location.f,
			s = location.s,
			tr = this.tribeId
		})
		if not oldSections then
			return nil, errorString.internal
		end
		oldSections = table.createSet(oldSections, 's')

		local success, data = this.performAction(forumUri.create_section, {
			{ 'f', location.f },
			{ 's', (location.s or 0) },
			{ "tr", (location.s and 0 or this.tribeId) },
			{ "nom", data.name },
			{ "icone", data.icon },
			{ "description", (data.description or data.name) },
			{ "caracteres", (data.min_characters or 4) }
		}, forumUri.new_section .. "?f=" .. location.f .. (location.s and ("&s=" .. location.s) or ("&tr=" .. this.tribeId)))
		
		if success then
			local currentSections
			currentSections, err = self.getTribeForum({
				f = location.f,
				s = location.s,
				tr = this.tribeId
			})
			if not currentSections then
				return nil, errorString.internal
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
		else
			return success, data
		end
	end
	--[[@
		@file Tribe
		@desc Updates a section.
		@desc The available data are:
		@desc string `name` -> Section's name
		@desc string `icon` -> The section's icon. An enum from `enumerations.sectionIcon` (index or value)
		@desc string `description` -> Section's description
		@desc int `min_characters` -> Minimum characters needed for a message in the new section
		@desc string|int `state` -> The section's state (e.g.: open, closed). An enum from `enumerations.displayState` (index or value)
		@desc int `parent` -> The parent section if the updated section is a sub-section. (default = 0)
		@param data<table> The updated section data
		@param location<table> The section location. Fields 'f' and 's' are needed.
		@returns boolean Whether the section was updated or not
		@returns string if #1, `section's url`, else `Result string` or `Error message`
	]]
	self.updateSection = function(data, location)
		assertion("updateSection", "table", 1, data)
		assertion("updateSection", "table", 2, location)

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not data.state then
			return nil, string.format(errorString.no_required_fields, "'data.state'")
		end

		local err
		if data.icon then
			data.icon, err = isEnum(data.icon, "sectionIcon", "data.icon", nil, true)
			if err then return nil, err end
		end
		
		data.state, err = isEnum(data.state, "displayState", "data.state")
		if err then return nil, err end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		local section = self.getSection(location)
		return this.performAction(forumUri.update_section, {
			{ 'f', location.f },
			{ 's', location.s },
			{ "nom", (data.name or section.name) },
			{ "icone", (data.icon or section.icon) },
			{ "description", (data.description or '') },
			{ "caracteres", (data.min_characters or 4) },
			{ "etat", data.state },
			{ "parent", (data.parent or (section.parent and section.parent.location.s) or 0) }
		}, forumUri.edit_section .. "?f=" .. location.f .. "&s=" .. location.s)
	end
	--[[@
		@file Tribe
		@desc Sets the permissions of each rank for a specific section on the tribe forums.
		@desc The available permissions are `canRead`, `canAnswer`, `canCreateTopic`, `canModerate`, and `canManage`.
		@desc Each one of them must be a table of IDs (`int` or `string`) of the ranks that this permission should be allowed.
		@desc To allow _non-members_, use `enumerations.misc.non_member` or `"non_member"`.
		@param permissions<table> The permissions
		@param location<table> The section location. The fields 'f', 't' and 'tr' are needed.
		@returns boolean Whether the new permissions were set or not
		@returns string `Result string` or `Error message`
	]]
	self.setTribeSectionPermissions = function(permissions, location)
		assertion("setTribeSectionPermissions", "table", 1, permissions)
		assertion("setTribeSectionPermissions", "table", 2, location)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		local ranks = this.getTribeRank(location) -- [i] = { id, name }
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
							permissions[indexes[i]][j] = enumerations.misc.non_member
						else
							permissions[indexes[i]][j] = ranks_by_name[permissions[indexes[i]][j]][1]
						end
						if not permissions[indexes[i]][j] then
							return nil, errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
						end
					end

					if not hasLeader and permissions[indexes[i]][j] == ranks[1][1] then
						hasLeader = true
					end

					if not ranks_by_id[permissions[indexes[i]][j]] then
						if permissions[indexes[i]][j] ~= enumerations.misc.non_member then
							return nil, errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
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

		return this.performAction(forumUri.update_section_permissions,  {
			{ 'f', location.f },
			{ 's', location.s },
			{ "tr", this.tribeId },
			{ "droitLire", table.concat(permissions.canRead, separator.forum_data) },
			{ "droitRepondre", table.concat(permissions.canAnswer, separator.forum_data) },
			{ "droitCreerSujet", table.concat(permissions.canCreateTopic, separator.forum_data) },
			{ "droitModerer", table.concat(permissions.canModerate, separator.forum_data) },
			{ "droitGerer", table.concat(permissions.canManage, separator.forum_data) }
		}, forumUri.edit_section_permissions .. "?f=" .. location.f .. "&s=" .. location.s)
	end

	-- > Micepix
	--[[@
		@file Micepix
		@desc Gets the images that were hosted in your account.
		@param pageNumber?<int> The page number of the gallery. To list ALL the gallery, use `0`. (default = 1)
		@returns table|nil The data of the images. Total pages at `_pages`.
		@returns nil|string The message error, if any occurred
	]]
	self.getAccountImages = function(pageNumber)
		assertion("getImages", { "number", "nil" }, 1, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return getList(pageNumber, forumUri.user_images_grid .. "?pr=" .. this.userId, function(code, _, timestamp)
			return {
				imageId = code,
				timestamp = tonumber(timestamp)
			}
		end, htmlChunk.image_id .. ".-" .. htmlChunk.profile_id .. ".-" .. htmlChunk.ms_time)
	end
	--[[@
		@file Micepix
		@desc Gets the latest images that were hosted on Micepix.
		@param quantity?<int> The quantity of images needed. Must be a number multiple of 16. (default = 16)
		@returns table|nil The data of the images.
		@returns nil|string The message error, if any occurred
	]]
	self.getLatestImages = function(quantity)
		assertion("getLatestImages", { "number", "nil" }, 1, quantity)

		quantity = quantity or 16

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local r = quantity % 16
		if r > 0 then
			quantity = quantity - r + 16
		end

		local head, body, lastImage
		local pat = htmlChunk.image_id .. ".-" .. htmlChunk.profile_id .. ".-" .. htmlChunk.ms_time

		local images, counter = { }, 0
		for i = 1, quantity, 16 do
			head, body = this.getPage(forumUri.images_gallery .. (lastImage and ("?im=" .. lastImage) or ""))

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
		@file Micepix
		@desc Uploads an image in Micepix.
		@param image<string> The new image. An URL or file name.
		@param isPublic?<boolean> Whether the image should appear in the gallery or not. (default = false)
		@returns boolean Whether the image was hosted or not
		@returns string if #1, `image's location`, else `Result string` or `Error message`
	]]
	self.uploadImage = function(image, isPublic)
		assertion("uploadImage", "string", 1, image)
		assertion("uploadImage", { "boolean", "nil" }, 2, isPublic)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local extension = getExtension(image)
		if not extension then
			return nil, errorString.invalid_extension
		end

		image = getFile(image)
		if not image then
			return nil, errorString.invalid_file
		end

		local file = {
			boundaries[2],
			'Content-Disposition: form-data; name="/KEY1/"',
			'',
			"/KEY2/",
			boundaries[2],
			'Content-Disposition: form-data; name="fichier"; filename="Lautenschlager_id.' .. extension .. '"',
			"Content-Type: image/" .. extension,
			'',
			image,
			(isPublic and boundaries[2] or nil),
			(isPublic and 'Content-Disposition: form-data; name="enGalerie"' or nil),
			(isPublic and '' or nil),
			(isPublic and "on" or nil),
			boundaries[3]
		}

		local success, data = this.performAction(forumUri.upload_image, nil, forumUri.user_images, table.concat(file, separator.file))
		return returnRedirection(success, data)
	end
	--[[@
		@file Micepix
		@desc Deletes an image from the account's micepix.
		@param imageId<string> The image id
		@returns boolean Whether the image was deleted or not
		@returns string `Result string` or `Error message`
	]]
	self.deleteMicepixImage = function(imageId)
		assertion("deleteMicepixImage", "string", 1, imageId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.remove_image, {
			{ "im", imageId }
		}, forumUri.view_user_image .. "?im=" .. imageId)
	end

	-- > Miscellaneous
	--[[@
		@file Miscellaneous
		@desc Performs a deep search on forums.
		@param searchType<string,int> The type of the search (e.g.: player, message). An enum from `enumerations.searchType` (index or value)
		@param search<string> The value to be found in the search
		@param pageNumber?<int> The page number of the search results. To list ALL the matches, use `0`. (default = 1)
		@param data?<table> Additional data to be used in the `message_topic` search type. Fields `searchLocation`(enum) and `f` are needed. Fields `author`, `community`(enum), and `s` are optional.
		@returns table|nil The search matches. Total pages at `_pages`.
		@returns nil|string The message error, if any occurred
	]]
	self.search = function(searchType, search, pageNumber, data)
		if type(search) == "number" then
			search = tostring(search)
		end

		assertion("search", { "string", "number" }, 1, searchType)
		assertion("search", "string", 2, search)
		assertion("search", { "number", "nil" }, 4, pageNumber)

		pageNumber = pageNumber or 1

		local err
		searchType, err = isEnum(searchType, "searchType", "searchType")
		if err then return nil, err end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local d, html, f = ''
		if searchType == enumerations.searchType.message_topic then
			assertion("search", "table", 3, data)

			if not data.searchLocation or not data.f then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "data { 'searchLocation', 'f' }")
			end
			data.author = data.author or ''
			data.community = data.community or 0
			data.s = data.s or 0

			if data.searchLocation == enumerations.searchLocation.titles then
				html = htmlChunk.topic_div .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.search_list .. ".-" .. htmlChunk.ms_time .. ".-" .. htmlChunk.profile_id
				f = function(community, post, title, timestamp, author)
					return {
						location = self.parseUrlData(post),
						community = enumerations.community[community],
						title = title,
						timestamp = tonumber(timestamp),
						author = self.formatNickname(author)
					}
				end
			else
				html = htmlChunk.topic_div .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.search_list .. ".-" .. htmlChunk.message_post_id .. ".-" .. htmlChunk.message_html .. ".-" .. htmlChunk.ms_time .. ".-" .. htmlChunk.profile_id
				f = function(community, post, title, postId, msgHtml, timestamp, author)
					return {
						location = self.parseUrlData(post),
						post = postId,
						topicTitle = title,
						community = enumerations.community[community],
						messageHtml = msgHtml,
						timestamp = tonumber(timestamp),
						author = self.formatNickname(author)
					}
				end
			end

			d = "&ou=" .. data.searchLocation .. "&pr=" .. data.author .. "&f=" .. data.f .. "&c=" .. data.community .. "&s=" .. data.s, pageNumber
		else
			if searchType == enumerations.searchType.tribe then
				html = htmlChunk.tribe_list
				f = function(name, id)
					return {
						name = name,
						id = tonumber(id)
					}
				end
			else
				html = htmlChunk.community .. ".-" .. htmlChunk.nickname
				f = function(community, name, discriminator)
					return {
						community = enumerations.community[community],
						name = name .. discriminator
					}
				end
			end
		end

		return getList(pageNumber, forumUri.search .. "?te=" .. searchType .. "&se=" .. encodeUrl(search) .. d, f, html)
	end
	--[[@
		@file Miscellaneous
		@desc Gets the topics created by a user.
		@param userName?<string,int> User name or id. (default = Client's account id)
		@returns table|nil The list of topics, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getCreatedTopics = function(userName)
		assertion("getCreatedTopics", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.topics_started .. "?pr=" .. (userName or this.userId))

		local topics, counter = { }, 0
		string.gsub(body, htmlChunk.topic_div .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.created_topic_data .. ".- on .-" .. htmlChunk.ms_time, function(community, topic, title, messages, timestamp)
			counter = counter + 1
			topics[counter] = {
				location = self.parseUrlData(topic),
				title = title,
				totalMessages = tonumber(messages),
				community = enumerations.community[community],
				timestamp = tonumber(timestamp)
			}
		end)

		return topics
	end
	--[[@
		@file Miscellaneous
		@desc Gets the last posts of a user.
		@param pageNumber?<int> The page number of the last posts list. (default = 1)
		@param userName?<string,int> User name or id. (default = Client's account id)
		@returns table|nil The list of posts, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getLastPosts = function(pageNumber, userName)
		assertion("getLastPosts", { "number", "nil" }, 1, pageNumber)
		assertion("getLastPosts", { "string", "number", "nil" }, 2, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.posts .. "?pr=" .. (userName or this.userId) .. "&p=" .. (pageNumber or 1))

		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local posts, counter = {
			_pages = totalPages
		}, 0
		string.gsub(body, htmlChunk.last_post .. htmlChunk.message_html .. ".-" .. htmlChunk.ms_time, function(post, topicTitle, postId, messageHtml, timestamp)
			counter = counter + 1
			posts[counter] = {
				location = self.parseUrlData(post),
				post = postId,
				timestamp = tonumber(timestamp),
				topicTitle = topicTitle,
				messageHtml = messageHtml
			}
		end)

		return posts
	end
	--[[@
		@file Miscellaneous
		@desc Gets the client's account favorite topics.
		@returns table|nil The list of topics, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getFavoriteTopics = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.favorite_topics)

		local topics, counter = { }, 0

		string.gsub(body, htmlChunk.favorite_topics .. ".-" .. string.format(htmlChunk.hidden_value, "fa") .. ".- on .-" .. htmlChunk.ms_time, function(navBar, favoriteId, timestamp)
			local navigation_bar, community = { }
			local _counter = 0

			local err
			string.gsub(navBar, htmlChunk.navigaton_bar_sections, function(href, code)
				href, err = self.parseUrlData(href)
				if err then
					return nil, err
				end
				
				_counter = _counter + 1
				local html, name = string.match(code, htmlChunk.navigaton_bar_sec_content)
				if html then
					navigation_bar[_counter] = {
						location = href,
						name = name
					}

					if not community then
						community = string.match(html, htmlChunk.community)
					end
				else
					navigation_bar[_counter] = {
						location = href,
						name = code
					}
				end
			end)

			counter = counter + 1
			topics[counter] = {
				favoriteId = tonumber(favoriteId),
				timestamp = tonumber(timestamp),
				navbar = navigation_bar,
				community = (community and enumerations.community[community] or nil)
			}
		end)

		return topics
	end
	--[[@
		@file Miscellaneous
		@desc Gets the account's friendlist.
		@returns table|nil The friendlist, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getFriendlist = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.friends .. "?pr=" .. this.userId)

		local friends, counter = { }, 0
		string.gsub(body, htmlChunk.nickname, function(name, discriminator)
			counter = counter + 1
			friends[counter] = name .. discriminator
		end)

		return friends
	end
	--[[@
		@file Miscellaneous
		@desc Gets the account's blacklist.
		@returns table|nil The blacklist, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getBlacklist = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.blacklist .. "?pr=" .. this.userId)

		local blacklist, counter = { }, 0
		string.gsub(body, htmlChunk.blacklist_name, function(name)
			counter = counter + 1
			blacklist[counter] = name
		end)

		return blacklist
	end
	--[[@
		@file Miscellaneous
		@desc Gets the client's account favorite tribes.
		@returns table|nil The list of tribes, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getFavoriteTribes = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local head, body = this.getPage(forumUri.favorite_tribes)

		local tribes, counter = { }, 0

		string.gsub(body, htmlChunk.profile_tribe, function(name, tribeId)
			counter = counter + 1
			tribes[counter] = {
				name = name,
				id = tonumber(tribeId)
			}
		end)

		return tribes
	end
	--[[@
		@file Miscellaneous
		@desc Gets the latest messages sent by admins.
		@returns table|nil The list of posts, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getDevTracker = function()
		local head, body = this.getPage(forumUri.tracker)

		local posts, counter = { }, 0
		string.gsub(body, htmlChunk.topic_div .. htmlChunk.tracker, function(content)
			local navBar = string.match(content, htmlChunk.navigation_bar)
			if not navBar then
				return nil, errorString.internal
			end

			local navigation_bar = { }
			local _counter = 0

			local err
			string.gsub(navBar, htmlChunk.navigaton_bar_sections, function(href, code)
				href, err = self.parseUrlData(href)
				if err then
					return nil, err
				end
				
				_counter = _counter + 1
				local html, name = string.match(code, htmlChunk.navigaton_bar_sec_content)
				if html then
					navigation_bar[_counter] = {
						location = href,
						name = name
					}
				else
					navigation_bar[_counter] = {
						location = href,
						name = code
					}
				end
			end)

			local postId = tonumber(string.sub(navigation_bar[_counter].name, 2))
			navigation_bar[_counter] = nil

			local messageHtml, timestamp, admin = string.match(content, htmlChunk.message_html .. ".-" .. htmlChunk.ms_time .. ".-" .. htmlChunk.admin_name)
			if not messageHtml then
				return nil, errorString.internal
			end

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
		@file Miscellaneous
		@desc Adds a user as friend.
		@param userName<string> The user to be added
		@returns boolean Whether the user was added or not
		@returns string `Result string` or `Error message`
	]]
	self.addFriend = function(userName)
		assertion("addFriend", "string", 1, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.add_friend, {
			{ "nom", userName }
		}, forumUri.friends .. "?pr=" .. this.userId)
	end
	--[[@
		@file Miscellaneous
		@desc Adds a user in the blacklist.
		@param userName<string> The user to be blacklisted
		@returns boolean Whether the user was blacklisted or not
		@returns string `Result string` or `Error message`
	]]
	self.blacklistUser = function(userName)
		assertion("blacklistUser", "string", 1, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.ignore_user, {
			{ "nom", userName }
		}, forumUri.blacklist .. "?pr=" .. this.userId)
	end
	--[[@
		@file Miscellaneous
		@desc Adds a user in the blacklist.
		@param userName<string> The user to be blacklisted
		@returns boolean Whether the user was blacklisted or not
		@returns string `Result string` or `Error message`
	]]
	self.unblacklistUser = function(userName)
		assertion("unblacklistUser", "string", 1, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(forumUri.remove_blacklisted, {
			{ "nom", userName }
		}, forumUri.blacklist .. "?pr=" .. this.userId)
	end
	--[[@
		@file Miscellaneous
		@desc Favorites an element. (e.g: topic, tribe)
		@param element<string,int> The element type. An enum from `enumerations.element` (index or value)
		@param elementId<int> The element id.
		@param location?<table> The location of the element. If it's a forum topic the fields 'f' and 't' are needed.
		@returns boolean Whether the element was favorited or not
		@returns string `Result string` or `Error message`
	]]
	self.favoriteElement = function(element, elementId, location)
		assertion("favoriteElement", { "string", "number" }, 1, element)
		assertion("favoriteElement", "number", 2, elementId)
		assertion("favoriteElement", { "table", "nil" }, 3, location)

		local err
		element, err = isEnum(element, "element")
		if err then return nil, err end

		location = location or { }

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local link
		if element == enumerations.element.topic then
			-- Topic ID
			if not location.f or not location.t then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		elseif element == enumerations.element.tribe then
			-- Tribe ID
			link = forumUri.tribe .. "?tr=" .. elementId
		else
			return nil, errorString.unaivalable_enum
		end

		return this.performAction(forumUri.add_favorite, {
			{ 'f', (location.f or 0) },
			{ "te", element },
			{ "ie", elementId }
		}, link)
	end
	--[[@
		@file Miscellaneous
		@desc Unfavorites an element.
		@param favoriteId<int,string> The element favorite-id.
		@param location?<table> The location of the element. If it's a forum topic the fields 'f' and 't' are needed.
		@returns boolean Whether the element was unfavorited or not
		@returns string `Result string` or `Error message`
	]]
	self.unfavoriteElement = function(favoriteId, location)
		assertion("unfavoriteElement", { "number", "string" }, 1, favoriteId)
		assertion("unfavoriteElement", { "table", "nil" }, 2, location)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local link
		if location then
			-- Forum topic
			if not location or not location.f or not location.t then
				return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
			end
			link = forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t
		else
			link = forumUri.tribe .. "?tr=" .. favoriteId
		end

		return this.performAction(forumUri.remove_favorite, {
			{ "fa", favoriteId }
		}, link)
	end
	--[[@
		@file Miscellaneous
		@desc Lists the members of a specific role.
		@param role<string,int<> The role id. An enum from `enumerations.listRole` (index or value)
		@returns table|nil The list, if there's any
		@returns nil|string The message error, if any occurred
	]]
	self.getStaffList = function(role)
		assertion("getStaffList", { "string", "number" }, 1, role)

		local err
		role, err = isEnum(role, "listRole")
		if err then return nil, err end

		local success, result = this.getPage(forumUri.staff .. "?role=" .. role)
		local data, counter = { }, 0
		string.gsub(result, htmlChunk.nickname, function(name, discriminator)
			counter = counter + 1
			data[counter] = name .. discriminator
		end)

		return data
	end

	return self
end