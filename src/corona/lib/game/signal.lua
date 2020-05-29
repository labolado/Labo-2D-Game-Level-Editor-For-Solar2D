-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- 用于在不同的模块间传输信号
-- 在A模块中发射信号之后，所有注册了接收信号的模块都会接收到信号

--A simple yet effective fre of Signals and Slots, also known as Observer pattern: Functions can be dynamically bound to signals. When a signal is emitted, all registered functions will be invoked. Simple as that.
--
--hump.signal makes things more interesing by allowing to emit all signals that match a Lua string pattern.

-- @usage:
-- in AI.lua
--signals.register('shoot', function(x,y, dx,dy)
--    -- for every critter in the path of the bullet:
--    -- try to avoid being hit
--    for critter in pairs(critters) do
--        if critter:intersectsRay(x,y, dx,dy) then
--            critter:setMoveDirection(-dy, dx)
--        end
--    end
--end)
--
-- in sounds.lua
--local handle = signals.register('shoot', function()
--    Sounds.fire_bullet:play()
--end)

-- signals.remove("shoot", handle)

-- in main.lua
--function love.keypressed(key)
--    if key == ' ' then
--        local x,y   = player.pos:unpack()
--        local dx,dy = player.direction:unpack()
--        signals.emit('shoot', x,y, dx,dy)
--    end
--end
--

-- local S = {}

-- function S:new()

local Registry = {}
Registry.__index = function(self, key)
    return Registry[key] or (function()
        local t = {}
        rawset(self, key, t)
        return t
    end)()
end

function Registry:register(s, f)
    self[s][f] = f
    return f
end

-- 注册之后，只执行一次即自动销毁
function Registry:registerOnce(s, f)
    local this = self
    local func
    func = function(...)
        this:remove(s, func)
        func = nil
        f(...)
    end
    ret = self:register(s, func)
    return ret
end

function Registry:hasRegistered(s)
    return next(self[s]) ~= nil
end

function Registry:get_name(name)
    local t = {}
    local n = 1
    for f in pairs(self[name]) do
        t[n] = f
        n = n + 1
    end
    return t
end

function Registry:get_all(name)
    local t = {}
    local n = 1
    for f in pairs(self[name]) do
        t[n] = f
        n = n + 1
    end
    return t
end

function Registry:emit(s, ...)
    -- local fs = {}
    -- for f in pairs(self[s]) do
    --     table.insert(fs, f)
    -- end
    -- for i = #fs, 1, -1 do
    --     fs[i](...)
    -- end
    -- fs = nil

    -- Log:dump(self[s])
    -- for i = #self[s], 1, -1 do
    --     print("emit: " .. i)
    --     local func = self[s][i]
    --     if func ~= nil then
    --         func(...)
    --     end
    -- end

    for f in pairs(self[s]) do
        -- print("signal", s, f)
        f(...)
    end
end

function Registry:remove(s, ...)
    local f = {...}
    for i = 1,select('#', ...) do
        if f[i] ~= nil then
            self[s][f[i]] = nil
        end
    end
end

function Registry:clear(...)
    local s = {...}
    for i = 1,select('#', ...) do
        self[s[i]] = {}
    end
end




function Registry:emit_pattern(p, ...)
    for s in pairs(self) do
        if s:match(p) then self:emit(s, ...) end
    end
end

function Registry:remove_pattern(p, ...)
    for s in pairs(self) do
        if s:match(p) then self:remove(s, ...) end
    end
end

function Registry:clear_pattern(p)
    for s in pairs(self) do
        if s:match(p) then self[s] = {} end
    end
end

function Registry:clear_all()
    for s in pairs(self) do
          self[s] = {}
    end
end

function Registry:clear_name(name)
    for s in pairs(self) do
        if s == name then self[s] = {} end
    end
end

-- the module
local function new()
    local registry = setmetatable({}, Registry)

    return setmetatable({
        new            = new,
        register       = function(...) return registry:register(...) end,
        registerOnce   = function(...) return registry:registerOnce(...) end,
        hasRegistered  = function(...) return registry:hasRegistered(...) end,
        emit           = function(...) registry:emit(...) end,
        remove         = function(...) registry:remove(...) end,
        clear          = function(...) registry:clear(...) end,
        emit_pattern   = function(...) registry:emit_pattern(...) end,
        remove_pattern = function(...) registry:remove_pattern(...) end,
        clear_pattern  = function(...) registry:clear_pattern(...) end,
        clear_all      = function(...) registry:clear_all() end,
        clear_name  = function(...) registry:clear_name(...) end,
    }, {__call = new})
end

return new()
-- end
-- return S
