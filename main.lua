io = require("rpiIO")
socket = require("socket") --networking lib
addr = "*"
port = 1025

pins = {}
pins.servo = 9

-- initialize hardware
local function initHardware()
	io.initServo(pins.servo)
end

-- initialize control server
local server,err = assert(socket.bind(addr, port),"TCP object creation failed.")

client = server:accept()
print("connection from "..client:getpeername())




-- wait for input to start autonomous mode

-- begin autonomous mode...
while true do
	io.setServo(pins.servo,0)
	-- collect sensor info
	-- do stuff
end


