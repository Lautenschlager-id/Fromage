local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

local print_tribeData = function(data)
	local id               = data.id
	local name             = data.name
	local creationDate     = data.creationDate
	local community        = data.community
	local recruitment      = data.recruitment
	local leaders          = data.leaders
	local greetingMessage  = data.greetingMessage
	local presentation     = data.presentation
	local isFavorited      = data.isFavorited
	local favoriteId       = data.favoriteId

	print(string.format([[
Id        : %d
Name      : %s
Creation  : %s
Community : %s [%s]

Recruitment : %s [%s]

Leaders : %s

Is favorited : %s
Favorite Id  : %s

Greetings : %s

Presentation : %s
]], 
		id,
		name,
		creationDate,
		enumerations.community(community), community,

		enumerations.recruitmentState(recruitment), recruitment,

		table.concat(leaders, ", "),

		isFavorited,
		favoriteId,

		greetingMessage,

		presentation
	))
end

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Tribe's profile:")
		local tribe, err = client.getTribe() -- Gets the client's tribe
		if tribe then
			print_tribeData(tribe)
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()