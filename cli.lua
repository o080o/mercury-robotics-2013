require("io")
require("string")
socket = require("socket")
-- open the CLI interface.
local commands = {}
commands.auto = nil


local client = nil -- client object for connection
local running = true


-- Connect to remote server. 2 arguments: address, port
function commands.connect(cmd, addr, port)
	assert(addr)
	assert(port)
	print("Connecting to "..addr..":"..port.."...")
	
	client,err = socket.connect(addr, port)
	if not client then
		print("TCP object creation failed:"..err)
		print("Connect failed")
		return nil
	end
	print("Connected.")
end

-- Help command
function commands.help()
	print("Available commands:")
	for k,v in pairs(commands) do
		print(k,v)
	end
end

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


local function testwords()
	retv = words("word1 word2 word3 test6")
	for k,v in ipairs(retv) do
		print(k,v)
		print(string.len(v))
	end
	print(tostring(retv))
	assert(words("word1 word2 word3 test6")=={"word1","word2","word3","test6"},"Failed 'words' test case 1")
	assert(words("")=={}, "Failed 'words' test case 2")
	assert(words("word1")=={"word1"}, "Failed 'words' test case 3")
	assert(words("word1 ")=={"word1"}, "Failed 'words' test case 4")
end
-- run some tests
--testwords()

-- main loop. read commands and lookup into function table.
while running do
	-- read one line from stdio
	local cmdline = io.read()
	local cmdwords = words(cmdline)
	local cmd = cmdwords[1]
	commands[cmd](unpack(cmdwords))
	
end
	
