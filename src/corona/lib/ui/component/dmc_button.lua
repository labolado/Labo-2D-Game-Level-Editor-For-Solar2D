local TMR = TouchManager
local Filter = import("ui.button.filter")

local DMCButton = class("DMCButton")

local _targets = setmetatable({}, {__mode = "v"})

local _pressed = function(self)
    if not self.pressed then
        self.pressed = true
        self.target:scale(self.overScale, self.overScale)
        -- if self.taret.over then
        -- end
    end
end

local _released = function(self)
    if self.pressed then
        self.pressed = false
        local value = 1 / self.overScale
        self.target:scale(value, value)
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
        if other.target.parent == nil then
            _targets[eid] = nil
        else
            if target.filter:checkConflict(other.target.filter) then
                TMR.unsetFocus( other.target, eid )
                _targets[eid] = nil
                _released(other)
                other.eid = nil
            end
        end
    end
end

local _pussButtonTouch = function(self, e)
    if self.eid and self.eid ~= e.id then return false end
    if e.phase == "began" then
        if self.eid == nil then self.eid = e.id end
        _targets[e.id] = self
        TMR.setFocus(self.target, e.id)
        _pressed(self)
        if self.onPress then self.onPress(e) end
        return true
    elseif e.isFocused then
        if e.phase == "moved" then
            if _isWithinBounds(self, e) then
                _pressed(self)
            else
                _released(self)
            end
            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            TMR.unsetFocus( self.target, e.id )
            if e.phase == "ended" then
                if _targets[e.id] and _isWithinBounds(self, e) then
                    if self.onRelease then self.onRelease(e) end
                    _cancellOtherBttns(self)
                else
                    e.phase = "cancelled"
                end

            end
            _targets[e.id] = nil
            _released(self)
            self.eid = nil
            return true
        end
    end

    if self.onEvent then self.onEvent(e) end
end

local _isTap = function(self, e)
    if self.startPosX then
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

local _taptouch = function(self, e)
    local result = false
    if self.eid and self.eid ~= e.id then return false end
    if e.phase == "began" then
        if self.eid == nil then self.eid = e.id end
        local cx, cy = self.target:localToContent(0, 0)
        self.startPosX, self.startPosY = e.x - cx, e.y - cy

        _targets[e.id] = self
        TMR.setFocus(self.target, e.id)
        _pressed(self)
        if self.onPress then self.onPress(e) end
        return true
    elseif e.isFocused then
        if e.phase == "moved" then
            if _isTap(self, e) then
                _pressed(self)
            else
                TMR.unsetFocus( self.target, e.id )
                _released(self)
                _targets[e.id] = nil
                self.startPosX = nil
                self.startPosY = nil
                self.eid = nil
            end
            return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
            TMR.unsetFocus( self.target, e.id )
            if e.phase == "ended" then
                if _targets[e.id] and _isTap(self, e) then
                    if self.onRelease and self.pressed then
                        result = self.onRelease(e)
                        _cancellOtherBttns(self)
                    end
                else
                    e.phase = "cancelled"
                end
            end
            _released(self)
            _targets[e.id] = nil
            self.startPosX = nil
            self.startPosY = nil
            self.eid = nil
            return true
        end
    end
    -- if self.onEvent then result = self.onEvent(e) end

    return result
end

function DMCButton:initialize(target, options)
    self.target = target
    self.pressed = false
    self.overScale = options.overScale or 0.96
    self.region = options.region
    self.onEvent = options.onEvent
    self.onPress = options.onPress
    self.onRelease = options.onRelease
    target.filter = Filter:new(options.filter)
    self.eid = nil -- 用于控制触摸手指数目

    if options.tap == true then
        self.touch = _taptouch
        if self.region == nil then
            self.region = {}
            self.region.width = 200
            self.region.height = 200
        end
    else
        self.touch = _pussButtonTouch
    end

    -- local this = self
    display.aliasRemoveSelf(target, function(obj)
        Component.remove("dmc_button", obj)
    end)
    -- self.target:addEventListener("finalize", function(e)
    --     Component.remove("dmc_button", self.target)
    -- end)
end

function DMCButton:enable()
    TMR.register(self.target, self)
end

function DMCButton:disable()
    TMR.unregister(self.target, self)
end

return DMCButton
