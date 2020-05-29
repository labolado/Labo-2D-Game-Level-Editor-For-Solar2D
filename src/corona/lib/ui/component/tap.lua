-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local SignalsManager = require("app.lib.modules.signals_manager")
local TimerManager = require("lib.system.timer_manager")
local Tap = class("Tap")
Tap:include(SignalsManager)

-- local function _pressed(self)
--     if not self.pressed then
--         self.pressed = true
--         self.target:scale(self.overScale, self.overScale)
--         -- if self.taret.over then
--         -- end
--         self.signals.emit(self.SIG_PRESS_VIEW)
--     end
-- end

-- local function _released(self)
--     if self.pressed then
--         self.pressed = false
--         local value = 1 / self.overScale
--         self.target:scale(value, value)
--         self.signals.emit(self.SIG_RELEASE_VIEW)
--     end
-- end

local function _isTap(self, e)
    if self.target.parent and self.startPosX then
        local w = self.region.width or 60
        local h = self.region.height or 60
        local x, y = self.target:localToContent(0, 0)
        x, y = x + self.startPosX, y + self.startPosY
        local xMin = x - w * 0.5
        local xMax = x + w * 0.5
        local yMin = y - h * 0.5
        local yMax = y + h * 0.5
        return xMin <= e.x and xMax >= e.x and yMin <= e.y and yMax >= e.y
    else
        return false
    end
end

function Tap:initialize(target, options)
    self:initModule()
    self.SIG_ON_TAP_BEGAN = "on_tap_began"
    self.SIG_ON_TAP_ENDED = "on_tap_ended"
    self.SIG_ON_TAP_CANCELLED = "on_tap_cancelled"
	self.timerMgr = TimerManager:new()
	self.target = target
    self.pressed = false
    self.overScale = options.overScale or 0.96
	self.region = options.region or {width=60, height=60}

	if options.onTapBegan then
        self:sigRegister(self.SIG_ON_TAP_BEGAN, options.onTapBegan)
	end
	if options.onTapEnded then
        self:sigRegister(self.SIG_ON_TAP_ENDED, options.onTapEnded)
	end
	if options.onTapCancelled then
        self:sigRegister(self.SIG_ON_TAP_CANCELLED, options.onTapCancelled)
	end
	self.target:addEventListener("initialize", function()
		self.timerMgr:cancelAll()
	    self:sigClearAll()
	end)
end

function Tap:touch(e)
	if e.phase == "began" then
        local cx, cy = self.target:localToContent(0, 0)
        self.startPosX, self.startPosY = e.x - cx, e.y - cy
        Component.eidDictionary[e.id] = 1
		self:sigEmit(self.SIG_ON_TAP_BEGAN, self) -- began
		self.timerMgr:setInterval(10, function(timerEvent)
			if _isTap(self, e) then
				if Component.eidDictionary[e.id] == nil then
					self.timerMgr:clearTimer(timerEvent.source)
					self:sigEmit(self.SIG_ON_TAP_ENDED, self) -- ended
				end
			else
				Component.eidDictionary[e.id] = 0
				self.timerMgr:clearTimer(timerEvent.source)
				self:sigEmit(self.SIG_ON_TAP_CANCELLED, self)
			end
		end)
	elseif e.phase == "ended" or e.phase == "cancelled" then
		Component.eidDictionary[e.id] = nil
	end
end

function Tap:enable()
	self:disable()
    self.target:addEventListener("touch", self)
end

function Tap:disable()
    self.target:removeEventListener("touch", self)
end

return Tap