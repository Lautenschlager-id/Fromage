local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
return {
	encode = function(code)
		if not code then return end
		code = string.gsub(code, "\r\n", "\n")

		return (string.gsub((string.gsub(code, '.', function(x)
			local r, b = '', string.byte(x)

			for i = 8, 1, -1 do
				r = r .. (b%2^i - b%2^(i-1) > 0 and '1' or '0')
			end

			return r
		end) .. '0000'), '%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then
				return ''
			end

			local c = 0

			for i = 1, 6 do
				c = c + (string.sub(x, i,i)=='1' and 2^(6-i) or 0)
			end

			return string.sub(chars, c+1, c+1)
		end) .. ({'', '==', '='})[#code%3 + 1])
	end,

	decode = function(code)
		if not code then return end

		code = string.gsub(code, "[^" .. chars .. "=]", '')

		return (string.gsub(string.gsub(code, '.', function(x)
			if (x == '=') then
				return ''
			end

			local r, f = '', (string.find(chars, x) - 1)

			for i = 6, 1, -1 do
				r = r .. (f%2^i - f%2^(i-1) > 0 and '1' or '0')
			end

			return r
		end), '%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then
				return ''
			end

			local c = 0

			for i = 1, 8 do
				c = c + (string.sub(x, i, i) == '1' and 2^(8-i) or 0)
			end

			return string.char(c)
		end))
	end
}