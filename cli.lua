require("io")
require("string")
socket = require("socket")
-- open the CLI interface.
local commands = {}
commands.auto = nil


local client = nil -- client object for connection
local running = true



local function blah(arglist)
	addr = arglist[2]
	port = arglist[3]
	print(addr)
	print(port)
	
	client,err = socket.connect(addr, port)
	if not client then
		print("TCP object creation failed:"..err)
		return nil
	end
end
commands["connect"] = blah

-- breaks string str into an array of words
local function words(rest)
	local words = {}
	local i = 1
	local idx=0

	while idx do
		idx = string.find(rest, " ")
		if idx then
			local word = string.sub(rest, 1, idx)
			rest = string.sub(rest, idx+1)
			words[i] = word
			i=i+1
			print("word:"..word)
			print(idx)
		else
			print("done with words()")
		end
	end
	return words
end

for k,v in pairs(commands) do
	print(k,v)
end

-- main loop. read commands and lookup into function table.
while running do
	-- read one line from stdio
	local cmdline = io.read()
	local cmdwords = words(cmdline)
	local cmd = cmdwords[1]
	print(cmdline)
	print(cmd)
	cmd="connect"
	print(commands[cmd])
	commands[cmd](cmdwords)
	
end
	
