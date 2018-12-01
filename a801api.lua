--[[ Dependencies ]]--
local http = require("coro-http")

--[[ Aux ]]--
local cryptToSha256 
do
	local required, openssl = pcall(require, "openssl")
	assert(required, "\"openssl\" module not found.")

	local sha256 = openssl.digest.get("sha256")
	cryptToSha256 = function(str)
		local hash = openssl.digest.new(sha256)
		hash:update(str)
		return hash:final()
	end
end

--[[ Class ]]--
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

return function()
	local this = { }
	local self = { }

	

	return self
end
