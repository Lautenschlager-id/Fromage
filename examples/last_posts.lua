local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Last posts:")
		local lastPosts, err = client.getLastPosts() -- Gets the last posts
		if lastPosts then
			for i = 1, #lastPosts do
				print("In [" .. lastPosts[i].location.data.f .. ", " .. lastPosts[i].location.data.t .. " - " .. lastPosts[i].topicTitle .. "] post #" .. lastPosts[i].post .. " on " .. os.date("%c", lastPosts[i].timestamp / 1000) .. ":\n" .. string.sub(lastPosts[i].messageHtml, 1, 100))
			end			
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()