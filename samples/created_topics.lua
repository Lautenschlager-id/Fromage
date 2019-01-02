local api = require("fromage")
local client = api()
local enumerations = client.enumerations()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Topics created:")
		local topics, err = client.getCreatedTopics("Bolodefchoco#0000") -- Gets the topics created by someone
		if topics then
			p(topics)		
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()