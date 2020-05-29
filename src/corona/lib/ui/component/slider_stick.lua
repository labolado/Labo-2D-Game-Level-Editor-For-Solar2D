-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("app.lib.modules.signals_manager")
local TransManager = require("lib.system.transition_manager")
local SliderStick = class("SliderStick")
SliderStick:include(SignalsManager)

local mathRound = math.round
function SliderStick:initialize(target, options)
    self:initModule()
    self.SIG_CONTROL = "on_control"
    self.target = target
    self.maxLevel = options.level
    self.currentLevel = 0
    self.region = options.region
    assert(type(options.region) == "table", "Component slider-> Param region is missing!")

    self.dir = "horizontal"
    self.unitLength = (self.region.xMax - self.region.xMin) / self.maxLevel
    if self.region.xMin == self.region.xMax then
        self.dir = "vertical"
        self.unitLength = (self.region.yMax - self.region.yMin) / self.maxLevel
    end

    self.prevLevel = 0
    self.transMgr = TransManager:new()
    if options.onControl then
        self:sigRegister(self.SIG_CONTROL, options.onControl)
    end
end

function SliderStick:touch(e)
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

            local distance, level
            if self.dir == "horizontal" then
                distance = x - region.xMin
                level = mathRound(distance / self.unitLength)
                e.value = (level * self.unitLength) / (region.xMax - region.xMin)
                e.deltaDistance = ox
            else
                distance = y - region.yMin
                level = mathRound(distance / self.unitLength)
                e.value = (level * self.unitLength) / (region.yMax - region.yMin)
                e.deltaDistance = oy
            end
            e.deltaTime = e.time - self.prevTime
            self.prevTime = e.time
            self.currentLevel = level
            if level ~= self.prevLevel then
                self.prevLevel = level
                e.level = level
                self.signals.emit(self.SIG_CONTROL, e)
            else
                e.level = self.prevLevel
            end

            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            display.getCurrentStage():setFocus(target, nil)
            self.isFocused = false

            if self.dir == "horizontal" then
                local distance = self.currentLevel * self.unitLength
                local px = self.region.xMin + distance
                e.value = distance / (self.region.xMax - self.region.xMin)
                e.deltaDistance = px
                self.transMgr:cancel(target)
                self.transMgr:add(target, {
                    time = 300, 
                    x = px,
                    transition = easing.outElastic
                    -- transition = easing.outExpo
                })
            else
                local distance = self.currentLevel * self.unitLength
                local py = self.region.yMin + distance
                e.value = distance / (self.region.yMax - self.region.yMin)
                e.deltaDistance = py
                self.transMgr:cancel(target)
                self.transMgr:add(target, {
                    time = 300, 
                    y = py,
                    transition = easing.outElastic
                    -- transition = easing.outExpo
                })
            end
            e.deltaTime = 17
            -- self.signals.emit(self.SIG_CONTROL, e)
	        return true
	    end
	end
end

function SliderStick:enable()
    self.target:removeEventListener("touch", self)
    self.target:addEventListener("touch", self)
end

function SliderStick:disable()
    self.target:removeEventListener("touch", self)
    self.transMgr:cancelAll()
    self:sigClearAll()
end

return SliderStick
