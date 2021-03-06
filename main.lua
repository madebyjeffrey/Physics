vector = require "hump.vector"
Class = require "hump.class"

require "geometry"

graphics = love.graphics


function math.clamp(v, min, max)
	if v > max then
		return max
	elseif v < min then
		return min
	else 
		return v
	end
end

--[[
function clamp (v, min, max) 
	return (v > max) and max or ((v < min) and min or v) 
end
--]]

function love.load()
  size = vector.new(graphics.getWidth(), graphics.getHeight())
  
  -- ball is a position, a mass, and a velocity
  ball = Circle(vector.new(size.x / 2, size.y / 2), 10)
  ball.mass = 50
  ball.velocity = vector.new(0, 0)
  ball.colour = { 255, 0, 0, 255 }
  
  borderColour = { 255, 255, 255, 255 }

  time = 0
  
  surfaceColour = { 0, 0, 255, 255 }
  
  surface = Rectangle(vector.new(200, 20), vector.new(300, 10))
  surface.colour = {0, 0, 255, 255 }
end

function love.update(dt)
	-- note that this function doesn't do exactly what it needs to do yet, must be worked out more

	local forces = { vector.new(0, -9.81 * ball.mass * 2) }
	ball = ballNext(ball, forces, dt)
	time = time + dt
	
--	print(string.format("update %f", dt))
	print(string.format("time: %f \t ball p: %f %f v: %f, %f", time, ball.origin.x, ball.origin.y, ball.velocity.x, ball.velocity.y))
end

function love.draw()
--    love.graphics.print('Hello World!', 400, 300)

  graphics.translate(0, graphics.getHeight())    
  graphics.scale(1, -1)
  
  -- draw the border
  graphics.setColor(borderColour)
  graphics.rectangle("line", 0.5, 0.5, graphics.getWidth(), graphics.getHeight())

  ball:draw()
  surface:draw()
  
end

function love.keypressed(key, unicode) 
	if (key == "escape") then
		love.event.push('q')
	end
end

function hitTest(ball, rectangle)
	local centre = ball.position
	local radius = ball.diameter / 2
	
	local closest = { x = math.clamp(centre.x, rectangle.position.x, rectangle.position.x + rectangle.cx - 1), 
			    y = math.clamp(centre.y, rectangle.position.y, rectangle.position.y + rectangle.cy - 1) }
			    
	local distance = { x = math.abs(centre.x - closest.x), 
	                   y = math.abs(centre.y - closest.y) }
	            
	return (distance.x * distance.x) + (distance.y * distance.y) < radius * radius
end

function ballNext(ball, forces, dt)
	-- add new velocities together
	sum = vector.new(0, 0)
	
	-- ipairs returns an iterator - for indexed tables
	-- pairs is for key-pair tables
	for _, f in ipairs(forces) do
		sum = sum + (f / ball.mass) * dt
	end
	
	local nextVelocity = ball.velocity + sum
	local nextOrigin = ball.origin + nextVelocity * dt
	
	local circle = Circle(nextOrigin, ball.radius)
	
	if (surface:hitTest(circle)) then
		-- add a partial distance calculation to account for the distance from the target and the velocity, before reversal
		nextVelocity = nextVelocity:permul(vector(-1, -1))
		nextOrigin = ball.origin + nextVelocity * dt
	end
  
  ball2 = deepcopy(ball)
  ball2.velocity = nextVelocity
  ball2.origin = nextOrigin
  
  return ball2
end

-- stolen from http://lua-users.org/wiki/CopyTable
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end