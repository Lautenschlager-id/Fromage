local account = load(io.open("account", 'r'):read("*a"))()

local api = require("../api")

coroutine.wrap(function()
	local client = api()
	client.connect(account.username, account.password)
	
	if client.isConnected() then
		print("Account's images:")
		local images, err = client.getAccountImages(0) -- Gets all images hosted by the account
		if images then
			print("Pages: " .. images._pages)
			for i = 1, #images do
				print("Image " .. images[i].imageId .. " created on " .. os.date("%c", images[i].timestamp / 1000))
			end
		else
			print(err)
		end

		print("Latest images:")
		images, err = client.getLatestImages() -- Gets the last 16 images hosted on micepix
		if images then
			for i = 1, #images do
				print("Image " .. images[i].imageId .. " created by " .. images[i].author .. " on " .. os.date("%c", images[i].timestamp / 1000))
			end
		else
			print(err)
		end

		local image
		image, err = client.uploadImage("http://images.atelier801.com/167b32d18e3.png", true) -- Uploads an image on micepix
		if image then
			print("Image id: " .. image.data.im)

			local time = os.time() + 10 -- 10 seconds
			while os.time() < time do end

			print("Deleting image:")
			print(client.deleteMicepixImage(image.data.im)) -- Deletes the hosted image
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()