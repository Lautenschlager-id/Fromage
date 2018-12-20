local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

local print_profileData = function(data)
	local name             = data.name
	local id               = data.id
	local registrationDate = data.registrationDate
	local community        = data.community
	local highestRole      = data.highestRole
	local totalMessages    = data.totalMessages
	local totalPrestige    = data.totalPrestige
	local level            = data.level
	local title            = data.title
	local gender           = data.gender
	local birthday         = data.birthday
	local location         = data.location
	local soulmate         = data.soulmate
	local tribe            = data.tribe
	local tribeId          = data.tribeId
	local avatar           = data.avatarUrl
	local presentation     = data.presentation

	print(string.format([[
Name   : %s
Id     : %s
Since  : %s
From   : %s [%d]
Gender : %s [%d]
Lover  : %s

Staff : %s

Sent %d messages, has %d prestiges.
Level? %d, title «%s»

Birthday : %s
Location : %s

Tribe    : %s
Tribe Id : %s

Avatar : %s

Presentation : %s
]], 
		name,
		id,
		registrationDate,
		enumerations.community(community), community,
		enumerations.gender(gender), gender,
		soulmate,

		(highestRole and (enumerations.role(highestRole) .. " [" .. highestRole .. "]") or "No"),

		totalMessages, totalPrestige,
		level, title,

		birthday,
		location,

		tribe,
		tribeId,

		avatar,

		presentation
	))
end

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password) -- Needs a connection for 'getProfile(nil)'
	
	if client.isConnected() then
		print("Account's profile:")
		local myProfile, result = client.getProfile() -- Gets account's profile
		if myProfile then
			print_profileData(myProfile)
		else
			print(result)
		end

		print("Bolo's profile:")
		local boloProfile, result = client.getProfile("Bolodefchoco#0000") -- Gets Bolodefchoco's profile
		if boloProfile then
			print_profileData(boloProfile)
		else
			print(result)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()