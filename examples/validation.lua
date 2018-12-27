local api = require("fromage")
local client = api()

coroutine.wrap(function()
	client.connect("Username#0000", "password")
	
	if client.isConnected() then
		print("Setting first e-mail:")
		print(client.setEmail("example@api.com", true)) -- Sets the new e-mail

		local isValidated = client.isAccountValidated() -- Checks whether the account is validated or not
		print(isValidated)

		if not isValidated then -- Checks whether the account is already validated or not
			print("Send validation code to the e-mail:")
			print(client.requestValidationCode()) -- Request the validation code to be sent to your e-mail

			print("Code: ")
			local code = io.read() -- Reads the code, since this API does not provide a connection to your e-mail
			print(client.submitValidationCode(code)) -- Sends the code you received in your e-mail
		end

		print("Setting new password:")
		print(client.setPassword("123", true)) -- Sets the new password
	end

	client.disconnect()
	os.execute("pause >nul")
end)()