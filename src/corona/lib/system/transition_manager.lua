-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.




-- Transition 管理类

--usage:
--local tm = require("../transition_manager")
--tm = tm.new()
--tm:add(plane1, {time = 5000, x = display.contentWidth - plane1.contentWidth * .5, onComplete = function() print("Plane 1 finished") end})
-- tm.cancel()
--tm:add(plane2, {time = 5000, rotation = 270, onComplete = function() print("Plane 2 finished") end})
--
--tm:add(plane3, {time = 5000, alpha = 0, rotation = 270, onComplete = function() print("Plane 3 finished") end})
--
--tm:add(plane4, {time = 2000, x = display.contentWidth - plane1.contentWidth * .5, transition = easing.inOutExpo, onComplete = function() print("Plane 4 finished") end})
--tm:pauseAll()
--tm:resumeAll

local TransitionManager  = {}

local pairs = pairs
function TransitionManager:new()
    local transitions = {
        goingOn = 0,
        transitionId = 1,
        db = {},

        paused = false,
        pausedSince = 0,
    }

    function transitions:add(object, params)
        local timeNow = system.getTimer()
        local givenCallback = params.onComplete
        local tween

        local thisId = self.transitionId

        -- self.db[thisId] = {
        --     object = {},
        --     params = {},
        --     timeStarted = 0,
        --     transition = {},
        --     remove = {},
        --     cancel = {}
        -- }

        -- Remove this transition pointers and count
        local function removeItself(whichId)
            local transitionId = whichId

            return function()
                if  transitions.db[transitionId] ~= nil and transitions.db[transitionId].transition ~= nil then
                    transitions.db[transitionId].transition = nil
                end
                transitions.db[transitionId] = nil
                transitions.goingOn = transitions.goingOn - 1
            end
        end

        -- Allow to cancel this transition
        local function cancelItself(whichId)
            local transitionId = whichId

            return function()
                if transitions.db[transitionId] ~= nil and transitions.db[transitionId].transition ~= nil then
                    transition.cancel(transitions.db[transitionId].transition)
                    transitions.db[transitionId].transition = nil
                end

                if transitions.db[transitionId] ~= nil then
                    transitions.db[transitionId].remove()
                end
            end
        end

        -- Create the callback which will call removal from object
        local function transitionCallback(nextId)
            local transitionId = nextId
            local callback = givenCallback

            return function(obj)
                if callback ~= nil then
                    callback(obj)
                end

                local remove = removeItself(transitionId)
                remove()
            end
        end

        if params.alreadyAddedTransitionCallback == nil then
            params.onComplete = transitionCallback(thisId)
            params.alreadyAddedTransitionCallback = true
        end

        local transFunc = params.transFunc or transition.to
        params.transFunc = nil
        self.db[thisId] = {
            object = object,
            params = params,
            timeStarted = timeNow,
            transition = transFunc(object, params),
            remove = removeItself(thisId),
            cancel = cancelItself(thisId)
        }
        self.transitionId = self.transitionId + 1
        self.goingOn = self.goingOn + 1




        return self.db[thisId]
    end

    function transitions:cancel(target)
        for k, v in pairs(self.db) do
            if v.object == target then
                transition.cancel(v.transition)
                self.db[k] = nil
            elseif v.transition == target then
                transition.cancel(v.transition)
                self.db[k] = nil
                break
            end
        end
    end

    -- function transitions:cancelAll(pausing, ignorePaused)
    function transitions:cancelAll()
        if self.goingOn <= 0 then
            return false
        end

        -- if self.paused and (not ignorePaused or ignorePaused == nil) then
        --     self.paused      = false
        --     self.pausedSince     = 0
        -- else
            for i, v in pairs(self.db) do
                if v.transition ~= nil then
                    transition.cancel(v.transition)
                    v.transition = nil
                end
            end
        -- end

        -- if pausing == nil or pausing == false then
            -- if ignorePaused then
                self.paused         = false
                self.pausedSince    = 0
            -- end

            self.goingOn        = 0
            self.transitionId   = 1

            for i, v in pairs(self.db) do
                -- v = nil
                self.db[i] = nil
            end

            self.db = {}
        -- end

        collectgarbage()
    end

    function transitions:pauseAll()
        if self.paused then
            return false
        end

        -- self:cancelAll(true)
        self.paused = true
        self.pausedSince = system.getTimer()
        for i, v in pairs(self.db) do
            -- local transFunc = v.params.transFunc or transition.to
            -- v.params.time = v.params.time - (self.pausedSince - v.timeStarted)
            -- v.timeStarted = timeNow
            -- v.transition = transFunc(v.object, v.params)
            if v.transition then
                transition.pause(v.transition)
            end
        end
    end

    function transitions:resumeAll()
        if not self.paused then
            return false
        end

        local timeNow = system.getTimer()

        for i, v in pairs(self.db) do
            -- local transFunc = v.params.transFunc or transition.to
            -- v.params.time = v.params.time - (self.pausedSince - v.timeStarted)
            -- v.timeStarted = timeNow
            -- v.transition = transFunc(v.object, v.params)
            if v.transition then
                transition.resume(v.transition)
            end
        end

        self.paused = false
        self.pausedSince = 0
    end

    return transitions
end
return TransitionManager
