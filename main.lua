io = require("rpiIO")
socket = require("socket") --networking lib
addr = "*"
port = 1025

-- initialize hardware
io.initServo(9)

-- initialize control server
local server,err = socket.bind(addr, port)
if not  server then
	print("TCP object creation error:"..err)
else	
	client = server:accept()
	print("connection from "..client:getpeername())
end




-- wait for input to start autonomous mode

-- begin autonomous mode...
while true do
	io.setServo(9,0)
	-- collect sensor info
	-- do stuff
end


