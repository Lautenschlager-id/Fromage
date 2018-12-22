local account = load(io.open("account", 'r'):read("*a"))()

local api = require("fromage")
local client = api()
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Topics created:")
		local topics, err = client.getCreatedTopics("Bolodefchoco#0000") -- Gets the topics created by someone
		if topics then
			for i = 1, #topics do
				print("[" .. enumerations.community(topics[i].community) .. " - " .. topics[i].location.data.f .. ", " .. topics[i].location.data.t .. "] " .. topics[i].title .. ", " .. topics[i].totalMessages .. " messages. Created on " .. os.date("%c", topics[i].timestamp / 1000))
			end			
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()