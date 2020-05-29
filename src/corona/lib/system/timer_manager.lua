--[[
    TIMER MANAGER

    Just a helper to allow an easy way to cancel all ongoing timers when switching screens, etc.
    Example:
    local timers = require("timer_manager")
    timers:add(1000, someFunctionToCall)
    timers:add(2000, someFunctionToCall2)

    .. requested to change scene, even with timers going on:
    timers:cancelAll()

    NOTE: If you make changes/updates, feel free to send them to me, so we keep improving the class :)
    @author Alfred R. Baudisch <alfred.r.baudisch@gmail.com>
    @url http://www.karnakgames.com
    @version 0.1b, 09/Nov/2011
    @license http://creativecommons.org/licenses/by/3.0/
]]--
local T = {}

function T:new()

    local timers = {
        id = 1,
        db = {}
    }

    function timers:add(time, callback, amount)
        local createdTimer = timer.performWithDelay(time, callback, amount)
        -- table.insert(self.db, createdTimer)
        self.db[tostring(self.id)] = createdTimer
        self.id = self.id + 1
        return createdTimer
    end

    -- 在指定的时间后执行指定方法，只执行一次
    function timers:setTimeout(time, callback)
        return self:add(time, callback)
    end

    -- 循环执行
    -- @param interval 执行的时间间隔
    -- @param func 需要执行的方法
    -- @param times 执行的次数，默认为-1，表示无限重复
    function timers:setInterval(interval, callback, amount)
        return self:add(interval, callback, amount or -1)
    end


    -- 定时检查
    -- @param interval 执行的时间间隔
    function timers:peroidCheck(interval, conditionFunc, callback)
        local myTimer = nil
        myTimer = self:setInterval(interval, function()
            if conditionFunc() == true then
                if myTimer then
                    timer.cancel(myTimer)
                end
                callback()
            end
        end)
        return myTimer
    end

    function timers:pauseAll()
        -- local amountTimers = #self.db

        -- for i = 1, amountTimers do
            -- if self.db[i] ~= nil and (not self.db[i]._expired) then
                -- timer.pause(self.db[i])
            -- end
        -- end
        for id, v in pairs(self.db) do
            if not v._expired then
                timer.pause(v)
            end
        end
    end

    function timers:resumeAll()
        -- local amountTimers = #self.db

        -- for i = 1, amountTimers do
        --     if self.db[i] ~= nil and (not self.db[i]._expired) then
        --         timer.resume(self.db[i])
        --     end
        -- end
        for id, v in pairs(self.db) do
            if not v._expired then
                timer.resume(v)
            end
        end
    end

    function timers:clearTimer(handler)
        -- table.removeElement(self.db, handler)
        for id, v in pairs(self.db) do
            if v == handler then
                self.db[id] = nil
            end
        end
        -- clearTimer(handler)
        if handler then
            timer.cancel(handler)
        end
    end


    function timers:cancelAll()
        -- _D("cancell all timer")
        -- local amountTimers = #self.db

        -- for i = 1, amountTimers do
        --     if self.db[i] ~= nil then
        --         timer.cancel(self.db[i])
        --         self.db[i] = nil
        --     end
        -- end
        for id, v in pairs(self.db) do
            timer.cancel(v)
            self.db[id] = nil
        end
        self.id = 1
    end

    return timers
    end
return T
