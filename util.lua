require("string")

util = {}

-- returns the a table with only the tail of the integer keys.
function util.tail(tbl)
	local newtbl = {}
	for i,val in ipairs(tbl) do
		if i > 1 then
			newtbl[i-1]=val
		end
	end
	return newtbl
end
-- breaks string str into an array of words
function util.words(rest)
	local words = {}
	local i = 1 -- lua uses 1-indexed arrays
	local idx=0

	while idx do
		if rest == nil then
			idx = nil
		else
			idx = string.find(rest, " ")
		end

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

return util
