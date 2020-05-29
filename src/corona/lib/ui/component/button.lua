-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- local TMR = TouchManager
local Filter = import("ui.button.filter")
local SignalsManager = require("lib.game.signals_manager")

local Button = class("Button")
Button:include(SignalsManager)

local _targets = setmetatable({}, {__mode = "v"})

local _pressed = function(self)
    if not self.pressed then
        self.pressed = true
        self.target:scale(self.overScale, self.overScale)
        -- if self.taret.over then
        -- end
        self.signals.emit(self.SIG_PRESS_VIEW)
    end
end

local _released = function(self)
    if self.pressed then
        self.pressed = false
        local value = 1 / self.overScale
        self.target:scale(value, value)
        self.signals.emit(self.SIG_RELEASE_VIEW)
    end
end

local _isWithinBounds = function(self, e)
    local bounds = self.target.contentBounds
    local xMin, xMax, yMin, yMax = bounds.xMin, bounds.xMax, bounds.yMin, bounds.yMax
    if self.region then
        local x, y = display.getWorldPosition(self.target)
        xMin = x - self.region.width * 0.5
        xMax = x + self.region.width * 0.5
        yMin = y - self.region.height * 0.5
        yMax = y + self.region.height * 0.5
    end
    return xMin <= e.x and xMax >= e.x and yMin <= e.y and yMax >= e.y
end

local _cancellOtherBttns = function(self)
    local target = self.target
    for eid, other in pairs(_targets) do
        if target.filter:checkConflict(other.filter) then
            _targets[eid] = nil
        end
    end
end

local _pushButtonTouch = function(self, e)
    if e.phase == "began" then
        _targets[e.id] = self.target
        self.target._eid = e.id
        display.getCurrentStage():setFocus( self.target, e.id )
        self.isFocused = true
        _pressed(self)
        -- if self.onPress then self.onPress(e) end
        self.signals.emit(self.SIG_ON_PRESS, e)
        return true
    elseif self.isFocused then
        if e.phase == "moved" then
            if _isWithinBounds(self, e) then
                _pressed(self)
            else
                _released(self)
            end
            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            display.getCurrentStage():setFocus(self.target, nil)
            self.isFocused = false
            if e.phase == "ended" then
                if _targets[e.id] and _isWithinBounds(self, e) then
                    -- if self.onRelease then self.onRelease(e) end
                    self.signals.emit(self.SIG_ON_RELEASE, e)
                    _cancellOtherBttns(self)
                else
                    -- if self.ensure then self.ensure(e) end
                    e.ensure = true
                    self.signals.emit(self.SIG_ENSURE, e)
                    e.phase = "cancelled"
                end
            else
                self.signals.emit(self.SIG_CANCEL, e)
            end
            self.target._eid = nil
            _targets[e.id] = nil
            _released(self)
            -- self.eid = nil
            return true
        end
    end

    -- if self.onEvent then self.onEvent(e) end
end

function Button:initialize(target, opts)
    local options = opts or {}
    self:initModule()
    self.SIG_ON_PRESS = "on_button_press"
    self.SIG_ON_RELEASE = "on_button_release"
    self.SIG_ENSURE = "on_button_ensure"
    self.SIG_CANCEL = "on_button_cancelled"
    self.SIG_PRESS_VIEW = "on_button_press_view_change"
    self.SIG_RELEASE_VIEW = "on_button_release_view_change"
    self.target = target
    self.pressed = false
    self.overScale = options.overScale or 0.96
    self.region = options.region
    -- self.onEvent = options.onEvent
    -- self.onPress = options.onPress
    -- self.onRelease = options.onRelease
    -- self.ensure = options.ensure
    target.filter = Filter:new(options.filter)
    self.eid = nil -- 用于控制触摸手指数目
    self.isFocused = false

    if options.onPress then
        self:sigRegister(self.SIG_ON_PRESS, options.onPress)
    end
    if options.onRelease then
        self:sigRegister(self.SIG_ON_RELEASE, options.onRelease)
    end
    if options.ensure then
        self:sigRegister(self.SIG_ENSURE, options.ensure)
    end
    if options.onCancel then
        self:sigRegister(self.SIG_CANCEL, options.onCancel)
    end

    self.touch = _pushButtonTouch
end

function Button:enable()
    self.target:removeEventListener("touch", self)
    self.target:addEventListener("touch", self)
end

function Button:disable()
    self.target:removeEventListener("touch", self)
    -- self:sigClearAll()
    display.getCurrentStage():setFocus(self.target, nil)
    self.isFocused = false
    if self.target._eid then
        _targets[self.target._eid] = nil
        self.target._eid = nil
    end
    _released(self)
end

function Button:cancel(e)
    local event = e or {}
    event.id = self.target._eid
    event.phase = "cancelled"
    self:touch(event)
end


return Button
