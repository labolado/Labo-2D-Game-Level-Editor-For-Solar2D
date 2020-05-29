-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("lib.game.signals_manager")
local Joystick = class("Joystick")
Joystick:include(SignalsManager)

function Joystick:initialize(target, options)
    self:initModule()
    self.SIG_CONTROL = "on_control"
    self.target = target
    self.touchRegion = options.touchRegion or target
	self.base = options.base
	self.radius = options.radius or 20
	self.initAngle = options.initAngle or 0

	if options.onControl then
		self:sigRegister(self.SIG_CONTROL, options.onControl)
	end
end

function Joystick:touch(e)
	local target = self.target
	local x, y = self.base:localToContent(0, 0)
	if e.phase == "began" then
	    display.getCurrentStage():setFocus( self.touchRegion, e.id )
	    self.isFocused = true
	    self.prevTime = e.time
	    self.prevAngle = angleOf2(x, y, e.x, e.y)
	    return true
	elseif self.isFocused then
	    if e.phase == "moved" then
			local angle = angleOf2(x, y, e.x, e.y)
			-- local deltaAngle = self.initAngle + angle - target.rotation
			local deltaAngle = angle - self.prevAngle
			deltaAngle = angleTranslate(deltaAngle)
			local deltaArcLength = deltaAngle * math.pi * self.radius / 180
			local deltaTime = e.time - self.prevTime

			-- this.rect:translate(0, deltaArcLength)
			-- this.rect:rotate(deltaAngle)
			if math.abs(deltaAngle) >=5 then
				target:rotate(deltaAngle)
				self.prevTime = e.time
				self.prevAngle = angle
				e.deltaAngle = deltaAngle
				e.deltaArcLength = deltaArcLength
				e.deltaTime = deltaTime == 0 and 17 or deltaTime
				self.signals.emit(self.SIG_CONTROL, e)
			end
	        return true
	    elseif e.phase == "ended" or e.phase == "cancelled" then
	        display.getCurrentStage():setFocus(self.touchRegion, nil)
	        self.isFocused = false
	        return true
	    end
	end
end

function Joystick:enable()
    self.touchRegion:removeEventListener("touch", self)
    self.touchRegion:addEventListener("touch", self)
end

function Joystick:disable()
    self.touchRegion:removeEventListener("touch", self)
    display.getCurrentStage():setFocus(self.touchRegion, nil)
    self.isFocused = false
    -- self:sigClearAll()
end

return Joystick
