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
--- helper functions
local function sendStr(client, str)
	client:send(str.."\n")
end

commands = {}
---------- command functions -------
-- change the pin mapping
function commands.remap(client,cmd, name, pin)
	pins.name = tonumber( pin )
	print(name.."is now on pin "..pin)
	return true --indicate success 
end

function commands.test(client,cmd, val)
	io.setLeftMotor(val,1)
	io.setRightMotor(val,1)
end

function commands.getSensors(client,cmd)
	local data = "@sensor:0:100:12"
	sendStr(client, data)
end

function commands.stop(client,cmd)
	io.setLeftMotor(0,0)
	io.setRightMotor(0,0)
end

function commands.init(client,cmd)
	initHardware()
end

function commands.run(client,cmd)
	print("run started.")
end

function commands.echo(client,cmd, ...)
	print (...)
end
-------------------------------------

-- initialize hardware
local function initHardware()
	io.initServo(pins.servo)
	io.initMotors(pins.speedL,pins.dirL,pins.speedR,pins.dirR)
end

local function getVals(line)
	local i=1
	local vals = {}
	local idx = string.find(line, ":")
	local rest = string.sub(line, idx+1)
	print(rest)
	while idx do
		idx = string.find(rest, ":")
		if idx then
			val = string.sub(rest,1,idx-1) 
			rest = string.sub(rest,idx+1)
			print("val="..val)
		else
			print("val="..val)
			val = rest
		end
		vals[i] = val
		i=i+1
	end
	return vals
end





local function clientWorker(client)
	local c,cmdline,cmdwords,cmd -- declare local vars
	while true do
		c = client:receive(1) -- read one character
		if c == "!" then -- command message from client
			cmdline = client:receive("*l")
			if cmdline == nil then
				print("Connection from client terminated")
				return
			end
			print(">>>!"..cmdline)
			cmdwords = util.words(cmdline)
			if cmdwords == {} then
				print("no words!")
			else
				cmd = cmdwords[1]
				if commands[cmd] then
					commands[cmd](client,unpack(cmdwords))
				else
					print("no such command")
				end
			end
		elseif c == "@" then -- data message from client
			cmd = client:receive("*l")
			local vals = getVals(cmd)
			print(">>>@"..cmd)
			print("motors:"..vals[1]..","..vals[2])
			io.setLeftMotor(vals[1],1)
			io.setRightMotor(vals[2],1)
			
		elseif c == nil then -- timeout/disconnect
			print("Connection from client terminated")
			return
		else -- unknown stuff....
			cmd = client:receive("*l")
			print(">>>"..cmd)
		end
	end
end

local v = getVals("biah:50:60")
print(v[1])
print(v[2])


-- blocking accept call that yields!
local function accept(server)
	local client=nil
	server:settimeout(0)
	while not client do
		server:accept()
		yield(server)
	end
	return client
end

-- wait for connections
local function acceptConnections(server)
	print("Waiting for connections...")
	while true do
		client = accept(server)
		--client = server:accept()
		print("connection from "..client:getpeername())
		-- start a new worker thread.
		clientWorker(client)
	end
end

co = {}
table.insert( co, coroutine.create(acceptConnections) )
table.insert( co, mainLoop )

-- initialize control server
local server = assert(socket.bind(addr, port))
initHardware() --setup all pin modes, PWM etc.

while running do
	-- loop through all coroutines, giving time to each
	for k,c in ipairs(co) do
	-- remove dead coroutines
		if coroutine.status(c) == "dead" then
			co[k] = nil
		else
			coroutine.resume(c)
		end
	end
end

