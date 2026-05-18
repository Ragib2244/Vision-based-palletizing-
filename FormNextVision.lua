
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
local x_offset = 4
local y_offset = 19
local current_task = 1 -- Tracks the current block task (1 = I, 2 = A, 3 = P, 4 = T)
--DO1 is Gripper actuation
--DO2 is suction actuation
function intermediate_Si() -- can be substituted by the Optimal path algorithm function developed recently 
	MovL(({coordinate = {135, -243, 75, 130.5}, tool = 0, user = 0}), {Start=NaN, ZLimit=NaN, End=NaN})
    Wait(100)
    MovL(({coordinate = {217, -133, 75, 130.5}, tool = 0, user = 0}), {Start=NaN, ZLimit=NaN, End=NaN})
    MovL(({coordinate = {264, 2, 75, 130.5}, tool = 0, user = 0}), {Start=NaN, ZLimit=NaN, End=NaN})
    MovL(({coordinate = {189, 216, 75, 130.5}, tool = 0, user = 0}), {Start=NaN, ZLimit=NaN, End=NaN})
end

function Blink_Led() --Blinking LED
	DO(16,1)
	Wait(500)
	DO(16,0)
	Wait(250)
	DO(16,1)
	Wait(500)
	DO(16,0)
end 

function split(str, reps) --
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
            end
        end

        print("move x value", move_x)
        print("move y value", move_y)
        
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
local data_coroutine = coroutine.create(data) --can be offloaded to subthreads 
   
function handleVisionTask() --Function called only when move_x and move_y are NOT nil values
		Wait(1000)
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		if shape == "Satellite" then
		print(shape)
        Jump(({coordinate = {(move_x + x_offset), (move_y + y_offset), -1.75, 0}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
        Wait(700)
        DO(1,1)
		Wait(1700)
        -- Drop Coordinate for the Satellite:
        Jump(({coordinate = {181.79, 282.62, -1.55, 172.04}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
        Wait(1000)
		DO(1,0)
		Wait(1000)
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		elseif shape == "Dragon" then
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		print(shape)
        Jump(({coordinate = {(move_x + x_offset), (move_y + y_offset), 9.93, 0}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
        Wait(700)
		DO(1,1)
		Wait(1000)
		--DO(1,0)
		-- Drop Coordinate for the Dragon:
        Jump(({coordinate = {261.49, 156.16, 16, 150}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
        Wait(1000)
		DO(1,0)
		Wait(300)
		DO(2,1)
		Wait(1000)
		DO(2,0)
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		Wait(1000)
		elseif shape == "Engine" then
		print(shape)
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Wait(500)
        Jump(({coordinate = {(move_x + x_offset), (move_y + y_offset ), 23.81, 0}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
        Wait(700)
        DO(2,1)
		Wait(1000)
		-- Drop Coordinate for the Engine:
        Jump(({coordinate = {154.87, 181.85, 35, 220}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
        Wait(500)
		DO(2,0)
		Wait(500)
		Jump(({coordinate = {217, 176, 55,138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		elseif shape == "Empty" then
		print(shape)
		
		Blink_Led() --But do this function as long as the object is 'UnknownShape'
		
        --AFter completing the vision task, go to a rest position and wait for 5 seconds for more objects to be detected but if there's nothing in the camera area then we
		--switch tool to the laser and start Routine task again
		--
		Jump(({coordinate = {217, 176, 55, 138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
		Sync()
		end
end


for count = 1, 100 do
    -- Receive data and extract coordinates concurrently
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    Sync()
    Wait(200)
    print("Rest position")
    -- Move to rest position
    Jump(({coordinate = {217, 176, 55, 138}, tool = 0, user = 0}), {Start=NaN, ZLimit=110, End=NaN})
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
	Sync()
    handleVisionTask()  -- Handle vision task with SI gripper
    Sync()
    -- Allow the coroutine to keep running concurrently
    if coroutine.status(data_coroutine) ~= "dead" then
        coroutine.resume(data_coroutine)
    end
    Wait(200)
end
