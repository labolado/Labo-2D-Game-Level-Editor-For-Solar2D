-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local EndlessMoving = class("EndlessMoving")

--[[
   -2
-1  0  1
	2
--]]
function EndlessMoving:initialize(target, options)
	assert(target.numChildren ~= nil, "EndlessMoving component must be add to a displayGroupObject")
	self.target = target
	for i=1, target.numChildren do
		local child = target[i]
		if type(child.numChildren) == "number" and type(child.insert) == "function" then
			display.resetGroupCenter(child)
		end
	end
	self.dir = options.direction or -1
	self.speed = math.abs(options.speed or 0)
	self.offset = options.offset or {x = 0, y = 0}
	-- self.offset = {x = 0, y = 0}
	self.offset.x = target[2].contentBounds.xMin - target[1].contentBounds.xMax
	-- local x, y = getWorldPos(self.target)
	-- local x, y = self.target:localToContent(0, 0)
	-- if self.dir == -1 then
	-- 	self.distance = x - _L
	-- elseif self.dir == 1 then
	-- 	self.distance = _R - x
	-- else
	-- 	self.distance = 0
	-- end
	if type(options.onUpdate) == "function" then
		self.onUpdate = options.onUpdate
	end

	self.target:addEventListener("finalize", function(e)
		self:disable()
	end)
end

function EndlessMoving:enterFrame(e)
	local target = self.target
	if not target.parent then
		self:disable()
		return true
	end
	local speed = self.speed * self.dir
	for i=1, target.numChildren do
		local child = target[i]
		if child.contentBounds.xMax + self.offset.x < _L then
			-- local x = self.target.parent:contentToLocal(_R + self.distance + (self.target.contentWidth - _RW), 0)
			local x = target:contentToLocal(target.contentBounds.xMax + self.offset.x + (child.contentWidth + self.offset.x) * 0.5, 0)
			child:translate(x - child.x, 0)
		end
		if child.contentBounds.xMin - self.offset.x + speed > _R then
			local x = target:contentToLocal(target.contentBounds.xMin - self.offset.x - (child.contentWidth + self.offset.x) * 0.5, 0)
			child:translate(x - child.x, 0)
		end
	end

	if speed ~= 0 then
		local x = target:localToContent(0, 0)
		local dx = target.parent:contentToLocal(x + speed, 0) - target.x
		target:translate(dx, 0)
	end

	if self.onUpdate then
		self.onUpdate(e)
	end
	return true
end

function EndlessMoving:enable()
	self:disable()
    Runtime:addEventListener("enterFrame", self)
end

function EndlessMoving:disable()
    Runtime:removeEventListener("enterFrame", self)
end

return EndlessMoving
