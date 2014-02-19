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
pinr.dirR = 6

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
-------------------------------------

-- initialize hardware
local function initHardware()
	io.initServo(pins.servo)
	io.initMotors(pins.speedL,pins.dirL,pins.speedR,pins.dirR)
end

-- initialize control server
local server,err = assert(socket.bind(addr, port),"TCP object creation failed.")

initHardware()
commands.motortest(nil)


print("Waiting for connection...")
client = server:accept()
print("connection from "..client:getpeername())




while true do
	local c = client:receive(1) -- read one character
	local cmdline,cmdwords,cmd -- declare local vars
	if c == "!" then -- command message from client
		cmdline = client:receive("*l")
		cmdwords = util.words(cmdline)
		cmd = cmdwords[1]
		commands[cmd](unpack(cmdwords))
	elseif c == "@" then -- data message from client
		cmd = client:receive(10)
	end
end


