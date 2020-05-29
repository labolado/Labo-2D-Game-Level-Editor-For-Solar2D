-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("app.lib.modules.signals_manager")
local Slider = class("Slider")
Slider:include(SignalsManager)

function Slider:initialize(target, options)
    self:initModule()
    self.SIG_CONTROL = "on_control"
    self.target = target
    self.region = options.region
    assert(type(options.region) == "table", "Component slider-> Param region is missing!")

    self.dir = "horizontal"
    if self.region.xMin == self.region.xMax then
	    self.dir = "vertical"
    end

	if options.onControl then
		self:sigRegister(self.SIG_CONTROL, options.onControl)
	end
end

function Slider:touch(e)
	local target = self.target
	if e.phase == "began" then
	    display.getCurrentStage():setFocus(target, e.id)
	    self.isFocused = true
	    self.prevTime = e.time
        self.x0 = e.x
        self.y0 = e.y
	    return true
	elseif self.isFocused then
	    if e.phase == "moved" then
	    	local region = self.region
            local parent = target.parent
            local x1, y1 = parent:contentToLocal( e.x, e.y )
            local x2, y2 = parent:contentToLocal( self.x0, self.y0 )
            -- target:translate(x1 - x2, y1 - y2)
            local x = clamp(target.x + x1 - x2, region.xMin, region.xMax)
            local y = clamp(target.y + y1 - y2, region.yMin, region.yMax)
            local ox, oy = x - target.x, y - target.y
            target:translate(ox, oy)
            self.x0 = e.x
            self.y0 = e.y

            if self.dir == "horizontal" then
            	e.value = (target.x - region.xMin) / (region.xMax - region.xMin)
            	e.deltaDistance = ox
            else
            	e.value = (target.y - region.yMin) / (region.yMax - region.yMin)
            	e.deltaDistance = oy
            end

			e.deltaTime = e.time - self.prevTime
			self.prevTime = e.time
			self.signals.emit(self.SIG_CONTROL, e)
	        return true
	    elseif e.phase == "ended" or e.phase == "cancelled" then
	        display.getCurrentStage():setFocus(target, nil)
	        self.isFocused = false
	        return true
	    end
	end
end

function Slider:enable()
    self.target:removeEventListener("touch", self)
    self.target:addEventListener("touch", self)
end

function Slider:disable()
    self.target:removeEventListener("touch", self)
    self:sigClearAll()
end

return Slider
