-- Optimization --
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
------------------

local getPasswordHash
do
	local openssl = require("openssl") -- built-in
	local sha256 = openssl.digest.get("sha256")

	-- Aux function to getPasswordHash
	local cryptToSha256 = function(str)
		local hash = openssl.digest.new(sha256)
		hash:update(str)
		return hash:final()
	end

	local saltBytes = {
		247, 026, 166, 222,
		143, 023, 118, 168,
		003, 157, 050, 184,
		161, 086, 178, 169,
		062, 221, 067, 157,
		197, 221, 206, 086,
		211, 183, 164, 005,
		074, 013, 008, 176
	}
	local chars = { }
	for i = 1, #saltBytes do
		chars[i] = string_char(saltBytes[i])
	end
	saltBytes = table_concat(chars)

	local base64_encode = require("base64").encode -- built-in
	--[[@
		@name getPasswordHash
		@desc Encrypts the account's password.
		@param password<string> The account's password.
		@returns string The encrypted password.
	]]
	getPasswordHash = function(password)
		local hash = cryptToSha256(password)
		hash = cryptToSha256(hash .. saltBytes)
		local len = #hash

		local out, counter = { }, 0
		for i = 1, len, 2 do
			counter = counter + 1
			out[counter] = string_char(tonumber(string_sub(hash, i, (i + 1)), 16))
		end

		return base64_encode(table_concat(out))
	end
end