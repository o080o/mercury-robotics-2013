io = require("rpiIO")
socket = require("socket") --networking lib
util = require("util") --helper functions

addr = "*"
port = 1025

pins = {}
pins.servo = 9
pins.speedL = 10
pins.speedR = 11
pins.dirL = 5
pins.dirR = 6

commands = {}
---------- command functions -------
-- change the pin mapping
function commands.remap(cmd, name, pin)
	pins.name = tonumber( pin )
	print(name.."is now on pin "..pin)
	return true --indicate success 
end

function commands.motortest(cmd)
	io.setLeftMotor(50,1)
	io.setRightMotor(50,1)
end

function commands.stop(cmd)
	io.setLeftMotor(0,0)
	io.setRightMotor(0,0)
end

function commands.init(cmd)
	initHardware()
end

function commands.echo(cmd, ...)
	print (...)
end
-------------------------------------

-- initialize hardware
local function initHardware()
	io.initServo(pins.servo)
	io.initMotors(pins.speedL,pins.dirL,pins.speedR,pins.dirR)
end






local function clientWorker(client)
	local c,cmdline,cmdwords,cmd -- declare local vars
	while true do
		c = client:receive(1) -- read one character
		if c == "!" then -- command message from client
			cmdline = client:receive("*l")
			print(">>>!"..cmdline)
			cmdwords = util.words(cmdline)
			if cmdwords == {} then
				print("no words!")
			else
				cmd = cmdwords[1]
				if commands[cmd] then
					commands[cmd](unpack(cmdwords))
				end
			end
		elseif c == "@" then -- data message from client
			cmd = client:receive("*l")
			print(">>>@"..cmd)
		elseif c == nil then -- timeout/disconnect
			print("Connection from client terminated")
			return
		else -- unknown stuff....
			cmd = client:receive("*l")
			print(">>>"..cmd)
		end
	end
end

-- initialize control server
local server,err = assert(socket.bind(addr, port),"TCP object creation failed.")
initHardware() --setup all pin modes, PWM etc.

-- wait for connections
print("Waiting for connections...")
while true do
	client = server:accept()
	print("connection from "..client:getpeername())
	-- start a new worker thread.
	clientWorker(client)
end

