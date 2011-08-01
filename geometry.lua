
vector = require "hump.vector"

require 'middleclass'

Rectangle = class('Rectangle')

function Rectangle:initialize(origin, size)
	self.origin = origin
	self.size = size
end
					
function Rectangle:hitTest(object)
	if instanceOf(Circle, object) then
		local closest = self:clamp(object.origin)
		local distance = (object.origin - closest):len2()
		
		return distance < (object.radius*object.radius)
	end
	
	return false
end

function Rectangle:left()
	return self.origin.x
end

function Rectangle:top()
	return self.origin.y
end

function Rectangle:right()
	return self.origin.x + self.size.x - 1
end

function Rectangle:bottom()
	return self.origin.y + self.size.y - 1
end

function Rectangle:clamp(point)
	if vector.isvector(point) then
		return vector.new(math.clamp(point.x, self:left(), self:right()),
		                  math.clamp(point.y, self:top(), self:bottom()))
	end
end

function Rectangle:draw()
	graphics.setColor(self.colour)
	graphics.rectangle("fill", self.origin.x + 0.5, 
						       self.origin.y + 0.5, 
						       self.size.x, self.size.y)
end

Circle = class('Circle')

function Circle:initialize(origin, radius)
	self.origin = origin
	self.radius = radius
end
			   
function Circle:draw()
	graphics.setColor(self.colour)
	graphics.circle("fill", self.origin.x + 0.5,
	                        self.origin.y + 0.5,
	                        self.radius)
end