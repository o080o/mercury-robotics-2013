socket = require("socket")

socketutil = {}

-- blocking accept call that yields!
function socketutil.accept(server)
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
function socketutil.receive(client, pattern)
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

return socketutil
