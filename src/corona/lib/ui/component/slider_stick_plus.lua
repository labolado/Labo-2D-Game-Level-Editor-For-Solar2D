-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("app.lib.modules.signals_manager")
local TransManager = require("lib.system.transition_manager")
local Vector = require("lib.thirdparty.polygon.vector-light")
local SliderStickPlus = class("SliderStickPlus")
SliderStickPlus:include(SignalsManager)


local mathRound = math.round
function SliderStickPlus:initialize(target, options)
    self:initModule()
    self.SIG_CONTROL = "on_control"
    self.SIG_UPDATE = "on_update"
    self.target = target
    self.angleRange = options.angleRange
    self.origin = options.origin or {x = target.x, y = target.y + 1300}
    self.current = {x = target.x, y = target.y}
    self.maxLevel = options.level
    self.currentLevel = 0
    self.unitAngle = (self.angleRange[2] - self.angleRange[1]) / self.maxLevel
    -- self.region = options.region
    -- assert(type(options.region) == "table", "Component slider-> Param region is missing!")

    local initAngle = options.initAngle
    if type(initAngle) == "number" then
        local x, y = Vector.rotate(math.rad(initAngle), self.current.x - self.origin.x, self.current.y - self.origin.y)
        target.x = self.origin.x + x
        target.y = self.origin.y + y
        target.rotation = initAngle
        if type(options.onUpdate) == "function" then
            options.onUpdate({rotation = initAngle})
        end
    end

    self.transMgr = TransManager:new()
    if options.onControl then
        self:sigRegister(self.SIG_CONTROL, options.onControl)
    end
    if options.onUpdate then
        self:sigRegister(self.SIG_UPDATE, options.onUpdate)
    end
end

function SliderStickPlus:setLevel(level)
    self.currentLevel = level
    local angle = clamp(level * self.unitAngle + self.angleRange[1], self.angleRange[1], self.angleRange[2])
    local x, y = Vector.rotate(math.rad(angle), self.current.x - self.origin.x, self.current.y - self.origin.y)
    self.target.x = self.origin.x + x
    self.target.y = self.origin.y + y
    self.target.rotation = angle
    self.signals.emit(self.SIG_UPDATE, {rotation = angle})
end

function SliderStickPlus:setLevelRatio(levelRatio)
    self:setLevel(levelRatio * self.maxLevel)
end

function SliderStickPlus:touch(e)
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
            local parent = target.parent
            local x1, y1 = parent:contentToLocal( e.x, e.y )
            local x2, y2 = parent:contentToLocal( self.x0, self.y0 )
            local dx = x1 - x2
            local dy = y1 - y2
            -- target:translate(dx, dy)
            self.x0 = e.x
            self.y0 = e.y

            local o, b = self.origin, self.current
            local angle = Vector.angle_between(b.x - o.x, b.y - o.y, target.x + dx - o.x, target.y + dy - o.y)
            local rotation = clamp(angle, self.angleRange[1], self.angleRange[2])
            local x, y = Vector.rotate(math.rad(rotation), b.x - o.x, b.y - o.y)
            target.x = o.x + x
            target.y = o.y + y
            target.rotation = rotation

            local level = mathRound((rotation - self.angleRange[1]) / self.unitAngle)
            e.deltaTime = e.time - self.prevTime
            e.rotation = rotation
            self.prevTime = e.time
            e.levelRatio = level / self.maxLevel
            if level ~= self.currentLevel then
                e.level = level
                self.currentLevel = level
                self.signals.emit(self.SIG_CONTROL, e)
            else
                e.level = self.currentLevel
            end
            self.signals.emit(self.SIG_UPDATE, e)

            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            display.getCurrentStage():setFocus(target, nil)
            self.isFocused = false

            -- if self.dir == "horizontal" then
            --     local distance = self.currentLevel * self.unitLength
            --     local px = self.region.xMin + distance
            --     e.value = distance / (self.region.xMax - self.region.xMin)
            --     e.deltaDistance = px
            --     self.transMgr:cancel(target)
            --     self.transMgr:add(target, {
            --         time = 300,
            --         x = px,
            --         transition = easing.outElastic
            --         -- transition = easing.outExpo
            --     })
            -- else
            --     local distance = self.currentLevel * self.unitLength
            --     local py = self.region.yMin + distance
            --     e.value = distance / (self.region.yMax - self.region.yMin)
            --     e.deltaDistance = py
            --     self.transMgr:cancel(target)
            --     self.transMgr:add(target, {
            --         time = 300,
            --         y = py,
            --         transition = easing.outElastic
            --         -- transition = easing.outExpo
            --     })
            -- end
            -- e.deltaTime = 17
            -- self.signals.emit(self.SIG_CONTROL, e)
	        return true
	    end
	end
end

function SliderStickPlus:cancel(e)
    -- local event = e or {}
    -- event.phase = "cancelled"
    -- self:touch(event)
    display.getCurrentStage():setFocus(self.target, nil)
    self.isFocused = false
end

function SliderStickPlus:enable()
    self.target:removeEventListener("touch", self)
    self.target:addEventListener("touch", self)
end

function SliderStickPlus:disable()
    display.getCurrentStage():setFocus(self.target, nil)
    self.isFocused = false
    self.target:removeEventListener("touch", self)
    self.transMgr:cancelAll()
    -- self:sigClearAll()
end

return SliderStickPlus
