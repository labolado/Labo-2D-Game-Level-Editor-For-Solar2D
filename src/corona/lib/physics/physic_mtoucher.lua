-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- 用于多点触摸情况下的touch控制

local M = {}

local PhysicHelper1 = import('physics.physic_helper')

function M:new(object, touchAgentParent, touchListener)
    local Toucher = {}

    Toucher.offsetX = 0
    Toucher.offsetY = 0

    Toucher.isDebug = false

    function Toucher:setDebug(b)
        self.isDebug = b
    end

    function Toucher:debug(msg)
        if self.isDebug == true then
            -- Log:debug("physic mtoucher debug:" .. msg)
        end
    end

    function Toucher:getObject()
        return object
    end

    --Toucher
    function Toucher:updateOffset(offsetX, offsetY)
        self.offsetX = offsetX or 0
        self.offsetY = offsetY or 0
    end



    function Toucher:callToucherListener(e)
        e.target = object

        if type(touchListener) == 'function' then
            touchListener(e)
        end
        if type(touchListener) == 'table' then
            touchListener:touch(e)
        end
    end


    local events = {}
    function Toucher:touch(e)
        local target = e.target
        if (e.phase == "began") then
            local onTarget = PhysicHelper1.isOnBody(e.x  , e.y , self.offsetX, self.offsetY, target)
            --self:debug("onTarget:" .. tostring(onTarget) .. " " .. self.offsetX )
            if onTarget then
                events[e.id] = Toucher:newTrackDot(e)
                --self:debug("touch began: " .. tostring(e))
                object.mtouchTimers = object.mtouchTimers  or 0
                object.mtouchTimers = object.mtouchTimers + 1
                self:callToucherListener(e)
                return true
            end
        elseif (e.parent == object) then

            if (e.phase == "moved") then
                if events[e.id] ~= nil then
                    --self:debug("touch moved ")
                    self:callToucherListener(e)
                end
            else -- ‘ended’ and ‘cancelled’ phases
                if events[e.id] ~= nil then
                    events[e.id]:removeSelf()
                    events[e.id] = nil
                    --self:debug("touch ended: " .. tostring(e))
                    object.mtouchTimers = object.mtouchTimers - 1
                    self:callToucherListener(e)
                    if object.mtouchTimers == 0 then
                        object.mtouchTimers = nil
                    end

                end
            end
            return true
        end
        return false
    end


    function Toucher:newTrackDot(e)
        local circle = display.newCircle(touchAgentParent, e.x, e.y, 50)
        circle.alpha = 0
        if self.isDebug == true then
            circle.alpha = .5
        end

        local rect = e.target

        function circle:touch(e)
            local target = circle
            e.parent = object
            if (e.phase == "began") then
                display.getCurrentStage():setFocus(target, e.id)
                target.hasFocus = true
                return true
            elseif (target.hasFocus) then
                if (e.phase == "moved") then
                    target.x, target.y = e.x, e.y
                else -- "ended" and "cancelled" phases
                    display.getCurrentStage():setFocus(target, nil)
                    target.hasFocus = false
                end
                Toucher:touch(e)
                return true
            end
            return false
        end

        circle:addEventListener("touch")
        circle:touch(e)
        return circle
    end

    object:addEventListener("touch", Toucher)

    function Toucher:removeSelf()
        --if object ~= nil and Toucher ~= nil then
            object:removeEventListener("touch", Toucher)
        --end
    end

    -- local oldRemoveSelf = object.removeSelf
    -- if oldRemoveSelf ~= nil then
    --     function object:removeSelf()
    --         if Toucher ~= nil then
    --             Toucher:removeSelf()
    --             oldRemoveSelf(self)
    --         end
    --     end
    -- end

    return Toucher
end

return M


