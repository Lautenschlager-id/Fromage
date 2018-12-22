local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		local topic = client.createTopic("Testing API", "Aye Hey Hi", {
			f = enumerations.forum.atelier801,
			s = 167
		}) -- Creates a topic
		print("Reporting message:")
		print(client.reportElement(enumerations.element.message, '1', "This is a test", topic.data))

		local user = client.getProfile() -- Gets the account's profile
		print("Reporting profile:")
		print(client.reportElement(enumerations.element.profile, user.id, "This is a test"))

		print("Reporting tribe:")
		print(client.reportElement(enumerations.element.tribe, user.tribeId, "This is a test"))

		local pm = client.createPrivateMessage("Trumpuke#0000", "PM", "[b]hahaha[/b]ha!") -- Creates a private message
		print("Reporting private message:")
		print(client.reportElement(enumerations.element.private_message, '1', "This is a test", pm.data))

		local image = client.getAccountImages()[1] -- Gets the last image hosted by the client
		print("Reporting image:")
		print(client.reportElement(enumerations.element.image, image.id, "This is a test"))

		local poll = client.createPoll("Poll test", "That's the question", { "To be", "Not to be" }, {
			f = enumerations.forum.atelier801,
			s = 167
		}, { public = true, multiple = true }) -- Creates a poll
		print("Reporting poll:")
		print(client.reportElement(enumerations.element.poll, poll.data.t, "Testando última vez o report uhu se alegrem por mim", poll.data))
	end

	client.disconnect()
	os.execute("pause >nul")
end)()