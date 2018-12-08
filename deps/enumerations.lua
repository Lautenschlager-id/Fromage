local enum = require("enum")

return {
	inboxLocale = enum {
		inbox = 0,
		archives = 1,
		bin = 2
	},
	conversationState = enum {
		open = 0,
		closed = 1
	},
	element = enum {
		topic = 3,
		message = 4,
		tribe = 9,
		profile = 10,
		private_message = 12,
		poll = 34,
		image = 45
	},
	gender = enum {
		none = 0,
		female = 1,
		male = 2
	},
	community = enum {
		xx = 1,
		fr = 2,
		br = 4,
		es = 5,
		cn = 6,
		tr = 7,
		vk = 8,
		pl = 9,
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
		ch = 20,
		fi = 21,
		cz = 22,
		sk = 23,
		hr = 24,
		bu = 25,
		lv = 26,
		he = 27,
		it = 28,
		et = 30,
		az = 31,
		pt = 33
	},
	recruitmentState = enum {
		closed = 0,
		open = 1
	},
	displayState = enum {
		open = 0,
		locked = 1,
		deleted = 2
	},
	messageState = enum {
		active = 0,
		moderated = 1
	},
	contentState = enum {
		restricted = "true",
		unrestricted = "false"
	},
	sectionIcon = enum {
		nekodancer = "nekodancer.png",
		fortoresse = "fortoresse.png",
		balloon_cheese = "bulle-fromage.png",
		transformice = "transformice.png",
		balloon_dots = "bulle-pointillets.png",
		wip = "wip.png",
		megaphone = "megaphone.png",
		skull = "crane.png",
		atelier801 = "atelier801.png",
		brush = "pinceau.png",
		grass = "picto.png",
		bouboum = "bouboum.png",
		hole = "trou-souris.png",
		deadmaze = "deadmaze.png",
		cogwheel = "roue-dentee.png",
		dice = "de.png",
		flag = "drapeau.png",
		runforcheese = "runforcheese.png"
	},
	misc = enum {
		non_member = -2
	},
	listRole = enum {
		moderator = 1,
		sentinel = 4,
		arbitre = 8,
		mapcrew = 16,
		module_team = 32,
		anti_hack_brigade = 64,
		administrator = 128,
		votecrew = 512,
		translator = 1024,
		funcorp = 2048
	},
	role = enum {
		administrator = 1,
		moderator = 1,
		sentinel = 15,
		mapcrew = 20
	},
	forumTitle = enum {
		[1] = "Citizen",
		[2] = "Censor",
		[3] = "Consul",
		[4] = "Senator",
		[5] = "Archon",
		[6] = "Heliast"
	},
	topicIcon = enum {
		poll = "/sondage.png",
		private_discussion = "/bulle-pointillets.png",
		private_message = "/enveloppe.png",
		postit = "/postit.png",
		locked = "/cadenas.png",
		deleted = "/no.png"
	}
}