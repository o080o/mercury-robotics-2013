require("io")
require("string")
util = require("util.lua")
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

-- main loop. read commands and lookup into function table.
while running do
	-- read one line from stdio
	local cmdline = io.read()
	local cmdwords = util.words(cmdline)
	local cmd = cmdwords[1]
	commands[cmd](unpack(cmdwords))
	
end
	
