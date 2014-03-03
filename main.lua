io = require("rpiIO")
socket = require("socket") --networking lib
util = require("util") --helper functions

addr = "*"
port = 1025

running = true -- global state. set to false to end program.

pins = {}
pins.servo = 9
pins.speedL = 10
pins.speedR = 11
pins.dirL = 5
pins.dirR = 6

commands = {}

local function sendStr(client, str)
	client:send(str.."\n") -- no yielding for send
end
---------- command functions -------
-- change the pin mapping
function commands.remap(client, name, pin)
	if not name then
		for name,pin in pairs(pins) do
		sendStr(client, name.."="..(tostring(pin)))
		end
	elseif not pin then
		sendStr(client, name.."="..(tostring(pins[name])))
	else
		pins.name = tonumber( pin )
		print(name.."is now on pin "..pin)
	end
end

function commands.motors(client, l,r)
	if not l then l=0 end
	if not r then r=0 end
	io.setLeftMotor(l,1)
	io.setRightMotor(r,1)
end

function commands.getSensors(client)
	local data = "@sensor 0 100 12"
	sendStr(client, data)
end

function commands.stop(client)
	io.setLeftMotor(0,0)
	io.setRightMotor(0,0)
	print("Motors stopped")
	sendStr(client, "Motors stopped")
end

function commands.init(client)
	initHardware()
	sendStr(client, "Initialized")
end

function commands.run(client)
	print("run started.")
end

function commands.echo(client, ...)
	print (...)
end
-------------------------------------

-- initialize hardware
local function initHardware()
	io.initServo(pins.servo)
	io.initMotors(pins.speedL,pins.dirL,pins.speedR,pins.dirR)
end

--------------- Socket Coroutine Functions -------------

-- blocking accept call that yields!
local function accept(server)
	assert(server)
	local client=nil
	while not client do
		server:settimeout(0)
		client = server:accept()
		coroutine.yield()
	end
	return client
end

-- blocking yielding receive call.
local function receive(client, pattern)
	local ret = "" -- return value
	local status = "timeout"
	while status=="timeout" do
		client:settimeout(0) --nonblocking
		s,status,part = client:receive(pattern)
		if status=="timeout" then coroutine.yield() end
		if s then
			ret = ret..s
		elseif part then
			ret = ret..part
		end
	end
	if status=="closed" then
		return nil
	else
		return ret
	end
end

-- listens and handles requests from client
local function clientWorker(client)
	local c,cmdline,cmdwords,cmd -- declare local vars
	while running do
		cmdline = receive(client, "*l")
		if not cmdline then
			print("Connection from client terminated.")
			return
		end -- connection closed
		print(">>>"..cmdline)
		c = string.sub(cmdline,1,1)
		cmdline = string.sub(cmdline,2)

		cmdwords = util.words(cmdline)
		cmd = cmdwords[1]
		args = util.tail(cmdwords)

		if c == "!" then -- command message from client
			cmd = cmdwords[1]
			if commands[cmd] then
				commands[cmd](client,unpack(args))
			else
				print("no such command")
			end
		elseif c == "@" then -- data message from client
			print("motors:"..args[1]..","..args[2])
			io.setLeftMotor(args[1],1)
			io.setRightMotor(args[2],1)
		end
	end
end

-- wait for connections
local function acceptConnections(server)
	while running do
		print("Waiting for connections...")
		client = accept(server)
		print("connection from "..client:getpeername())
		-- create a new coroutine for worker 
		local worker = coroutine.create(function() clientWorker(client) end)
		table.insert(co,worker)
	end
end
local function mainLoop()
	while running do
		print(".")
		socket.sleep(1)
		coroutine.yield()
	end
end


-- initialize control server
local server = assert(socket.bind(addr, port))
initHardware() --setup all pin modes, PWM etc.
-- init coroutine table
co = {}
table.insert( co, coroutine.create(function () acceptConnections(server) end) )
table.insert( co, coroutine.create(mainLoop) )

while running do
	-- loop through all coroutines, giving time to each
	for k,c in pairs(co) do
		if coroutine.status(c) == "dead" then
			-- remove dead coroutines
			co[k] = nil
			print(k,"dead")
		else
			print(k)
			status,error = coroutine.resume(c)
			if not status then print("Error with coroutine:\n"..error) end
		end
	end
end

