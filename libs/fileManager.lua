require("extensions")

-- Optimization --
local os_time = os.time
------------------

local boundaries = { }
do
	boundaries[1] = "Lautenschlager_Fromage_" .. os_time()
	boundaries[2] = "--" .. boundaries[1]
	boundaries[3] = boundaries[2] .. "--"
end

local fileExtensions = { "png", "jpg", "jpeg", "gif" }

local getFile = function(f)
	if string.find(f, "https?://") then
		local _, body = http.request("GET", f)
		return body
	else
		f = os.readFile(f)
		if f then
			return f
		end
	end
end

local getExtension = function(f)
	local extension
	for i = 1, #fileExtensions do
		if string.find(f, "%." .. fileExtensions[i]) then
			extension = fileExtensions[i]
			break
		end
	end
	if extension == "jpg" then
		extension = "jpeg"
	end
	return extension
end

local buildFileContent = function(name, id, extension, image)
	return {
		boundaries[2],
		'Content-Disposition: form-data; name="' .. name .. '"',
		'',
		id,
		boundaries[2],
		'Content-Disposition: form-data; name="fichier"; filename="Lautenschlager_id.' .. extension .. '"',
		"Content-Type: image/" .. extension,
		'',
		image,
		boundaries[2],
		'Content-Disposition: form-data; name="/KEY1/"',
		'',
		"/KEY2/",
		boundaries[3]
	}
end

return {
	boundaries = boundaries,
	getExtension = getExtension,
	getFile = getFile,
	buildFileContent = buildFileContent
}