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
	ch	=	20,
	fi	=	21,
	cz	=	22,
	sk	=	23,
	hr	=	24,
	bu	=	25,
	lv	=	26,
	he	=	27,
	it	=	28,
	et	=	30,
	az	=	31,
	pt	=	33
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
		discussions	=	0,
		off_topic	=	1,
		forum_games	=	2,
		tribes		=	3
	},
	transformice = e {
		discussions	=	0,
		map_editor	=	1,
		modules		=	2,
		fanart		=	3,
		suggestions	=	4,
		bugs		=	5,
		archives	=	6
	},
	bouboum = e {
		discussions	=	0
	},
	fortoresse = e {
		discussions	=	0
	},
	nekodancer = e {
		discussions	=	0
	},

	en = e {
		atelier801	=	60,
		transformice=	95,
		bouboum		=	14,
		fortoresse	=	14,
		nekodancer	=	14
	},
	
}
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