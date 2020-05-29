-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("app.lib.modules.signals_manager")
local TransManager = require("lib.system.transition_manager")
local Steer = class("Steer")
Steer:include(SignalsManager)

local sign = sign
local math_abs = math.abs
function Steer:initialize(target, options)
    self:initModule()
    self.SIG_CONTROL = "on_control"
    self.target = target
    self.touchRegion = options.touchRegion or target
	self.base = options.base or target
	self.radius = options.radius or 20
	self.initAngle = options.initAngle or 0
	self.leftAngle = self.initAngle + -70
	self.rightAngle = self.initAngle + 70
    self.transMgr = TransManager:new()

	if options.onControl then
		self:sigRegister(self.SIG_CONTROL, options.onControl)
	end
end

function Steer:touch(e)
	local target = self.target
	local x, y = self.base:localToContent(0, 0)
	if e.phase == "began" then
	    display.getCurrentStage():setFocus( self.touchRegion, e.id )
	    self.isFocused = true
	    self.prevTime = e.time
	    self.prevAngle = angleOf2(x, y, e.x, e.y)
	    self.transMgr:cancel(target)
	    return true
	elseif self.isFocused then
	    if e.phase == "moved" then
			local angle = angleOf2(x, y, e.x, e.y)
			local deltaAngle = angle - self.prevAngle
			deltaAngle = angleTranslate(deltaAngle)
			-- local deltaArcLength = deltaAngle * math.pi * self.radius / 180
			-- local deltaTime = e.time - self.prevTime

			-- if math.abs(deltaAngle) >=5 then
				self.prevTime = e.time
				self.prevAngle = angle
				-- e.deltaAngle = deltaAngle
				-- e.deltaArcLength = deltaArcLength
				-- e.deltaTime = deltaTime == 0 and 17 or deltaTime
				local angle = angleTranslate(target.rotation)
				target:rotate(deltaAngle)
				if angle > self.rightAngle and sign(deltaAngle) > 0 then
					target:rotate(-deltaAngle)
				end
				if angle < self.leftAngle and sign(deltaAngle) < 0 then
					target:rotate(-deltaAngle)
				end
				local dir
				if angle > 0 then 
					dir = 1
				elseif angle < 0 then
					dir = -1
				else
					dir = 0
				end
				e.direction = dir
				e.value = dir * math_abs(angle / self.leftAngle)
				if math_abs(e.value) < 0.11 then
					e.value = 0
				end
				self.signals.emit(self.SIG_CONTROL, e)
			-- end
	        return true
	    elseif e.phase == "ended" or e.phase == "cancelled" then
	    	e.direction = 0
	    	e.value = 0
			self.signals.emit(self.SIG_CONTROL, e)
	        display.getCurrentStage():setFocus(self.touchRegion, nil)
	        self.isFocused = false
	        self.transMgr:cancel(target)
	        self.transMgr:add(target, {
                time = 300, 
                rotation = 0,
                transition = easing.outElastic
	        })
	        return true
	    end
	end
end

function Steer:enable()
    self.touchRegion:removeEventListener("touch", self)
    self.touchRegion:addEventListener("touch", self)
end

function Steer:disable()
    self.touchRegion:removeEventListener("touch", self)
    display.getCurrentStage():setFocus(self.touchRegion, nil)
    self.isFocused = false
    self.transMgr:cancelAll()
    -- self:sigClearAll()
end

return Steer