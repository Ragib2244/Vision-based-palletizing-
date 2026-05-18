-- Version: Lua 5.3.5

local ip = "192.168.1.40" -- The IP address of the robot, as the server IP
local port = 4001 -- Server port
local err = 0 -- TCP return
local socket 
local data_send
local msg
local coordination
local move_x = 0 -- Initialize move_x outside of the loop
local move_y = 0 -- Initialize move_y outside of the loop
local shape
-- Function to split a string based on a delimiter
function split(str, reps)
    local resultStrList = {} -- String is delimitted by ;
    string.gsub(str, '[^' .. reps .. ']+', function(w)
        table.insert(resultStrList, w)
    end)
    return resultStrList
end

-- Function to receive data from TCP/IP and extract coordinates
function data()
    while true do
        Sync()
        Wait(700)
        data_send = "ok"
        TCPWrite(socket, data_send)
        err, Recbuf = TCPRead(socket, 0, "string")
        msg = Recbuf.buf
        
        coordination = split(msg, ";")
        Sync()
        print(msg)
        move_x = tonumber(coordination[1]) -- Update move_x with new value
        move_y = tonumber(coordination[2]) -- Update move_y with new value
		shape = coordination[3]
		print(shape)
        -- Check for nil values
        if move_x == nil or move_y == nil then
            print("Received nil values, waiting for valid coordinates...")
			local jumped = false -- Initialize the flag to false
            while move_x == nil or move_y == nil do
                Sync()
                Wait(500)
                TCPWrite(socket, data_send)
                err, Recbuf = TCPRead(socket, 0, "string")
                msg = Recbuf.buf
                coordination = split(msg, ";")
                move_x = tonumber(coordination[1])
                move_y = tonumber(coordination[2])
                print("Rechecking move_x value", move_x)
                print("Rechecking move_y value", move_y)
				
				if not jumped then
					Jump(({coordinate = {260, -100, 20, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
					jumped = true -- Set the flag to true after executing Jump 
				end
            end
        end

        print("move x value is", move_x)
        print("move y value is", move_y)
        
        msg = 0
        coordination = 0
        print(msg)
        Sync()
        coroutine.yield()
    end
end

-- Initialize TCP/IP connection
err, socket = TCPCreate(false, ip, port) 
if err == 0 then
    err = TCPStart(socket, 0)
end

-- Create coroutine for the data function
local data_coroutine = coroutine.create(data)

-- Main loop
for count = 1, 100 do
    -- Receive data and extract coordinates concurrently
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    Sync()
    Wait(200)
    print("Rest position")
    -- Move to rest position
    Jump(({coordinate = {260, -100, 30, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
    Wait(200)
    Sync()

    -- Continue receiving data
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    Wait(200)
    print("Moving to target position")
    -- Wait for values to stabilize
    print("Waiting for coordinates to stabilize...")
    Wait(500)
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    print("new move x value", move_x)
    print("new move y value", move_y)
    --Jump(({coordinate = {(move_x + 9), (move_y + 53), -61, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
    
    -- Wait(700)
    -- DO(2, 1)
    -- Wait(700)
    
	if shape == "Circle" then
	-- Code block for the Circular shape
	Jump(({coordinate = {(move_x), (move_y + 47), 20, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	
	Wait(700)
    DO(1, 1)
    Wait(1500)
	DO(1, 0)
    Wait(100)
	
    Jump(({coordinate = {190, -180, 22, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
    
    Wait(500)
    DO(2, 1)
	Wait(200)
	DO(2, 0)
	Wait(200)
    Sync()
    msg = 0
    coordination = 0
	
	elseif shape == "Square" then
	
	Jump(({coordinate = {(move_x), (move_y + 47), 20, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	
	Wait(500)
    DO(2, 1)
    Wait(700)
	
	Jump(({coordinate = {350, -130, 22, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	-- Code block for Square shape
	Wait(500)
    DO(2, 0)
	Wait(200)
	DO(1, 1)
	Wait(200)
	DO(1, 0)
    Sync()
    msg = 0
    coordination = 0
	
	elseif shape == "Other" then
	Jump(({coordinate = {(move_x), (move_y + 47), 20, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	
	Wait(500)
    DO(2, 1)
    Wait(700)
	
	Jump(({coordinate = {395, 3, 22, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	-- Code block for other shapes
	Wait(500)
    DO(2, 0)
	Wait(200)
	DO(1, 1)
	Wait(200)
	DO(1, 0)
    Sync()
    msg = 0
    coordination = 0
	
	elseif shape == "Stacked1" then
	Jump(({coordinate = {(move_x), (move_y + 47), 0, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	
	Wait(500)
    DO(2, 1)
    Wait(700)
	
	Jump(({coordinate = {395, 3, 0, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	-- Code block for other shapes
	Wait(500)
    DO(2, 0)
	Wait(200)
	DO(1, 1)
	Wait(200)
	DO(1, 0)
    Sync()
    msg = 0
    coordination = 0
	
	elseif shape == "Unknown" then
	Jump(({coordinate = {(move_x), (move_y + 47), 0, 0}, tool = 0, user = 0}), {Start = NaN, ZLimit = NaN, End = NaN})
	--Code block for Unknown objects. Note that here the Blob analysis tool is being used and so the center may not be fully accurate. 
	--It is therefore imperative that the center coordinates be calculated properly from the detected blob
	
	Wait(500)
    DO(2, 1)
    Wait(700)
	
	end 
	
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    Wait(200)
end

