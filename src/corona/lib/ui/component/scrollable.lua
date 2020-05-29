-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local TMR = TouchManager

-- local SignalsManager = require("app.lib.modules.signals_manager")
local abs = math.abs
local clamp = clamp
local sign = sign
local _ratio = _RW / _W

local Scrollable = class("Scrollable")
-- Scrollable:include(SignalsManager)

function Scrollable:initialize(target, options)
	options = options or {}
	-- self:initModule()
	self.target = target
	self.timerMgr = options.timerMgr or import("system.timer_manager"):new()
	self.transMgr = options.transMgr or import("system.transition_manager"):new()
	self.padding = options.padding or {0, 0}
	self.isScrollable = dictGet(options, "isScrollable", true)
	-- self.SIG_ON_DRAG_UP = "on_drag_up"

	-- if options.onDragUp then
	-- 	self:sigRegister(self.SIG_ON_DRAG_UP, options.onDragUp)
	-- end
	self.touchCallBack = options.touchCallBack
	-- self.onStart = options.onStart
	self.onAfter = options.onAfter
	self.fingers = {}
	self.speed = 0
	self.initPosX = target.x
	self.initPosY = target.y
	self.initW = target.initW or 0
	self.initH = target.initW or 0

    display.aliasRemoveSelf(target, function(obj)
        Component.remove("scrollable", obj)
    end)
end

function Scrollable:averagePos(events)
    local ex, ey = 0, 0
    local count = _.size(events)
    for k,event in pairs(events) do
        ex = ex + event.x
        ey = ey + event.y
    end
    return ex/count, ey/count
end


function Scrollable:touch(e)
	if not self.isScrollable then return false end
	-- logOnScreen(e.phase, e.isFoucsed)
	if self.touchCallBack then self.touchCallBack(e) end
	if e.phase == "began" then
		self.fingers[e.id] = e
		TMR.setFocus(self.target, e.id)
		self.x0, self.y0 = self:averagePos(self.fingers)
		self.speed = 0
        if self.slideAuto then self.timerMgr:clearTimer(self.slideAuto) end
        -- if self.onAfter then self.onAfter(e) end
		return true
	else
		if not e.isFocused then
			if e.phase == "moved" then
			    self.fingers[e.id] = e
			    TMR.setFocus(self.target, e.id)
				self.x0, self.y0 = self:averagePos(self.fingers)
				self.speed = 0
		        if self.slideAuto then self.timerMgr:clearTimer(self.slideAuto) end
			else
		        -- if self.onAfter then self.onAfter(e) end
			    return false
			end
		end

		if e.phase == "moved" then
		    self.fingers[e.id] = e
			local ex, ey = self:averagePos(self.fingers)
			local parent = self.target.parent
			if parent == nil then return false end
			local x1, y1 = parent:contentToLocal(ex, ey)
			local x2, y2 = parent:contentToLocal(self.x0, self.y0)
			local dx = x1 - x2
			-- local dy = y1 - y2
			-- self.target:translate(dx, dy)
			local speed = dx * 0.8
			self.speed = sign(speed) * clamp(abs(speed), 10 * _ratio, 180 * _ratio)
			if (self.target.contentBounds.xMin > parent.contentBounds.xMin) or
			    (self.target.contentBounds.xMax < parent.contentBounds.xMax) then
			    dx = dx * 0.4
			end
			self.target:translate(dx, 0)
			self.x0 = ex
			self.y0 = ey
			return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
        	TMR.unsetFocus(self.target, e.id)
        	self.fingers[e.id] = nil
        	-- logOnScreen(_.size(self.fingers), unpack(_.map(_.values(self.fingers), function(item) return item.phase end) ))
			self.x0, self.y0 = self:averagePos(self.fingers)

			-- if e.phase == "ended" then
		    local offset = self.padding  -- 边界恢复原位时的偏离位置
		    local parent = self.target.parent
		    if parent == nil then return false end
			if self.speed ~= 0 then
				local speed = self.speed
				local speedFlag = sign(speed)
				local ratio = 0.03
				if abs(speed) < 3 * ratio then
				    ratio = 0.2
				end
				local delta = speed * ratio
				self.timerMgr:setTimeout(1000, EMPTY) -- 防止 timer 事件出现在 Runtime enterFrame 监听器列表最底端
				self.slideAuto = self.timerMgr:setInterval(10, function(e)
				    local ox = speed
				    if (self.target.contentBounds.xMin - offset[1] > parent.contentBounds.xMin) or
				        (self.target.contentBounds.xMax + offset[2] < parent.contentBounds.xMax) then
				       ox = ox * 0.05
				    end
				    self.target:translate( ox, 0 )
				    speed = speed - delta
				    local flag = sign(speed)
				    if (speed == 0) or (flag ~= speedFlag) then
				        self.timerMgr:clearTimer( e.source )
				        self.slideAuto = nil
				        if (self.target.contentBounds.xMin - offset[1] > parent.contentBounds.xMin) then
				            self.transMgr:add( self.target, {time = 200, x = self.initPosX + offset[1], transition = easing.outQuad} )
				        elseif (self.target.contentBounds.xMax + offset[2] < parent.contentBounds.xMax) then
				            self.transMgr:add( self.target, {time = 200, x = self.initPosX - self.initW - offset[2], transition = easing.outQuad} )
				        end
				    end
				end)
			end
			local a = self.target.contentBounds.xMin - offset[1] > parent.contentBounds.xMin
			local b = self.target.contentBounds.xMax + offset[2] < parent.contentBounds.xMax
			if a or b then
			    if (self.slideAuto) then self.timerMgr:clearTimer(self.slideAuto) end
			    self.transMgr:cancelAll()
				if e.id == "fake" then
					if (parent.contentBounds.xMin + self.target.contentWidth + offset[1] - offset[2]) < parent.contentBounds.xMax then
					    self.transMgr:add( self.target, {time = 200, x = self.initPosX + offset[1], transition = easing.outQuad} )
					else
					    self.transMgr:add( self.target, {time = 200, x = self.initPosX - self.initW - offset[2], transition = easing.outQuad} )
					end
				else
					if a then
					    self.transMgr:add( self.target, {time = 200, x = self.initPosX + offset[1], transition = easing.outQuad} )
					else
					    self.transMgr:add( self.target, {time = 200, x = self.initPosX - self.initW - offset[2], transition = easing.outQuad} )
					end
				end
			end
			if e.id then
			    Component.eidDictionary[e.id] = nil
			end
			-- end

	        if self.onAfter then self.onAfter(e) end
        	return true
		end
	end
end

function Scrollable:setScrollable(bool)
	self.isScrollable = bool
end

function Scrollable:enable()
    TMR.register(self.target, self)
end

function Scrollable:disable()
    TMR.unregister(self.target, self)
    -- self.fingers = {}
end
return Scrollable
