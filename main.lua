f = require("rpiIO")
socket = require("socket") --networking lib

dist,err = f.readPing(5)
if not dist then
	print(err)
else
	print("Distance:"..dist)
end
