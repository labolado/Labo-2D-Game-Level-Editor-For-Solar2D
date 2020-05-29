-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local M = class("Draggable")

local function _defaultTouchCheck(e)
    return true
end

function M:touch(e)
    e.dx, e.dy = 0, 0
    if e.phase == "began" then
        if self.touchCheck(e) then
            display.getCurrentStage():setFocus( self.target, e.id )
            self.isFocus = true
            self.x0 = e.x
            self.y0 = e.y
            if self.on_drag_start then self.on_drag_start(e) end
            return true
        end
    elseif self.isFocus then
        if e.phase == "moved" then
            local parent = self.target.parent
            local x1, y1 = parent:contentToLocal( e.x, e.y )
            local x2, y2 = parent:contentToLocal( self.x0, self.y0 )
            local dx = x1 - x2
            local dy = y1 - y2
            e.dx, e.dy = dx, dy
            if self.autoMove then
                self.target:translate(dx, dy)
            end
            self.x0 = e.x
            self.y0 = e.y
            if self.on_drag then self.on_drag(e) end
            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            display.getCurrentStage():setFocus( self.target, nil )
            self.isFocus = false
            if e.phase == "ended" then
                if self.on_drag_ended then self.on_drag_ended(e) end
            else
                if self.on_drag_cancelled then self.on_drag_cancelled(e) end
            end
            return true
        end
    end
end

function M:initialize(target, options)
    self.target = target
    self.touchObject = options.touch or target
    self.on_drag_start = options.onBegan
    self.on_drag = options.onMoved
    self.on_drag_ended = options.onEnded
    self.on_drag_cancelled = options.onCancelled
    self.touchCheck = options.touchCheck or _defaultTouchCheck
    self.autoMove = options.autoMove
    self.isFocus = false
    self.x0 = 0
    self.y0 = 0
    if self.autoMove == nil then
        self.autoMove = true
    end
end

function M:cancel(e)
    local event = e or {}
    event.phase = "cancelled"
    self:touch(event)
end

function M:enable()
    self.touchObject:removeEventListener("touch", self)
    self.touchObject:addEventListener("touch", self)
end

function M:disable()
    display.getCurrentStage():setFocus(self.touchObject, nil)
    self.isFocus = false
    self.touchObject:removeEventListener("touch", self)
end

return M
