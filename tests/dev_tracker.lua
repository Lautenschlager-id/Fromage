local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")
local enumerations = require("../deps/enumerations")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		local lastMessages, err = client.getDevTracker() -- Gets the last messages posted in dev-tracker
		if lastMessages then
			for i = 1, #lastMessages do
				print(lastMessages[i].navbar[#lastMessages[i].navbar].name .. " / #" .. lastMessages[i].post .. ", on " .. os.date("%c", lastMessages[i].timestamp / 1000) .. " by " .. lastMessages[i].author .. ": \n" .. string.sub(lastMessages[i].messageHtml, 1, 100) .. "...")
			end
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()