local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Last posts:")
		local lastPosts, err = client.getLastPosts() -- Gets the last posts
		if lastPosts then
			p(lastPosts)		
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()