require("string")

-- breaks string str into an array of words
local function words(rest)
	local words = {}
	local i = 1 -- lua uses 1-indexed arrays
	local idx=0

	while idx do
		idx = string.find(rest, " ")
		if idx then
			local word = string.sub(rest, 1, idx-1)
			rest = string.sub(rest, idx+1)
			words[i] = word
			i=i+1
		else
			if string.len(rest)>0 then
				words[i] = rest
			end
		end
	end
	return words
end
