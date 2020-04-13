--[[ Dependencies ]]--
-- Performs HTTP(S) requests
local http = require("coro-http")
-- Encoding
local base64 = require("base64")
-- Necessary enumerations
local enumerations = require("enumerations")
-- Utilities
local extensions = require("extensions")

--[[ autoupdate ]]--
do
	local autoupdate = io.open("autoupdate", 'r') or io.open("autoupdate.txt", 'r')
	local semiupdate = not autoupdate and (io.open("semiautoupdate", 'r') or io.open("semiautoupdate.txt", 'r'))
	if autoupdate or semiautoupdate then
		if autoupdate then
			autoupdate:close()
		end
		if semiupdate then
			semiupdate:close()
		end

		coroutine.wrap(function()
			local pkg = require("deps/fromage/package")
			if pkg then
				local version = pkg.version
				local _, lastVersion = http.request("GET", "https://raw.githubusercontent.com/Lautenschlager-id/Fromage/master/package.lua")
				if lastVersion then
					lastVersion = string.match(lastVersion, "version = \"(.-)\"")
					if version ~= lastVersion then
						local toUpdate
						if semiupdate then
							repeat
								print("There is a new version of 'Fromage' available [" .. lastVersion .. "]. Update it now? (Y/N)")
								toUpdate = string.lower(io.read())
							until toUpdate == 'n' or toUpdate == 'y'
						else
							toUpdate = 'y'
						end

						if toUpdate == 'y' then
							for i = 1, #pkg.files do
								os.remove("deps/fromage/" .. pkg.files[i])
							end
							os.execute("lit install Lautenschlager-id/fromage") -- Installs the new lib
							os.execute("luvit " .. table.concat(args, ' ')) -- Luvit's command
							return os.exit()
						end
					end
				end
			end
		end)()
	end
end

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
	acc                        = "account",
	add_favorite               = "add-favourite",
	add_friend                 = "add-friend",
	answer_conversation        = "answer-conversation",
	answer_poll                = "answer-forum-poll",
	answer_private_poll        = "answer-conversation-poll",
	answer_topic               = "answer-topic",
	blacklist                  = "blacklist",
	close_discussion           = "close-discussion",
	conversation               = "conversation",
	conversations              = "conversations",
	create_dialog              = "create-dialog",
	create_discussion          = "create-discussion",
	create_section             = "create-section",
	create_topic               = "create-topic",
	disconnection              = "deconnexion",
	edit                       = "edit",
	edit_message               = "edit-topic-message",
	edit_section               = "edit-section",
	edit_section_permissions   = "edit-section-permissions",
	edit_topic                 = "edit-topic",
	element_id                 = "ie",
	favorite_id                = "fa",
	favorite_topics            = "favorite-topics",
	favorite_tribes            = "favorite-tribes",
	friends                    = "friends",
	get_cert                   = "get-certification",
	identification             = "identification",
	ignore_user                = "add-ignored",
	images_gallery             = "gallery-images-ajax",
	index                      = "index",
	invite_discussion          = "invite-discussion",
	kick_member                = "kick-discussion-member",
	leave_discussion           = "quit-discussion",
	like_message               = "like-message",
	login                      = "login",
	manage_message_restriction = "manage-selected-topic-messages-restriction",
	message_history            = "tribulle-frame-topic-message-history",
	moderate                   = "moderate-selected-topic-messages",
	move_all_conversations     = "move-all-conversations",
	move_conversation          = "move-conversations",
	new_dialog                 = "new-dialog",
	new_discussion             = "new-discussion",
	new_poll                   = "new-forum-poll",
	new_private_poll           = "new-private-poll",
	new_section                = "new-section",
	new_topic                  = "new-topic",
	poll_id                    = "po",
	posts                      = "posts",
	profile                    = "profile",
	quote                      = "citer",
	remove_avatar              = "remove-profile-avatar",
	remove_blacklisted         = "remove-ignored",
	remove_bulk_images         = "remove-user-own-images",
	remove_favorite            = "remove-favourite",
	remove_logo                = "remove-tribe-logo",
	reopen_discussion          = "reopen-discussion",
	report                     = "report-element",
	search                     = "search",
	section                    = "section",
	set_cert                   = "set-certification",
	set_email                  = "set-email",
	set_pw                     = "set-password",
	staff                      = "staff-ajax",
	topic                      = "topic",
	topics_started             = "topics-started",
	tracker                    = "dev-tracker",
	tribe                      = "tribe",
	tribe_forum                = "tribe-forum",
	tribe_history              = "tribe-history",
	tribe_members              = "tribe-members",
	update_avatar              = "update-profile-avatar",
	update_parameters          = "update-user-parameters",
	update_profile             = "update-profile",
	update_section             = "update-section",
	update_section_permissions = "update-section-permissions",
	update_topic               = "update-topic",
	update_tribe               = "update-tribe",
	update_tribe_message       = "update-tribe-greeting-message",
	update_tribe_parameters    = "update-tribe-parameters",
	upload_image               = "upload-user-image",
	upload_logo                = "update-tribe-logo",
	user_images                = "user-images",
	user_images_home           = "user-images-home",
	user_images_grid           = "user-images-grid-ajax",
	view_user_image            = "view-user-image"
}

local htmlChunk = {
	admin_name                 = 'cadre%-type%-auteur%-admin">(.-)</span>',
	blacklist_name             = 'cadre%-ignore%-nom">(.-)</span>',
	community                  = 'pays/(..)%.png',
	conversation_icon          = 'cadre%-sujet%-titre">(.-)</span>%s+</td>%s+</tr>%s+</table>',
	conversation_member_state  = '<span class="cadre%-membre%-conversation.-> %((.-)%)',
	conversation_members       = '<div class="cadre%-membre%-conversation">(.-)</div>%s+</div>%s+</div>',
	created_topic_data         = 'href="(topic%?f=%d+&t=%d+).-".->%s+([^>]+)%s+</a>.-%2.-m(%d+)',
	date                       = '(%d+/%d+/%d+)',
	edition_timestamp          = 'cadre%-message%-dates.-(%d+)',
	empty_section              = '<div class="aucun%-resultat">Empty</div>',
	error_503                  = "^<html>\r?\n<head><title>503 Service Temporarily Unavailable</title></head>",
	favorite_topics            = '<td rowspan="2">(.-)</td>%s+<td rowspan="2">',
	greeting_message           = '<h4>Greeting message</h4> (.*)$',
	hidden_value               = '<input type="hidden" name="%s" value="(%%d+)"/?>',
	image_id                   = '?im=(%w+)"',
	last_post                  = '("barre%-navigation  ltr .-<a href="(topic%?.-)".->%s+(.-)%s+</a></li>.-)%2.-#m(%d+)">',
	message                    = 'cadre_message_sujet_(%%d+)">%%s+<div id="m%d"(.-</div>%%s+</div>%%s+</div>)',
	message_content            = '"%s_message_%d" .->(.-)<',
	message_data               = 'class="coeur".-(%d+).-message_%d+">(.-)</div>%s+</div>',
	message_history_log        = 'class="hidden"> (.-) </div>',
	message_html               = 'Message</a></span> :%s+(.-)%s*</div>%s+</td>%s+</tr>',
	message_id                 = '<div id="message_(%d+)">',
	message_post_id            = 'numero%-message".-#(%d+)',
	moderated_message          = 'cadre%-message%-modere%-texte">.-by ([^,]+)[^:]*:?%s*(.*)%s*%]<',
	ms_time                    = 'data%-afficher%-secondes.->(%d+)',
	navigation_bar             = '"barre%-navigation.->(.-)</ul>',
	navigation_bar_sec_content = '^<(.+)>%s*(.+)%s*$',
	navigation_bar_sections    = '<a.-href="(.-)".->%s*(.-)%s*</a>',
	nickname                   = '(%S+)<span class="nav%-header%-hashtag">(#(%d+))',
	not_connected              = '<p> +You must be connected to do this%. +</p>',
	poll_content               = '<div>%s+(.-)%s+</div>%s+<br>',
	poll_option                = '<label class="(.-) ">%s+<input type="%1" name="reponse_%d*" id="reponse_(%d+)" value="%2" .-/>%s+(.-)%s+</label>',
	poll_percentage            = 'reponse%-sondage">.-%((%d+)%)</div>',
	post                       = '<div id="m%d',
	private_message            = '<div id="m%d" (.-</div>%%s+</div>%%s+</div>%%s+</td>%%s+</tr>)',
	private_message_data       = '<.-id="message_(%d+)">(.-)</div>%s+</div>%s+</div>%s+</td>%s+</tr>',
	profile_avatar             = '(http://avatars%.atelier801%.com/%d+/(%d+)%.%a+)',
	profile_birthday           = 'Birthday :</span> ',
	profile_data               = 'Messages: </span>(%-?%d+).-Prestige: </span>(%d+).-Level: </span>(%d+)',
	profile_gender             = 'Gender :.- (%S+)%s+<br>',
	profile_id                 = 'profile%?pr=(.-)"',
	profile_location           = 'Location :</span> (.-)  <br>',
	profile_presentation       = 'cadre%-presentation">%s*(.-)%s*</div></div></div>',
	profile_soulmate           = 'Soul mate :</span>.-',
	profile_tribe              = 'cadre%-tribu%-nom">(.-)</span>.-tr=(%d+)',
	recruitment                = 'Recruitment : (.-)<',
	search_list                = '<a href="(topic%?.-)".->%s+(.-)%s+</a></li>',
	sec_topic_author           = '>(%S+)</span>',
	secret_keys                = '<input type="hidden" name="(.-)" value="(.-)">',
	section_icon               = 'sections/(.-%.png)',
	section_topic              = 'cadre%-sujet%-%titre.-href="topic%?.-&t=(%d+).-".->%s+([^>]+)%s+</a>',
	subsection                 = '"cadre%-section%-titre%-mini.-(section.-)".->%s+([^>]+)%s+</a>',
	title                      = '<title>(.-)</title>',
	topic_div                  = '<div class="row">',
	total_members              = 'table%-cadre%-cellule%-principale',
	total_pages                = '"input%-pagination".-max="(%d+)"',
	tracker                    = '(.-)</div>%s+</div>',
	tribe_list                 = '<li class="nav%-header">([^<]+)</li> <li><a class="element%-menu%-contextuel" href="tribe%?tr=(%d+)">',
	tribe_log                  = '<td> (.-) </td>',
	tribe_presentation         = 'cadre%-presentation"> (.-) </div>',
	tribe_rank                 = '<div class="rang%-tribu"> (.-) </div>',
	tribe_rank_id              = '<tr id="(%d+)"> <td>(.-)</td>',
	tribe_rank_list            = '<h4>Ranks</h4>(.-)</div>%s+</div>',
	tribe_section_id           = '"section%?f=(%d+)&s=(%d+)".-/>%s*(.-)%s*</a>'
}

local errorString = {
	already_connected       = "This instance is already connected, disconnect first.",
	enum_out_of_range       = "Enum value out of range.",
	image_id                = "An image id can not be a number.",
	internal                = "Internal error.",
	invalid_date            = "Invalid date format. Expected: dd/mm/yyyy",
	invalid_enum            = "Invalid enum.",
	invalid_extension       = "Provided file url or name does not have a valid extension.",
	invalid_file            = "Provided file does not exist.",
	invalid_forum_url       = "Invalid Atelier801's url.",
	invalid_id              = "Invalid id.",
	invalid_user            = "The user does not exist or was not found.",
	no_poll_responses       = "Missing poll responses. There must be at least two responses.",
	no_required_fields      = "The fields %s are needed.",
	no_right                = "You don't have rights to see this info.",
	no_tribe                = "This instance does not have a tribe.",
	no_url_location         = "Missing location.",
	no_url_location_private = "The fields %s are needed if the object is private.",
	not_connected           = "This instance is not connected yet, connect first.",
	not_poll                = "Invalid topic. Poll not detected.",
	not_verified            = "This instance has not a certificate yet. Valid the account first.",
	poll_id                 = "A poll id can not be a string.",
	poll_option_not_found   = "Invalid poll option.",
	secret_key_not_found    = "Secret keys could not be found.",
	unaivalable_enum        = "This function does not accept this enum."
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
		local _, body = http.request("GET", f)
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

--[[ Class ]]--
return function()
	-- Internal
	local this = { }
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

		return body
	end

	-- Gets a page using the headers of the account
	this.getPage = function(url)
		local head, body = http.request("GET", forumLink .. url, this.getHeaders())
		return body, head
	end

	--> Private function
	local newThis = function()
		-- Whether the account is connected or not
		this.isConnected = false
		-- The nickname of the account, if it's connected.
		this.userName = nil
		this.userId = nil
		this.tribeId = nil
		this.cookieState = cookieState.login
		-- Account cookies
		this.cookies = { }
		-- Whether the account has validated its account with a code
		this.hasCertificate = false
		-- Current time since the last login
		this.connectionTime = -1
	end
	newThis()

	local getNavbar = function(content, isNavbar)
		local navBar = (isNavbar and content or string.match(content, htmlChunk.navigation_bar))
		if not navBar then
			return nil, errorString.internal .. " (0x1)"
		end

		local navigation_bar = { }
		local counter = 0

		local lastHtml, err, html, name, community = ''
		string.gsub(navBar, htmlChunk.navigation_bar_sections, function(href, code)
			href, err = self.parseUrlData(href)
			if not href then
				return nil, err .. " (0x2)"
			end

			counter = counter + 1
			navigation_bar[counter] = {
				location = href
			}

			local html, name = string.match(code, htmlChunk.navigation_bar_sec_content)
			if html then
				navigation_bar[counter].name = name

				lastHtml = html
				if not community then
					community = string.match(html, htmlChunk.community)
				end
			else
				navigation_bar[counter].name = code
			end
		end)

		return navigation_bar, lastHtml, community
	end

	local getList, getBigList
	getBigList = function(pageNumber, uri, f, getTotalPages, _totalPages, inif)
		local body, head = this.getPage(uri .. "&p=" .. math.max(1, pageNumber))
		if inif then
			local out = inif(head, body)
			if out then
				return out
			end
		end

		if getTotalPages then
			_totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1
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
	getList = function(pageNumber, uri, f, html, inif, usesCoro)
		return getBigList(pageNumber, uri, function(list, body)
			local counter = 0
			if usesCoro then
				-- Using string.gsub would create another environment and break the API because of http requests
				local iterator = string.gmatch(body, html)
				while true do
					local result = { iterator() }
					if #result == 0 then break end
					result[#result + 1] = body

					counter = counter + 1
					list[counter] = f(table.unpack(result))
				end
			else
				string.gsub(body, html, function(...)
					local result = { ... }
					result[#result + 1] = body

					counter = counter + 1
					list[counter] = f(table.unpack(result))
				end)
			end
		end, true, nil, inif)
	end

	local redirect = function(data, err)
		if data then
			local link = string.match(data, '"redirection":"(.-)"')
			if link then
				return self.parseUrlData(link)
			end
		end

		return nil, err
	end

	-- > Tool
	--[[@
		@file Api
		@desc Performs a GET request using the connection cookies.
		@param url<string> The URL for the GET request. The forum path is not necessary.
		@returns string,nil Page HTML.
		@returns table,string Page headers or Error message.
	]]
	self.getPage = function(url)
		assertion("getPage", "string", 1, url)

		url = string.gsub(url, forumLink, '')
		return this.getPage(url)
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
	self.getLocation = function(forum, community, section)
		assertion("getLocation", { "number", "string" }, 1, forum)
		assertion("getLocation", { "string", "number" }, 2, community)
		assertion("getLocation", { "string", "number" }, 3, section)

		local err
		forum, err = isEnum(forum, "forum", "#1")
		if err then return nil, err end
		community, err = isEnum(community, "community", "#2", true)
		if err then return nil, err end
		section, err = isEnum(section, "section", "#3", true, true)
		if err then return nil, err end

		local s = enumerations.location[community][enumerations.forum(forum)][section]
		if not s then
			return nil, errorString.enum_out_of_range .. " (section)"
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
	self.getUser = function()
		return this.userName, this.userId, this.tribeId
	end
	--[[@
		@file Api
		@desc Gets the total time since the last login performed in the instace.
		@returns int Total time since the connection of the current account.
	]]
	self.getConnectionTime = function()
		if this.connectionTime >= 0 then
			return os.time() - this.connectionTime
		end
		return this.connectionTime
	end
	--[[@
		@file Api
		@desc Gets the system enumerations.
		@desc Smoother alias for `require "fromage/libs/enumerations"`.
		@returns table The enumerations table
	]]
	self.enumerations = function()
		return enumerations
	end
	--[[@
		@file Api
		@desc Gets the extension functions of the API.
		@desc Smoother alias for `require "fromage/libs/extensions"`.
		@returns table The extension functions.
	]]
	self.extensions = function()
		return extensions
	end
	--[[@
		@file Api
		@desc Performs a POST request using the connection cookies.
		@param uri<string> The URI code for the POST request. (Function)
		@param postData?<table> The headers for the POST request.
		@param ajaxUri?<string> The ajax URI code for the POST request. (Forum)
		@param file?<string> The file (image) content. If set, this will change most of the standard headers.
		@paramstruct postData
		{
			[n]<table> A table with two strings: header name, header value.
		}
		@returns string,nil Result string.
		@returns nil,string Error message.
	]]
	self.performAction = function(uri, postData, ajaxUri, file)
		assertion("performAction", "string", 1, uri)
		assertion("performAction", { "table", "nil" }, 2, postData)
		assertion("performAction", { "string", "nil" }, 3, ajaxUri)
		assertion("performAction", { "string", "nil" }, 4, file)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return this.performAction(uri, postData, ajaxUri, file)
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
	self.parseUrlData = function(href)
		assertion("parseUrlData", "string", 1, href)

		href = string.gsub(href, forumLink, '')
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
			data = data,
			id = string.match(raw_data, "#(.-)$"),
			num_id = string.match(raw_data, "#.-(%d+).-$")
		}
	end
	--[[@
		@file Api
		@desc Checks whether the instance is supposed to be connected to an account or not.
		@desc Note that this function does not perform any request to confirm the existence of the connection and is fully based on @see connect and @see disconnect.
		@desc See @see isConnectionAlive to confirm that the connection is still active.
		@returns boolean Whether there's already a connection or not.
	]]
	self.isConnected = function()
		return this.isConnected
	end
	--[[@
		@file Api
		@desc Checks whether the instance connection is alive or not.
		@desc /!\ Calling this function several times uninterruptedly may disconnect the account unexpectedly due to the forum delay.
		@desc See @see isConnected to check whether the connection should exist or not.
		@returns boolean Whether the connection is alive or not.
	]]
	self.isConnectionAlive = function()
		if not this.isConnected then
			return false
		end

		local body = this.getPage(forumUri.conversations)
		local isAlive = not (string.find(body, htmlChunk.error_503) or string.find(body, htmlChunk.not_connected))
		if not isAlive then
			newThis()
		end

		return isAlive
	end
	--[[@
		@file Api
		@desc Formats a nickname.
		@param nickname<string> The nickname.
		@returns string Formated nickname.
	]]
	self.formatNickname = function(nickname)
		assertion("formatNickname", "string", 1, nickname)

		nickname = string.lower(nickname)
		nickname = string.gsub(nickname, "%%23", '#', 1)
		nickname = string.gsub(nickname, "%a", string.upper, 1)

		if not string.find(nickname, '#') then
			nickname = nickname .. "#0000"
		end

		return nickname
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
	self.extractNicknameData = function(nickname)
		assertion("extractNicknameData", "string", 1, nickname)

		nickname = self.formatNickname(nickname)

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
	self.isAccountValidated = function()
		return this.hasCertificate
	end

	--[[ Methods ]]
	-- > Settings
	--[[@
		@file Settings
		@desc Connects to an account on Atelier801's forums.
		@param userName<string> Account's username.
		@param userPassword<string> Account's password.
		@returns boolean,nil Whether the connection succeeded or not.
		@returns nil,string Error message.
	]]
	self.connect = function(userName, userPassword)
		assertion("connect", "string", 1, userName)
		assertion("connect", "string", 2, userPassword)

		if this.isConnected then
			return nil, errorString.already_connected
		end

		userName = self.formatNickname(userName)

		local result, err = this.performAction(forumUri.identification, {
			{ "rester_connecte", "on" },
			{ "id", userName },
			{ "pass", getPasswordHash(userPassword) },
			{ "redirect", string.sub(forumLink, 1, -2) }
		}, forumUri.login)
		if not result then
			return nil, err .. " (0x1)"
		end

		if string.sub(result, 2, 15) == '"supprime":"*"' then
			this.isConnected = true
			this.userName = userName
			local pr, err = self.getProfile()
			if not pr then
				this.isConnected = false
				this.userName = nil
				return nil, err .. " (0x2)"
			end
			this.cookieState = cookieState.after_login
			this.userId = pr.id
			this.tribeId = pr.tribeId
			this.connectionTime = os.time()
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
	self.disconnect = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.disconnection, nil, forumUri.acc)
		if not result then
			return nil, err
		end

		if string.sub(result, 2, 15) == '"supprime":"*"' then
			newThis()
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
		@returns boolean,nil Whether the validation code is valid or not.
		@returns string Result string or Error message.
	]]
	self.submitValidationCode = function(code)
		assertion("submitValidationCode", "string", 1, code)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.set_cert, {
			{ "code", code }
		}, forumUri.acc)
		if not result then
			return nil, err
		end

		this.hasCertificate = (result == "{}") -- An empty table is returned when it succeed

		return this.hasCertificate, result
	end
	--[[@
		@file Settings
		@desc Sets the new account's e-mail.
		@param email<string> The e-mail to be linked to the account.
		@param registration?<boolean> Whether this is the first e-mail assigned to the account or not. @default false
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@param password<string> The new password.
		@param disconnect?<boolean> Whether the account should be disconnect from all the dispositives or not. @default false
		@returns boolean,nil Result string.
		@returns nil,string Error message.
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
		@desc Gets the profile data of an user.
		@param userName?<string,int> User name or user id. @default Account's username
		@returns table,nil The profile data.
		@returns nil,string Error message.
		@struct {
			avatarUrl = "", -- The profile picture url.
			birthday = "", -- The birthday string field.
			community = enumerations.community, -- The community of the user.
			gender = enumerations.gender, -- The gender of the user.
			highestRole = enumerations.role, -- The highest role of the account based on the discriminator number.
			id = 0, -- The user id.
			level = 0, -- The level of the user on forums.
			location = "", -- The location string field.
			name = "", -- The name of the user.
			presentation = "", -- The presentation string field (HTML).
			registrationDate = "", -- The registration date string field.
			soulmate = "", -- The username of the account's soulmate.
			title = enumerations.forumTitle, -- The current forum title of the account based on the level.
			totalMessages = 0, -- The quantity of messages sent by the user.
			totalPrestige = 0, -- The quantity of prestige (likes) obtained by the user.
			tribe = "", -- The name of the account's tribe.
			tribeId = 0 -- The id of the account's tribe.
		}
	]]
	self.getProfile = function(userName)
		assertion("getProfile", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			if not userName then
				return nil, errorString.not_connected
			end
		end

		userName = userName or this.userName
		local body = this.getPage(forumUri.profile .. "?pr=" .. encodeUrl(userName))

		local avatar, id = string.match(body, htmlChunk.profile_avatar)
		id = tonumber(id)
		if not id then
			id = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.element_id)))
			if not id then
				return nil, errorString.invalid_user
			end
		end

		local name, hashtag, discriminator = string.match(body, htmlChunk.nickname)
		if not discriminator then
			return nil, errorString.internal .. " (0x1)"
		end

		local highestRole = tonumber(discriminator)
		if not enumerations.role(highestRole) then
			highestRole = nil
		end

		local registrationDate, community, messages, prestige, level = string.match(body, htmlChunk.date .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.profile_data)
		level = tonumber(level)
		if not level then
			return nil, errorString.internal .. " (0x2)"
		end

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

		return {
			avatarUrl = avatar,
			birthday = birthday,
			community = enumerations.community[community],
			gender = enumerations.gender[gender],
			highestRole = highestRole,
			id = tonumber(id),
			level = level,
			location = location,
			name = name .. hashtag,
			presentation = presentation,
			registrationDate = registrationDate,
			soulmate = soulmate,
			title = enumerations.forumTitle[level],
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
		@desc Removes the profile picture of the account.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@desc Updates the account profile parameters.
		@param parameters?<table> The parameters.
		@paramstruct parameters {
			online?<boolean> Whether the account should display if it's online or not. @default false
		}
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		local body = this.getPage(forumUri.conversation .. path)

		local title = string.match(body, htmlChunk.title)
		if not title then
			return nil, errorString.internal .. " (0x1)"
		end

		local isDiscussion, isPrivateMessage = false, false
		local titleIcon = string.match(body, htmlChunk.conversation_icon)
		if not titleIcon then
			return nil, errorString.internal .. " (0x2)"
		end

		local err
		local isPoll, poll = not not string.find(body, string.format(htmlChunk.hidden_value, forumUri.poll_id)) -- Whether it's a poll or not
		if isPoll and not ignoreFirstMessage then
			poll, err = self.getPoll(location)
			if not poll then
				return nil, err .. " (0x3)"
			end
		end

		if not isPoll then
			isDiscussion = not not string.find(titleIcon, enumerations.topicIcon.private_discussion)
			isPrivateMessage = not isDiscussion
		end

		local invitedUsers
		if not isPrivateMessage then
			invitedUsers = { }
			local invList = string.match(body, htmlChunk.conversation_members)

			local foundSelf = false
			string.gsub(invList, htmlChunk.conversation_member_state .. ".-" .. htmlChunk.nickname, function(situation, name, discriminator)
				name = name .. discriminator

				invitedUsers[name] = enumerations.memberState(situation) or ("@" .. situation)

				if not foundSelf then
					foundSelf = name == this.userName
				end
			end)
			if not foundSelf then
				invitedUsers[this.userName] = enumerations.memberState.invited
			end
		end

		local isLocked = false
		if not isPrivateMessage then
			isLocked = not not string.find(titleIcon, enumerations.topicIcon.locked)
		end

		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local counter = 0
		local lastPage = this.getPage(forumUri.conversation .. path .. "&p=" .. totalPages)
		string.gsub(lastPage, htmlChunk.post, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		local firstMessage
		if not ignoreFirstMessage then
			if not isPoll then
				firstMessage, err = self.getMessage('1', location)
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
	self.createPrivateMessage = function(destinatary, subject, message)
		assertion("createPrivateMessage", "string", 1, destinatary)
		assertion("createPrivateMessage", "string", 2, subject)
		assertion("createPrivateMessage", "string", 3, message)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.create_dialog, {
			{ "destinataire", destinatary },
			{ "objet", subject },
			{ "message", message }
		}, forumUri.new_dialog)
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
	self.createPrivateDiscussion = function(destinataries, subject, message)
		assertion("createPrivateDiscussion", "table", 1, destinataries)
		assertion("createPrivateDiscussion", "string", 2, subject)
		assertion("createPrivateDiscussion", "string", 3, message)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.create_discussion, {
			{ "destinataires", table.concat(destinataries, separator.forum_data) },
			{ "objet", subject },
			{ "message", message }
		}, forumUri.new_discussion)
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

		local result, err = this.performAction(forumUri.create_discussion, postData, forumUri.new_private_poll)
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
	self.answerConversation = function(conversationId, answer)
		assertion("answerConversation", { "number", "string" }, 1, conversationId)
		assertion("answerConversation", "string", 2, answer)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.answer_conversation, {
			{ "co", conversationId },
			{ "message_reponse", answer }
		}, forumUri.conversation .. "?co=" .. conversationId)
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
	self.moveConversation = function(inboxLocale, conversationId)
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

		return this.performAction((moveAll and forumUri.move_all_conversations or forumUri.move_conversation), (not moveAll and {
			{ "conversations", table.concat(conversationId, separator.forum_data) },
			{ "location", inboxLocale }
		} or nil), forumUri.conversations .. "?location=" .. inboxLocale)
	end
	--[[@
		@file Inbox
		@desc Changes the conversation state (open, closed).
		@param displayState<string,int> The conversation display state. An enum from @see displayState. (index or value)
		@param conversationId<int,string> The conversation id.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@file Inbox
		@desc Leaves a private conversation.
		@param conversationId<int,string> The conversation id.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@file Inbox
		@desc Invites an user to a private conversation.
		@param conversationId<int,string> The conversation id.
		@param userName<string> The name of the user to be invited.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@file Inbox
		@desc Removes a user from a conversation.
		@param conversationId<int,string> The conversation id.
		@param userId<int,string> User name or user id.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
	self.getMessage = function(postId, location, _body)
		assertion("getMessage", { "number", "string" }, 1, postId)
		assertion("getMessage", "table", 2, location)

		local pageNumber = math.ceil(tonumber(postId) / 20)

		local body = _body or this.getPage((location.co and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)) .. "&p=" .. pageNumber)

		local id, post
		if not location.co then
			-- Forum message
			id, post = string.match(body, string.format(htmlChunk.message, postId))
			if not id then
				return nil, errorString.internal .. " (0x1)"
			end

			local isModerated, moderatedBy, reason = false
			local timestamp, author, authorDiscriminator, _, prestige, contentHtml = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.message_data)
			if not timestamp then
				timestamp, author, authorDiscriminator, _, moderatedBy, reason = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.moderated_message)
				if not timestamp then
					return nil, errorString.internal .. " (0x2)"
				end
				isModerated = true
			end

			local editTimestamp = string.match(post, htmlChunk.edition_timestamp)

			local content = string.match(body, string.format(htmlChunk.message_content, forumUri.edit, id))

			local canLike = not not string.find(post, string.format(htmlChunk.hidden_value, 'm'))

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
			post = string.match(body, string.format(htmlChunk.private_message, postId))
			if not post then
				return nil, errorString.internal .. " (0x3)"
			end

			local timestamp, author, authorDiscriminator, _, id, contentHtml = string.match(post, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.private_message_data)
			if not timestamp then
				return nil, errorString.internal .. " (0x4)"
			end

			local content = string.match(body, string.format(htmlChunk.message_content, forumUri.quote, id))

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
			community = enumerations.community, -- The community where the topic is located.
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
	self.getTopic = function(location, ignoreFirstMessage, _body)
		assertion("getTopic", "table", 1, location)
		assertion("getTopic", { "boolean", "nil" }, 2, ignoreFirstMessage)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		local path = "?f=" .. location.f .. "&t=" .. location.t
		local body = _body or this.getPage(forumUri.topic .. path)

		local isPoll, poll = not not string.find(body, string.format(htmlChunk.hidden_value, forumUri.poll_id)) -- Whether it's a poll or not
		if isPoll and not ignoreFirstMessage then
			poll, err = self.getPoll(location)
			if not poll then
				return nil, err .. " (0x1)"
			end
		end

		local firstMessage
		if not ignoreFirstMessage then
			if not isPoll then
				firstMessage, err = self.getMessage('1', location)
				if not firstMessage then
					return nil, err .. " (0x2)"
				end
			end
		end

		local navigation_bar, lastHtml, community = getNavbar(body)
		if not navigation_bar then
			return nil, lastHtml .. " (0x3)"
		end

		local isFixed = not not string.find(lastHtml, enumerations.topicIcon.postit)
		local isLocked = not not string.find(lastHtml, enumerations.topicIcon.locked)
		local isDeleted = not not string.find(lastHtml, enumerations.topicIcon.deleted)

		local ie = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.element_id))) -- Element id
		local fa = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.favorite_id)))

		-- Get total of pages and total of messages
		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local counter = 0
		local lastPage = this.getPage(forumUri.topic .. path .. "&p=" .. totalPages)
		string.gsub(lastPage, htmlChunk.post, function()
			counter = counter + 1
		end)

		local totalMessages = ((totalPages - 1) * 20) + counter

		return {
			community = (community and enumerations.community[community] or nil),
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
	self.getPoll = function(location)
		assertion("getPoll", "table", 1, location)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_url_location_private, "'co'")
		end

		local body = this.getPage((isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))

		local timestamp, nickname, discriminator, _, id, contentHtml = string.match(body, htmlChunk.ms_time .. ".-" .. htmlChunk.nickname .. ".-" .. string.format(htmlChunk.hidden_value, forumUri.poll_id) .. ".-" .. htmlChunk.poll_content)
		if not timestamp then
			return nil, errorString.internal
		end

		local options = { }
		local multiple = false
		local totalVotes = -1

		local counter = 0
		string.gsub(body, htmlChunk.poll_option, function(t, id, value)
			if not multiple and t == "checkbox" then
				multiple = true
			end

			counter = counter + 1
			options[counter] = {
				id = tonumber(id),
				value = value,
				votes = -1
			}
		end)
		if counter > 0 then
			-- Gets the percentage, if there's any
			local counter = 0
			local votes = 0
			string.gsub(body, htmlChunk.poll_percentage, function(number)
				number = tonumber(number)
				counter = counter + 1
				votes = votes + number
				options[counter].votes = number
			end)
			totalVotes = votes
		else
			return nil, errorString.not_poll
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
			community = enumerations.community, -- The community where the section is located.
			f = 0, -- The forum id.
			hasSubsections = false, -- Whether the section has subsections or not.
			icon = enumerations.sectionIcon, -- The icon of the section.
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
	self.getSection = function(location)
		assertion("getSection", "table", 1, location)

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		local path = "?f=" .. location.f .. "&s=" .. location.s
		local body = this.getPage(forumUri.section .. path)

		local navigation_bar, lastHtml, community = getNavbar(body)
		if not navigation_bar then
			return nil, lastHtml .. " (0x1)"
		end
		if not lastHtml then
			return nil, errorString.internal .. " (0x2)"
		end

		local icon = string.match(lastHtml, htmlChunk.section_icon)
		icon = enumerations.sectionIcon(icon)
		if not icon then
			return nil, errorString.internal .. " (0x3)"
		end

		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1
		local lastPage = this.getPage(forumUri.section .. path .. "&p=" .. totalPages)

		local counter = 0
		local subsections, totalSubsections, err = { }, 0
		string.gsub(lastPage, htmlChunk.subsection, function(href, name)
			counter = counter + 1
			href, err = self.parseUrlData(href)
			if err then
				return nil, err .. " (0x4)"
			end

			subsections[counter] = {
				location = href,
				name = name
			}
		end)
		if counter == 0 then
			subsections = nil
		else
			totalSubsections = counter
		end
		local isSubsection = #navigation_bar > 3

		counter = 0
		local totalTopics
		if string.find(lastPage, htmlChunk.empty_section) then
			totalTopics = 0
		else
			string.gsub(lastPage, htmlChunk.topic_div, function()
				counter = counter + 1
			end)

			totalTopics = ((totalPages - 1) * 30) + (counter - (totalSubsections and 1 or 0))
		end

		local totalFixedTopics = 0
		string.gsub(body, enumerations.topicIcon.postit, function()
			totalFixedTopics = totalFixedTopics + 1
		end)

		return {
			community = (community and enumerations.community[community] or nil),
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
		@desc /!\ This function may take several minutes to return the values depending on the total of pages of the topic.
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
	self.getAllMessages = function(location, getAllInfo, pageNumber)
		assertion("getAllMessages", "table", 1, location)
		assertion("getAllMessages", { "boolean", "nil" }, 2, getAllInfo)
		assertion("getAllMessages", { "number", "nil" }, 3, pageNumber)

		getAllInfo = (getAllInfo == nil and true or getAllInfo)
		pageNumber = pageNumber or 1

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_url_location_private, "'co'")
		end

		return getBigList(pageNumber, (isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)), function(messages, body, pageNumber, totalPages)
			local post = math.max(1, pageNumber) * 20
			local counter = 0
			if getAllInfo then
				for i = (post - 19), post do
					local msg, err = self.getMessage(tostring(i), location, body)
					if not msg then
						break -- End of the page
					end
					counter = counter + 1
					messages[counter] = msg
				end
			else
				post = (post - 20)
				string.gsub(body, htmlChunk.ms_time .. ".-" .. htmlChunk.message_id, function(timestamp, id)
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
				end)
			end
		end, true)
	end
	--[[@
		@file Forum
		@desc Gets the topics of a section.
		@desc /!\ This function may take several minutes to return the values depending on the total of pages of the section.
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
	self.getSectionTopics = function(location, getAllInfo, pageNumber)
		assertion("getSectionTopics", "table", 1, location)
		assertion("getSectionTopics", { "boolean", "nil" }, 2, getAllInfo)
		assertion("getSectionTopics", { "number", "nil" }, 1, pageNumber)

		getAllInfo = (getAllInfo == nil and true or getAllInfo)
		pageNumber = pageNumber or 1

		if not location.f or not location.s then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		return getList(pageNumber, forumUri.section .. "?f=" .. location.f .. "&s=" .. location.s, function(id, title, author, timestamp, _body)
			id = tonumber(id)

			if getAllInfo then
				local tpc, err = self.getTopic({ f = location.f, t = id }, true, _body)
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
		end, htmlChunk.section_topic .. ".-" .. htmlChunk.sec_topic_author .. " on .-" .. htmlChunk.ms_time, nil, true)
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

		local result, err = this.performAction(forumUri.create_topic, {
			{ 'f', location.f },
			{ 's', location.s },
			{ "titre", title },
			{ "message", message }
		}, forumUri.new_topic .. "?f=" .. location.f .. "&s=" .. location.s)
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
	self.answerTopic = function(message, location)
		assertion("answerTopic", "string", 1, message)
		assertion("answerTopic", "table", 2, location)

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local result, err = this.performAction(forumUri.answer_topic, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "message_reponse", message }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
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
	self.editAnswer = function(messageId, message, location)
		assertion("editAnswer", { "number", "string" }, 1, messageId)
		assertion("editAnswer", "string", 2, message)
		assertion("editAnswer", "table", 3, location)

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

		return this.performAction(forumUri.edit_message, {
			{ 'f', location.f },
			{ 't', location.t },
			{ 'm', messageId },
			{ "message", message }
		}, forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)
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

		local result, err = this.performAction(forumUri.create_topic, postData, forumUri.new_poll .. "?f=" .. location.f .. "&s=" .. location.s)
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
	self.answerPoll = function(option, location, pollId)
		assertion("answerPoll", { "number", "table", "string" }, 1, option)
		assertion("answerPoll", "table", 2, location)
		assertion("answerPoll", { "number", "nil" }, 3, pollId)

		local isPrivatePoll = not not location.co
		if not isPrivatePoll and (not location.f or not location.t) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'") .. " " .. errorString.no_url_location .. " " .. string.format(errorString.no_url_location_private, "'co'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not pollId then
			local body = this.getPage((isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))

			pollId = tonumber(string.match(body, string.format(htmlChunk.hidden_value, forumUri.poll_id)))
			if not pollId then
				return nil, errorString.not_poll
			end
		end

		local optionIsString = type(option) == "string"
		if optionIsString or (type(option) == "table" and type(option[1]) == "string") then
			local options, err = self.getPoll(location)
			if err then
				return nil, err
			end
			options = options.options

			if optionIsString then
				local index = table.search(options, option, "value")
				if not index then
					return nil, errorString.poll_option_not_found
				end
				option = options[index].id
			else
				local tmpSet = table.createSet(options, "value")
				for i = 1, #option do
					if tmpSet[option[i]] then
						option[i] = tmpSet[option[i]].id
					else
						return nil, errorString.poll_option_not_found
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

		return this.performAction((isPrivatePoll and forumUri.answer_private_poll or forumUri.answer_poll), postData, (isPrivatePoll and (forumUri.conversation .. "?co=" .. location.co) or (forumUri.topic .. "?f=" .. location.f .. "&t=" .. location.t)))
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

		local body = this.getPage(forumUri.message_history .. "?forum=" .. location.f .. "&message=" .. messageId)

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
			state?<string,int> The state of the topic. An enum from 'enumerations.displayState'. (index or value)
		}
		@returns string,nil Result string.
		@returns nil,string Error message.
	]]
	self.updateTopic = function(location, data)
		assertion("updateTopic", "table", 1, location)
		assertion("updateTopic", { "table", "nil" }, 2, data)

		data = data or { }

		if not location.f or not location.s or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local topic, err = self.getTopic(location, true)
		if not topic then
			return nil, err
		end

		local postit = data.fixed
		if postit == nil then
			postit = topic.isFixed
		end

		if data.state then
			local err
			data.state, err = isEnum(data.state, "displayState", "data.state")
			if err then return nil, err end
		end

		return this.performAction(forumUri.update_topic, {
			{ 'f', location.f },
			{ 't', location.t },
			{ "titre", (data.title or topic.title) },
			{ "postit", (postit and "on" or '') },
			{ "etat", (data.state or enumerations.displayState.active) },
			{ 's', location.s }
		}, forumUri.edit_topic .. "?f=" .. location.f .. "&t=" .. location.t)
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
					return nil, err .. " (0x1)"
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
					return nil, err .. " (0x2)"
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
					return nil, err .. " (0x3)"
				end
			end
			link = forumUri.conversation .. "?co=" .. location.co
		elseif element == enumerations.element.poll then
			-- Poll ID
			if not location.f or not location.t then
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

		local message
		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				message, err = self.getMessage(messageId, location)
				if not message then
					return nil, err .. " (0x1)"
				end
				messageId = { message.id }
			else
				for i = 1, #messageId do
					message, err = self.getMessage(messageId, location)
					if not message then
						return nil, err .. " (0x2)"
					end
					messageId[i] = message.id
				end
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
	self.changeMessageContentState = function(messageId, contentState, location)
		assertion("changeMessageContentState", { "number", "table", "string" }, 1, messageId)
		assertion("changeMessageContentState", "string", 2, contentState)
		assertion("changeMessageContentState", "table", 3, location)

		local err
		contentState, err = isEnum(contentState, "contentState", nil, nil, true)
		if err then return nil, err end

		if not location.f or not location.t then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 't'")
		end

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local message
		local messageIdIsString = type(messageId) == "string"
		if messageIdIsString or (type(messageId) == "table" and type(messageId[1]) == "string") then
			if messageIdIsString then
				message, err = self.getMessage(messageId, location)
				if not message then
					return nil, err .. " (0x1)"
				end
				messageId = { message.id }
			else
				for i = 1, #messageId do
					message, err = self.getMessage(messageId, location)
					if not message then
						return nil, err .. " (0x2)"
					end
					messageId[i] = message.id
				end
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
		@param tribeId?<int> The tribe id. @default = Account's tribe id
		@returns table,nil The tribe data.
		@returns nil,string Error message.
		@struct {
			community = enumerations.community, -- The tribe community.
			creationDate = "", -- The date of the tribe creation.
			favoriteId = 0, -- The favorite id of the tribe, if 'isFavorited'.
			greetingMessage = "", -- The tribe greeting messages string field.
			id = 0, -- The tribe id.
			isFavorited = false, -- Whether the tribe is favorited or not.
			leaders = { "" }, -- The list of tribe leaders.
			name = "", -- The name of the tribe.
			presentation = "", -- The tribe presentation string field.
			recruitment = enumerations.recruitmentState -- The current recruitment state of the tribe.
		}
	]]
	self.getTribe = function(tribeId)
		assertion("getTribe", { "number", "nil" }, 1, tribeId)

		if not tribeId then
			if not this.isConnected then
				return nil, errorString.not_connected
			end

			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local body = this.getPage(forumUri.tribe .. "?tr=" .. tribeId)

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
			community = enumerations.community[community],
			creationDate = creationDate,
			favoriteId = fa,
			greetingMessage = greetingMessage,
			id = tribeId,
			isFavorited = not not fa,
			leaders = leaders,
			name = name,
			presentation = presentation,
			recruitment = enumerations.recruitmentState[string.lower(recruitment)]
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
				community = enumerations.community, -- The community of the member.
				name = "", -- The name of the member.
				rank = "", -- The name of the rank assigned to the member. (needs tribe permissions or to be a tribe member)
				timestamp = 0 -- The timestamp of when the member joined the tribe. (needs to be a tribe member)
			},
			_pages = 0, -- The total pages of the member list.
			_count = 0 -- The total of members in the tribe.
		}
	]]
	self.getTribeMembers = function(tribeId, pageNumber)
		assertion("getTribeMembers", { "number", "nil" }, 1, tribeId)
		assertion("getTribeMembers", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not tribeId then
			if not this.isConnected then
				return nil, errorString.not_connected
			end

			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		local uri = forumUri.tribe_members .. "?tr=" .. tribeId
		local totalPages, lastPageQuantity
		local members = getBigList(pageNumber, uri, function(members, body, _pageNumber, _totalPages)
			local counter = 0
			if tribeId == this.tribeId then
				string.gsub(body, htmlChunk.community .. ".-" .. htmlChunk.nickname .. ".-" .. htmlChunk.tribe_rank .. ".-" .. htmlChunk.ms_time, function(community, name, discriminator, _, rank, jointDate)
					counter = counter + 1
					members[counter] = {
						community = enumerations.community[community],
						name = name .. discriminator,
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
							community = enumerations.community[community],
							name = name .. discriminator,
							rank = rank
						}
					end)
				else
					string.gsub(body, htmlChunk.community .. ".-" .. htmlChunk.nickname, function(community, name, discriminator)
						counter = counter + 1
						members[counter] = {
							community = enumerations.community[community],
							name = name .. discriminator,
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
			lastPageQuantity = 0
			local body = this.getPage(uri .. "&p=" .. totalPages)
			string.gsub(body, htmlChunk.total_members, function()
				lastPageQuantity = lastPageQuantity + 1
			end)
			if lastPageQuantity == 0 then
				return nil, errorString.internal
			end
		end

		members._count = ((totalPages - 1) * 30) + lastPageQuantity
		return members
	end
	--[[@
		@file Tribe
		@desc Gets the ranks of a tribe.
		@param tribeId?<int,table> The tribe id. If the rank ids are necessary, send a location table from any forum in your own tribe instead (if it's from another tribe it will not affect the behavior of this function). @default Account's tribe id
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
	self.getTribeRanks = function(tribeId)
		assertion("getTribeRanks", { "number", "table", "nil" }, 1, tribeId)

		local location
		if type(tribeId) == "table" then
			location = tribeId
			tribeId = this.tribeId
		end

		if location and (not location.f or not location.s) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's'")
		end

		if not this.isConnected and (not tribeId or location) then
			return nil, errorString.not_connected
		end

		if not tribeId then
			if not this.tribeId then
				return nil, errorString.no_tribe
			end
			tribeId = this.tribeId
		end

		if location and tribeId ~= this.tribeId then
			location = nil
		end

		local body = this.getPage((location and (forumUri.edit_section_permissions .. "?f=" .. location.f .. "&s=" .. location.s) or (forumUri.tribe_members .. "?tr=" .. tribeId)))

		local ranks, counter = { }, 0

		if not location then
			local data = string.match(body, htmlChunk.tribe_rank_list)
			if not data then
				return nil, errorString.no_right
			end

			string.gsub(data, htmlChunk.tribe_rank, function(name)
				counter = counter + 1
				ranks[counter] = name
			end)
		else
			string.gsub(body, htmlChunk.tribe_rank_id, function(id, name)
				counter = counter + 1
				ranks[counter] = {
					id = id,
					name = name
				}
			end)
		end

		return ranks
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
	self.getTribeHistory = function(tribeId, pageNumber)
		assertion("getTribeHistory", { "number", "nil" }, 1, tribeId)
		assertion("getTribeHistory", { "number", "nil" }, 2, pageNumber)

		pageNumber = pageNumber or 1

		if not tribeId then
			if not this.isConnected then
				return nil, errorString.not_connected
			end

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
	self.getTribeForum = function(location)
		assertion("getTribeForum", { "table", "nil" }, 1, location)

		location = location or { tr = this.tribeId }

		if not location.tr and (not location.f or not location.s) then
			return nil, errorString.no_url_location .. " " .. string.format(errorString.no_required_fields, "'f', 's' / 'tr'")
		end

		local body = this.getPage(forumUri.tribe_forum .. (location.s and ("?f=" .. location.f .. "&s=" .. location.s) or ("?tr=" .. location.tr)))

		local sections, counter = { }, 0
		string.gsub(body, htmlChunk.tribe_section_id, function(f, s, name)
			counter = counter + 1
			sections[counter] = {
				f = tonumber(f),
				name = name,
				s = tonumber(s),
				tr = location.tr
			}
		end)

		return sections
	end
	--[[@
		@file Tribe
		@desc Updates the account's tribe's greetings message string field.
		@param message<string> The new message content.
		@returns string,nil Result string.
		@returns nil,string Error message.
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

		return this.performAction(forumUri.update_tribe_parameters, postData, forumUri.tribe .. "?tr=" .. this.tribeId)
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

		local err
		if data.community then
			data.community, err = isEnum(data.community, "community", "data.community")
			if err then return nil, err end

			postData[#postData + 1] = { "communaute", data.community }
		else
			postData[#postData + 1] = { "communaute", enumerations.community.xx }
		end
		if data.recruitment then
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
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@returns string,nil Result string.
		@returns nil,string Error message.
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
			local body = this.getPage(forumUri.tribe_forum .. "?tr=" .. this.tribeId)
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
			return nil, err .. " (0x1)"
		end
		oldSections = table.createSet(oldSections, 's')

		local result, err = this.performAction(forumUri.create_section, {
			{ 'f', location.f },
			{ 's', (location.s or 0) },
			{ "tr", (location.s and 0 or this.tribeId) },
			{ "nom", data.name },
			{ "icone", data.icon },
			{ "description", (data.description or data.name) },
			{ "caracteres", (data.min_characters or 4) }
		}, forumUri.new_section .. "?f=" .. location.f .. (location.s and ("&s=" .. location.s) or ("&tr=" .. this.tribeId)))

		if result then
			local currentSections
			currentSections, err = self.getTribeForum({
				f = location.f,
				s = location.s,
				tr = this.tribeId
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

		local section, err = self.getSection(location)
		if not section then
			return nil, err
		end

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
		@desc Sets the permissions of each rank for a specific section on the account's tribe's forum.
		@desc To allow _non-members_, use `enumerations.misc.non_member` or `"non_member"` in the permissions list.
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
	self.setTribeSectionPermissions = function(permissions, location)
		assertion("setTribeSectionPermissions", "table", 1, permissions)
		assertion("setTribeSectionPermissions", "table", 2, location)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if not this.tribeId then
			return nil, errorString.no_tribe
		end

		local ranks, err = self.getTribeRanks(nil, location)
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
							permissions[indexes[i]][j] = enumerations.misc.non_member
						else
							permissions[indexes[i]][j] = ranks_by_name[permissions[indexes[i]][j]].id
						end
						if not permissions[indexes[i]][j] then
							return nil, errorString.invalid_id .. " (in #" .. j .. " at '" .. indexes[i] .. "')"
						end
					end

					if not hasLeader and permissions[indexes[i]][j] == ranks[1].id then
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
					permissions[indexes[i]][#permissions[indexes[i]] + 1] = ranks[1].id
				end
			else
				permissions[indexes[i]] = defaultPermission
			end
		end

		return this.performAction(forumUri.update_section_permissions, {
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

	--[========================================================================================[ DEPRECATED
	-- > Micepix
	--[[@
		@file Micepix
		@desc Gets the images that were hosted by the logged account.
		@param pageNumber?<int> The page number of the gallery. To list ALL the gallery, use `0`. @default 1
		@returns table,nil The data of the images.
		@returns nil,string Error message.
		@struct {
			[n] = {
				id = "", -- The image id.
				timestamp = 0 -- The timestamp of when the image was hosted.
			},
			_pages = 0 -- The total pages of the images gallery.
		}
	]]
	self.getAccountImages = function(pageNumber)
		assertion("getAccountImages", { "number", "nil" }, 1, pageNumber)

		pageNumber = pageNumber or 1

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		return getList(pageNumber, forumUri.user_images_grid .. "?pr=" .. this.userId, function(code, _, timestamp)
			return {
				id = code,
				timestamp = tonumber(timestamp)
			}
		end, htmlChunk.image_id .. ".-" .. htmlChunk.profile_id .. ".-" .. htmlChunk.ms_time)
	end
	--[[@
		@file Micepix
		@desc Gets the latest images that were hosted by people on Micepix.
		@param quantity?<int> The quantity of images to be returned. Must be a number multiple of 16. @default 16
		@returns table,nil The data of the images.
		@returns nil,string Error message.
		@struct {
			[n] = {
				hoster = "", -- The name of the hoster of the image.
				id = "", -- The image id.
				timestamp = 0 -- The timestamp of when the image was hosted.
			}
		}
	]]
	self.getLatestImages = function(quantity)
		assertion("getLatestImages", { "number", "nil" }, 1, quantity)

		quantity = quantity or 16

		local r = quantity % 16
		if r > 0 then
			quantity = quantity - r + 16
		end

		local body, lastImage
		local pat = htmlChunk.image_id .. ".-" .. htmlChunk.profile_id .. ".-" .. htmlChunk.ms_time

		local images, counter = { }, 0
		for i = 1, quantity, 16 do
			body = this.getPage(forumUri.images_gallery .. (lastImage and ("?im=" .. lastImage) or ""))

			string.gsub(body, pat, function(code, name, timestamp)
				counter = counter + 1
				images[counter] = {
					hoster = self.formatNickname(name),
					id = code,
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
		@param isPublic?<boolean> Whether the image should appear in the gallery or not. @default false
		@returns table,nil A parsed-url location object.
		@returns nil,string Error message.
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
			[1] = boundaries[2],
			[2] = 'Content-Disposition: form-data; name="/KEY1/"',
			[3] = '',
			[4] = "/KEY2/",
			[5] = boundaries[2],
			[6] = 'Content-Disposition: form-data; name="fichier"; filename="Lautenschlager_id.' .. extension .. '"',
			[7] = "Content-Type: image/" .. extension,
			[8] = '',
			[9] = image
		}
		if isPublic then
			file[10] = boundaries[2]
			file[11] = 'Content-Disposition: form-data; name="enGalerie"'
			file[12] = ''
			file[13] = "on"
			file[14] = boundaries[3]
		else
			file[10] = boundaries[3]
		end

		local result, err = this.performAction(forumUri.upload_image, nil, forumUri.user_images_home, table.concat(file, separator.file))
		return redirect(result, err)
	end
	--[[@
		@file Micepix
		@desc Deletes an image from the account's micepix gallery.
		@param imageId<string,table> The image(s) id(s) to be deleted.
		@returns string,nil Result string.
		@returns nil,string Error message.
	]]
	self.deleteImage = function(imageId)
		assertion("deleteImage", { "string", "table" }, 1, imageId)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		if type(imageId) == "string" then
			imageId = { imageId }
		end
		return this.performAction(forumUri.remove_bulk_images, {
			{ "pr", this.userId },
			{ "im", table.concat(imageId, separator.forum_data) }
		}, forumUri.user_images .. "?pr=" .. this.userId)
	end
	]========================================================================================]
	-- > Miscellaneous
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
				community = enumerations.community, -- The community of the topic or player matched. (When 'searchType' is not 'tribe')
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

		local d, html, f, inif = ''
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
						author = self.formatNickname(author),
						community = enumerations.community[community],
						location = self.parseUrlData(post),
						timestamp = tonumber(timestamp),
						title = title
					}
				end
			else
				html = htmlChunk.topic_div .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.search_list .. ".-" .. htmlChunk.message_post_id .. ".-" .. htmlChunk.message_html .. ".-" .. htmlChunk.ms_time .. ".-" .. htmlChunk.profile_id
				f = function(community, post, title, postId, contentHtml, timestamp, author)
					return {
						author = self.formatNickname(author),
						community = enumerations.community[community],
						contentHtml = contentHtml,
						location = self.parseUrlData(post),
						post = postId,
						timestamp = tonumber(timestamp),
						title = title
					}
				end
			end

			d = "&ou=" .. data.searchLocation .. "&pr=" .. data.author .. "&f=" .. data.f .. "&c=" .. data.community .. "&s=" .. data.s, pageNumber
		else
			if searchType == enumerations.searchType.tribe then
				html = htmlChunk.tribe_list
				f = function(name, id)
					return {
						id = tonumber(id),
						name = name
					}
				end
				inif = function(head, body)
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

		return getList(pageNumber, forumUri.search .. "?te=" .. searchType .. "&se=" .. encodeUrl(search) .. d, f, html, inif)
	end
	--[[@
		@file Miscellaneous
		@desc Gets the topics created by a user.
		@param userName?<string,int> User name or user id. @default Account's id
		@returns table,nil The list of topics.
		@returns nil,string Error message.
		@struct {
			[n] = {
				community = enumerations.community, -- The community where the topic was created.
				location = parseUrlData, -- The location of the topic.
				timestamp = 0, -- The timestamp of when the topic was created.
				title = "", -- The title of the topic.
				totalMessages = 0 -- The total of messages of the topic.
			}
		}
	]]
	self.getCreatedTopics = function(userName)
		assertion("getCreatedTopics", { "string", "number", "nil" }, 1, userName)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.topics_started .. "?pr=" .. (userName and encodeUrl(userName) or this.userId))

		local topics, counter = { }, 0
		string.gsub(body, htmlChunk.topic_div .. ".-" .. htmlChunk.community .. ".-" .. htmlChunk.created_topic_data .. ".- on .-" .. htmlChunk.ms_time, function(community, topic, title, messages, timestamp)
			counter = counter + 1
			topics[counter] = {
				community = enumerations.community[community],
				location = self.parseUrlData(topic),
				timestamp = tonumber(timestamp),
				title = title,
				totalMessages = tonumber(messages)
			}
		end)

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
	self.getLastPosts = function(pageNumber, userName, extractNavbar)
		assertion("getLastPosts", { "number", "nil" }, 1, pageNumber)
		assertion("getLastPosts", { "string", "number", "nil" }, 2, userName)
		assertion("getLastPosts", { "boolean", "nil" }, 3, extractNavbar)

		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.posts .. "?pr=" .. (userName and encodeUrl(userName) or this.userId) .. "&p=" .. (pageNumber or 1))

		local totalPages = tonumber(string.match(body, htmlChunk.total_pages)) or 1

		local posts, counter = {
			_pages = totalPages
		}, 0
		string.gsub(body, htmlChunk.last_post .. htmlChunk.message_html .. ".-" .. htmlChunk.ms_time, function(navBar, post, topicTitle, postId, contentHtml, timestamp)
			counter = counter + 1
			posts[counter] = {
				contentHtml = contentHtml,
				location = self.parseUrlData(post),
				navbar = (extractNavbar and getNavbar(navBar, true) or nil),
				post = postId,
				timestamp = tonumber(timestamp),
				topicTitle = topicTitle
			}
		end)

		return posts
	end
	--[[@
		@file Miscellaneous
		@desc Gets the account's favorite topics.
		@returns table,nil The list of topics.
		@returns nil,string Error message.
		@struct {
			[n] = {
				community = enumerations.community, -- The community where the topic is located.
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
	self.getFavoriteTopics = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.favorite_topics)

		local topics, counter = { }, 0
		local navigation_bar, _, community

		string.gsub(body, htmlChunk.favorite_topics .. ".-" .. string.format(htmlChunk.hidden_value, forumUri.favorite_id) .. ".- on .-" .. htmlChunk.ms_time, function(navBar, favoriteId, timestamp)
			navigation_bar, _, community = getNavbar(navBar, true)
			if not navigation_bar then
				return nil, err .. " (0x1)"
			end

			counter = counter + 1
			topics[counter] = {
				community = (community and enumerations.community[community] or nil),
				favoriteId = tonumber(favoriteId),
				navbar = navigation_bar,
				timestamp = tonumber(timestamp)
			}
		end)

		return topics
	end
	--[[@
		@file Miscellaneous
		@desc Gets the account's friendlist.
		@returns table,nil The list of friends.
		@returns nil,string Error message.
	]]
	self.getFriendlist = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.friends .. "?pr=" .. this.userId)

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
		@returns table,nil The list of ignored users.
		@returns nil,string Error message.
	]]
	self.getBlacklist = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.blacklist .. "?pr=" .. this.userId)

		local blacklist, counter = { }, 0
		string.gsub(body, htmlChunk.blacklist_name, function(name)
			counter = counter + 1
			blacklist[counter] = name
		end)

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
	self.getFavoriteTribes = function()
		if not this.isConnected then
			return nil, errorString.not_connected
		end

		local body = this.getPage(forumUri.favorite_tribes)

		local tribes, counter = { }, 0

		string.gsub(body, htmlChunk.profile_tribe, function(name, tribeId)
			counter = counter + 1
			tribes[counter] = {
				id = tonumber(tribeId),
				name = name
			}
		end)

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
	self.getDevTracker = function()
		local body = this.getPage(forumUri.tracker)

		local posts, counter = { }, 0
		string.gsub(body, htmlChunk.topic_div .. htmlChunk.tracker, function(content)
			local navigation_bar, err = getNavbar(content)
			if not navigation_bar then
				return nil, err .. " (0x1)"
			end

			local navlen = #navigation_bar
			local postId = string.sub(navigation_bar[navlen].name, 2) -- #x
			navigation_bar[navlen] = nil

			local contentHtml, timestamp, admin = string.match(content, htmlChunk.message_html .. ".-" .. htmlChunk.ms_time .. ".-" .. htmlChunk.admin_name)
			if not contentHtml then
				return nil, errorString.internal .. " (0x2)"
			end

			counter = counter + 1
			posts[counter] = {
				author = admin .. "#0001",
				contentHtml = contentHtml,
				navbar = navigation_bar,
				post = postId,
				timestamp = tonumber(timestamp)
			}
		end)

		return posts
	end
	--[[@
		@file Miscellaneous
		@desc Adds a user as friend.
		@param userName<string> The user to be added.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@param userName<string> The user to be blacklisted.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@desc Removes a user from the blacklist.
		@param userName<string> The user to be removed from the blacklist.
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		if element == enumerations.element.topic or element == enumerations.element.poll then
			element = enumerations.element.topic
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
		@param favoriteId<int,string> The favorite id of the element.
		@param location?<table> The location of the element. (if `element` is `topic`)
		paramstruct location {
			int f The forum id.
			int t The topic id.
		}
		@returns string,nil Result string.
		@returns nil,string Error message.
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
		@param role<string,int<> The role id. An enum from @see listRole. (index or value)
		@returns table,nil The list of users.
		@returns nil,string Error message.
	]]
	self.getStaffList = function(role)
		assertion("getStaffList", { "string", "number" }, 1, role)

		local err
		role, err = isEnum(role, "listRole")
		if err then return nil, err end

		local result = this.getPage(forumUri.staff .. "?role=" .. role)
		local data, counter = { }, 0
		string.gsub(result, htmlChunk.nickname, function(name, discriminator)
			counter = counter + 1
			data[counter] = name .. discriminator
		end)

		return data
	end

	-- Compatibility Aliases
	self.deleteMicepixImage = self.deleteImage
	self.getTopicMessages = self.getAllMessages

	return self
end