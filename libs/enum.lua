local enum = setmetatablenum({ }, {
	--[[@
		@name enum
		@desc Creates a new enumeration.
		@param list<table> The table that will become an enumeration.
		@param ignoreConflict?<boolean> If the system should ignore value conflicts. (if there are identical values in @list) @default false
		@param __index?<function> A function to handle the __index metamethod of the enumeration. It receives the given index and @list.
		@returns enum A new enumeration.
	]]
	__call = function(_, list, ignoreConflit, __index)
		local reversed = { }

		for k, v in next, list do
			if not ignoreConflit and reversed[v] then
				return error("[ENUM] Enumeration conflict in " .. tostring(k) .. " and " .. tostring(reversed[v]))
			end
			reversed[v] = k
		end

		return setmetatablenum({ }, {
			__index = function(_, index)
				if __index then
					index = __index(index, list)
				end
				return list[index]
			end,
			__call = function(_, value)
				return reversed[value]
			end,
			__pairs = function()
				return next, list
			end,
			__len = function()
				return #list
			end,
			__newindex = function()
				return error("[ENUM] Can not overwrite enumerations.")
			end,
			__metatable = "enumeration"
		})
	end
})

enum._isValid = function(value, enum, showName, getIndex, stringValues)
	showName = showName and (" (" .. showName .. ")") or ''

	if not stringValues then
		if type(value) == "string" then
			if not enum[enum][value] then
				return nil, enum.errorString.invalid_enum .. showName
			end
			if getIndex then
				return value
			else
				return enum[enum][value]
			end
		else
			if not enum[enum](value) then
				return nil, enum.errorString.enum_out_of_range .. showName
			end
			if getIndex then
				return enum[enum](value)
			else
				return value
			end
		end
	else
		if enum[enum][value] then
			if getIndex then
				return value
			else
				return enum[enum][value]
			end
		elseif enum[enum](value) then
			if getIndex then
				return enum[enum](value)
			else
				return value
			end
		else
			return nil, enum.errorString.invalid_enum .. showName
		end
	end
end

--[[@
	@desc The ID of each forum element.
	@type int
]]
enum.element = enum {
	topic           = 03,
	message         = 04,
	tribe           = 09,
	profile         = 10,
	private_message = 12,
	poll            = 34,
	image           = 45
}
--[[@
	@desc The ID of each forum community.
	@type int
]]
enum.community = enum({
	xx = 01,
	fr = 02,
	br = 04,
	es = 05,
	cn = 06,
	tr = 07,
	vk = 08,
	pl = 09,
	hu = 10,
	nl = 11,
	ro = 12,
	id = 13,
	de = 14,
	en = 15,
	ar = 16,
	ph = 17,
	lt = 18,
	jp = 19,
	fi = 21,
	cz = 22,
	hr = 23,
	bu = 25,
	lv = 26,
	he = 27,
	it = 28,
	ee = 29,
	az = 30
}, function(index)
	if index == "gb" then
		return "en"
	elseif index == "sa" then
		return "ar"
	elseif index == "il" then
		return "he"
	end
	return index
end)
--[[@
	@desc The ID of each forum.
	@type int
]]
enum.forum = enum {
	atelier801              = 000005,
	transformice            = 000006,
	bouboum                 = 000007,
	fortoresse              = 000008,
	nekodancer              = 508574,
	transformice_adventures = 841223
}
--[[@
	@desc The names of the official sections.
	@type string
]]
enum.section = enum {
	announcements   = "announcements",
	discussions     = "discussions",
	off_topic       = "off_topic",
	forum_games     = "forum_games",
	tribes          = "tribes",
	map_submissions = "map_submissions",
	map_editor      = "map_editor",
	modules         = "modules",
	fanart          = "fanart",
	suggestions     = "suggestions",
	bugs            = "bugs",
	archives        = "archives",
}
--@ Private enum
local section_ID = {
	fr = {
		atelier801   = 08,
		transformice = 04,
		others       = 01
	},
	br = {
		atelier801   = 16,
		transformice = 18,
		others       = 03
	},
	es = {
		atelier801   = 20,
		transformice = 25,
		others       = 04
	},
	cn = {
		atelier801   = 24,
		transformice = 32,
		others       = 05
	},
	tr = {
		atelier801   = 28,
		transformice = 39,
		others       = 06
	},
	vk = {
		atelier801   = 32,
		transformice = 46,
		others       = 07
	},
	pl = {
		atelier801   = 36,
		transformice = 53,
		others       = 08
	},
	hu = {
		atelier801   = 40,
		transformice = 60,
		others       = 09
	},
	nl = {
		atelier801   = 44,
		transformice = 67,
		others       = 10
	},
	ro = {
		atelier801   = 48,
		transformice = 74,
		others       = 11
	},
	id = {
		atelier801   = 52,
		transformice = 81,
		others       = 12
	},
	de = {
		atelier801   = 56,
		transformice = 88,
		others       = 13
	},
	en = {
		atelier801   = 60,
		transformice = 95,
		others       = 14
	},
	ar = {
		atelier801   = 077,
		transformice = 104,
		others       = 015
	},
	ph = {
		atelier801   = 081,
		transformice = 111,
		others       = 016
	},
	lt = {
		atelier801   = 085,
		transformice = 118,
		others       = 017
	},
	jp = {
		atelier801   = 089,
		transformice = 125,
		others       = 018
	},
	fi = {
		atelier801   = 093,
		transformice = 132,
		others       = 019
	},
	cz = {
		atelier801   = 123,
		transformice = 176,
		others       = 022
	},
	hr = {
		atelier801   = 127,
		transformice = 183,
		others       = 023
	},
	bu = {
		atelier801   = 135,
		transformice = 197,
		others       = 025
	},
	lv = {
		atelier801   = 139,
		transformice = 204,
		others       = 026
	},
	he = {
		atelier801   = 101,
		transformice = 146,
		others       = 021
	},
	it = {
		atelier801   = 097,
		transformice = 139,
		others       = 020
	},
	ee = {
		atelier801   = 143,
		transformice = 211,
		others       = 027
	},
	az = {
		atelier801   = 147,
		transformice = 218,
		others       = 028
	}
}
local section_VALUE = {
	atelier801 = {
        announcements = -1,
        discussions   = 0,
        off_topic     = 1,
        forum_games   = 2,
        tribes        = 3
	},
	transformice = {
        map_submissions = -1,
        discussions     = 0,
        map_editor      = 1,
        modules         = 2,
        fanart          = 3,
        suggestions     = 4,
        bugs            = 5,
        archives        = 6
	},
	bouboum = {
		discussions = 0
	},
	fortoresse = {
		discussions = 0
	},
	nekodancer = {
		discussions = 0
	}
}
--[[@
	@desc The path location of the official sections on forums.
	@type table
	@tree [enums.community]
	@tree 	└ [enums.forum]
	@tree 		└ [enums.section]
]]
enum.location = { }
for community, ids in next, section_ID do
	enum.location[community] = { }

	for forum, data in next, section_VALUE do
		enum.location[community][forum] = { }

		local id = ids[forum]
		if not id then
			id = ids.others
		end

		for name, value in next, data do
			if value >= 0 then
				enum.location[community][forum][name] = value + id
			end
		end

		enum.location[community][forum] = enum(enum.location[community][forum])
	end

	enum.location[community] = enum(enum.location[community])
end
enum.location.xx = enum {
	atelier801 = enum {
		announcements = 1
	},
	transformice = enum {
		map_submissions = 102
	},
	transformice_adventures = enum {
		announcements = 1,
		discussions   = 2,
		bugs          = 3
	}
}
enum.location = enum(enum.location)
--[[@
	@desc The IDs of the available display states of an element. (Topic, Section, ...)
	@type int
]]
enum.displayState = enum {
	active  = 0,
	locked  = 1,
	deleted = 2
}
--[[@
	@desc The IDs of the available locales on the mail box.
	@type int
]]
enum.inboxLocale = enum {
	inbox    = 0,
	archives = 1,
	bin      = 2
}
--[[@
	@desc The IDs of the available display states of a message.
	@type int
]]
enum.messageState = enum {
	active    = 0,
	moderated = 1
}
--[[@
	@desc The content state for image (un)restrictions.
	@type string
]]
enum.contentState = enum {
	restricted   = "true",
	unrestricted = "false"
}
--[[@
	@desc The IDs of the roles of each staff discriminator.
	@type int
]]
enum.role = enum {
	administrator = 01,
	moderator     = 10,
	sentinel      = 15,
	mapcrew       = 20
}
--[[@
	@desc The IDs of the search types.
	@type int
]]
enum.searchType = enum {
	message_topic = 04,
	tribe         = 09,
	player        = 10
}
--[[@
	@desc The search locales for the specific `SearchType.message_topic` enumeration.
	@type int
]]
enum.searchLocation = enum {
	posts  = 1,
	titles = 2,
	both   = 3
}
--[[@
	@desc The available icons for sections.
	@type string
]]
enum.sectionIcon = enum {
	nekodancer     = "nekodancer.png",
	fortoresse     = "fortoresse.png",
	balloon_cheese = "bulle-fromage.png",
	transformice   = "transformice.png",
	balloon_dots   = "bulle-pointillets.png",
	wip            = "wip.png",
	megaphone      = "megaphone.png",
	skull          = "crane.png",
	atelier801     = "atelier801.png",
	brush          = "pinceau.png",
	grass          = "picto.png",
	bouboum        = "bouboum.png",
	hole           = "trou-souris.png",
	deadmaze       = "deadmaze.png",
	cogwheel       = "roue-dentee.png",
	dice           = "de.png",
	flag           = "drapeau.png",
	runforcheese   = "runforcheese.png"
}
--[[@
	@desc The available roles for the staff list.
	@type int
]]
enum.listRole = enum {
	moderator         =    0001,
	sentinel          =    0004,
	arbitre           =    0008,
	mapcrew           =    0016,
	module_team       =    0032,
	anti_hack_brigade =    0064,
	administrator     =    0128,
	votecrew          =    0512,
	translator        =    1024,
	funcorp           =    2048
}
--[[@
	@desc The available forum titles.
	@type string
]]
enum.forumTitle = enum {
	[1] = "Citizen",
	[2] = "Censor",
	[3] = "Consul",
	[4] = "Senator",
	[5] = "Archon",
	[6] = "Heliast"
}
--[[@
	@desc The available icons for a topic.
	@type string
]]
enum.topicIcon = enum {
	poll               = "sondage%.png",
	private_discussion = "bulle%-pointillets%.png",
	private_message    = "enveloppe%.png",
	postit             = "postit%.png",
	locked             = "cadenas%.png",
	deleted            = "/no%.png"
}
--[[@
	@desc The available genders on profile.
	@type int
]]
enum.gender = enum {
	none   = 0,
	female = 1,
	male   = 2
}
--[[@
	@desc The state of a member in a conversation.
	@type string
]]
enum.memberState = enum {
	author = "author",
	excluded = "excluded",
	invited = "invited",
	gone = "gone"
}
--[[@
	@desc The recruitment state for tribes.
	@type int
]]
enum.recruitmentState = enum {
	closed = 0,
	open   = 1
}
--[[@
	@desc Miscellaneous values for various purposes.
	@desc `non_member` -> Tribe section permission to allow non members to have access to something.
	@type int
]]
enum.misc = enum {
	non_member = -2
}


--[[ New ones, to test ]]--
enum.cookieState = enum {
	login       = 0, -- Get all cookies
	after_login = 1, -- Get all cookies after login
	action      = 2  -- ^, except the ones in the `nonActionCookie` set
}

enum.nonActionCookie = enum {
	JSESSIONID = true,
	token      = true,
	token_date = true
}

enum.separator = enum {
	cookie     = "; ",
	forum_data = "§#§",
	file       = "\r\n"
}

enum.forumUri = enum {
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

enum.htmlChunk = enum {
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

enum.errorString = enum {
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


return enum