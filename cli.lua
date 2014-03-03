require("io")
require("string")
util = require("util")
socketutil = require("socketutil")
socket = require("socket")
-- open the CLI interface.
local commands = {}


local client = nil -- client object for connection
local running = true


-- send command string to server
local function send(str)
	if client then
		client:send("!"..str.."\n")
	end
end
------------- command functions ------------------
-- Connect to remote server. 2 arguments: address, port
function commands.connect(cmd, addr, port)
	if not addr then addr="localhost" end
	if not port then port=1025 end

	print("Connecting to "..addr..":"..port.."...")
	
	client,err = socket.connect(addr, port)
	if not client then
		print("TCP object creation failed:"..err)
		print("Connect failed")
		return nil
	end
	-- new coroutine!
	table.insert(co,coroutine.create(function () echoLoop(client) end))
	print("Connected.")
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


-- listens and echos anything sent back from the server.
function echoLoop(client)
	local line
	while running do
		line = socketutil.receive(client,"*l")
		if line then
			print("Server:"..line)
		end
	end
end
-- main loop. read commands and lookup into function table.
function readLoop()
	while running do
		print("enter command:")
		-- read one line from stdio
		local cmdline = io.read()
		local cmdwords = util.words(cmdline)
		local cmd = cmdwords[1]
		if commands[cmd] then
			commands[cmd](unpack(cmdwords))
		else
			send(cmdline)
		end
		socket.sleep(1)
		coroutine.yield()
	end
end

-- coroutine scheduler.
co = {}
co["readLoop"] = coroutine.create(readLoop)	
while running do
	for k,c in pairs(co) do
		if coroutine.status(c) == "dead" then
			co[k]=nil
			print(k,"dead")
		else
			status,err = coroutine.resume(c)
			if not status then print(k,err) end
		end
	end
end
