local e = require("enum")

local enum = { }
enum.enum = enum

--[[@

]]
enum.element = e {
	topic			=	03,
	message			=	04,
	tribe			=	09,
	profile			=	10,
	private_message	=	12,
	poll			=	34,
	image			=	45
}
--[[@

]]
enum.community = e {
	xx	=	01,
	fr	=	02,
	br	=	04,
	es	=	05,
	cn	=	06,
	tr	=	07,
	vk	=	08,
	pl	=	09,
	hu	=	10,
	nl	=	11,
	ro	=	12,
	id	=	13,
	de	=	14,
	en	=	15,
	ar	=	16,
	ph	=	17,
	lt	=	18,
	jp	=	19,
	fi	=	21,
	cz	=	22,
	hr	=	23,
	bu	=	25,
	lv	=	26,
	he	=	27,
	it	=	28,
	ee	=	29,
	az	=	30
}
--[[@

]]
enum.forum = e {
	atelier801		=	000005,
	transformice	=	000006,
	bouboum			=	000007,
	fortoresse		=	000008,
	nekodancer		= 	508574
}
--[[@

]]
enum.section = e {
	atelier801 = e {
		announcements	=	-1,
		discussions		=	0,
		off_topic		=	1,
		forum_games		=	2,
		tribes			=	3
	},
	transformice = e {
		map_submissions	=	-1,
		discussions		=	0,
		map_editor		=	1,
		modules			=	2,
		fanart			=	3,
		suggestions		=	4,
		bugs			=	5,
		archives		=	6
	},
	bouboum = e {
		discussions	=	0
	},
	fortoresse = e {
		discussions	=	0
	},
	nekodancer = e {
		discussions	=	0
	}
}
--@ Private enum
local section_ID = {
	fr = {
		atelier801	=	08,
		transformice=	04,
		others		=	01
	},
	br = {
		atelier801	=	16,
		transformice=	18,
		others		=	03
	},
	es = {
		atelier801	=	20,
		transformice=	25,
		others		=	04
	},
	cn = {
		atelier801	=	24,
		transformice=	32,
		others		=	05
	},
	tr = {
		atelier801	=	28,
		transformice=	39,
		others		=	06
	},
	vk = {
		atelier801	=	32,
		transformice=	46,
		others		=	07
	},
	pl = {
		atelier801	=	36,
		transformice=	53,
		others		=	08
	},
	hu = {
		atelier801	=	40,
		transformice=	60,
		others		=	09
	},
	nl = {
		atelier801	=	44,
		transformice=	67,
		others		=	10
	},
	ro = {
		atelier801	=	48,
		transformice=	74,
		others		=	11
	},
	id = {
		atelier801	=	52,
		transformice=	81,
		others		=	12
	},
	de = {
		atelier801	=	56,
		transformice=	88,
		others		=	13
	},
	en = {
		atelier801	=	60,
		transformice=	95,
		bouboum		=	14,
		fortoresse	=	14,
		nekodancer	=	14
	},
	ar = {
		atelier801	=	077,
		transformice=	104,
		others		=	015
	},
	ph = {
		atelier801	=	081,
		transformice=	111,
		others		=	016
	},
	lt = {
		atelier801	=	085,
		transformice=	118,
		others		=	017
	},
	jp = {
		atelier801	=	089,
		transformice=	125,
		others		=	018
	},
	fi = {
		atelier801	=	093,
		transformice=	132,
		others		=	019
	},
	cz = {
		atelier801	=	123,
		transformice=	176,
		others		=	022
	},
	hr = {
		atelier801	=	127,
		transformice=	183,
		others		=	023
	},
	bu = {
		atelier801	=	135,
		transformice=	197,
		others		=	025
	},
	lv = {
		atelier801	=	139,
		transformice=	204,
		others		=	026
	},
	he = {
		atelier801	=	101,
		transformice=	146,
		others		=	021
	},
	it = {
		atelier801	=	097,
		transformice=	139,
		others		=	020
	},
	ee = {
		atelier801	=	143,
		transformice=	211,
		others		=	027
	},
	az = {
		atelier801	=	147,
		transformice=	218,
		others		=	028
	}
}
--[[@

]]
enum.location = { }
for community, ids in next, section_ID do
	enum.section[community] = { }

	for forum, data in pairs(enum.section) do
		enum.section[community][forum] = { }

		local id = ids[forum]
		if not id then
			id = ids.others
		end

		for name, value in next, data do
			if value >= 0 then
				enum.section[community][forum][name] = value + id
			end
		end

		enum.section[community][forum] = e(enum.section[community][forum])
	end

	enum.section[community] = e(enum.section[community])
end
enum.location.xx = e {
	atelier801 = e {
		announcements = 1
	},
	transformice = e {
		map_submissions = 102
	}
}
--[[ Structure
enum
	section
		en
			atelier801
				discussions
			transformice
				modules
		xx
			transformice
				map_submissions
]]
enum.location = e(enum.location)
--[[@

]]
enum.displayState = e {
	open	=	0,
	locked	=	1,
	deleted	=	2
}
--[[@

]]
enum.inboxLocale = e {
	inbox	=	0,
	archives=	1,
	bin		=	2
}
--[[@

]]
enum.messageState = e {
	active		=	0,
	moderated	=	1
}
--[[@

]]
enum.contentState = e {
	restricted	=	"true",
	unrestricted=	"false"
}
--[[@

]]
enum.role = e {
	administrator	=	1,
	moderator		=	1,
	sentinel		=	15,
	mapcrew			=	20
}
--[[@

]]
enum.sectionIcon = e {
	nekodancer		=	"nekodancer.png",
	fortoresse		=	"fortoresse.png",
	balloon_cheese	=	"bulle-fromage.png",
	transformice	=	"transformice.png",
	balloon_dots	=	"bulle-pointillets.png",
	wip				=	"wip.png",
	megaphone		=	"megaphone.png",
	skull			=	"crane.png",
	atelier801		=	"atelier801.png",
	brush			=	"pinceau.png",
	grass			=	"picto.png",
	bouboum			=	"bouboum.png",
	hole			=	"trou-souris.png",
	deadmaze		=	"deadmaze.png",
	cogwheel		=	"roue-dentee.png",
	dice			=	"de.png",
	flag			=	"drapeau.png",
	runforcheese	=	"runforcheese.png"
}
--[[@

]]
enum.listRole = e {
	moderator			=	0001,
	super_moderator		=	nil, -- 0002
	sentinel			=	0004,
	arbitre				=	0008,
	mapcrew				=	0016,
	module_team			=	0032,
	anti_hack_brigade	=	0064,
	administrator		=	0128,
	fashion_squad		=	nil, -- 0256
	votecrew			=	0512,
	translator			=	1024,
	funcorp				=	2048
}
--[[@

]]
enum.forumTitle = e {
	[1]	=	"Citizen",
	[2]	=	"Censor",
	[3]	=	"Consul",
	[4]	=	"Senator",
	[5]	=	"Archon",
	[6]	=	"Heliast"
}
--[[@

]]
enum.topicIcon = e {
	poll				=	"sondage.png",
	private_discussion	=	"bulle-pointillets.png",
	private_message		=	"enveloppe.png",
	postit				=	"postit.png",
	locked				=	"cadenas.png",
	deleted				=	"/no.png"
}
--[[@

]]
enum.gender = e {
	none	=	0,
	female	=	1,
	male	=	2
}
--[[@

]]
enum.recruitmentState = e {
	closed	=	0,
	open	=	1
}
--[[@

]]
enum.misc = e {
	non_member	=	-2
}

return enum