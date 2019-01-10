local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Account's images:")
		local images, err = client.getAccountImages(0) -- Gets all images hosted by the account
		if images then
			p(images)
		else
			print(err)
		end

		print("Latest images:")
		images, err = client.getLatestImages() -- Gets the last 16 images hosted on micepix
		if images then
			p(images)
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
			print(client.deleteImage(image.data.im)) -- Deletes the hosted image
		else
			print(err)
		end
	end

	client.disconnect()
	os.execute("pause >nul")
end)()