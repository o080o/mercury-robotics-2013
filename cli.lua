require("io")
require("string")
util = require("util")
socket = require("socket")
-- open the CLI interface.
local commands = {}


local client = nil -- client object for connection
local running = true


-- send command string to server
local function send(str)
	assert(client)
	client:send("!"..str)
end
------------- command functions ------------------
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
function commands.remap(cmd, name, pin)
	assert(name)
	assert(pin)
	assert(client)
	print("remapping "..name.." to pin "..pin.."...")
	send("remap "..name.." "..pin.."\n")
	
	print("Done.")
end

-- Help command
function commands.help()
	print("Available commands:")
	for k,v in pairs(commands) do
		print(k,v)
	end
end

-- Exit command
function commands.exit()
	running = false
end

-----------------------------------


-- main loop. read commands and lookup into function table.
while running do
	print("enter command:")
	-- read one line from stdio
	local cmdline = io.read()
	local cmdwords = util.words(cmdline)
	local cmd = cmdwords[1]
	if commands[cmd] then
		commands[cmd](unpack(cmdwords))
	else
		print("no such command")
	end
end
	
