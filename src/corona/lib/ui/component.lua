-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local M = {}
M.eidDictionary = {}

local _PACKAGE = currentPackage(...)

M.add = function(name, target, options)
    target._components = target._components or {}
    if target._components[name] == nil then
        local m = require(_PACKAGE .. '.component.' .. name)
        local component = m:new(target, options or {})
        component:enable()
        target._components[name] = component
    end
    return target._components[name]
end

M.get = function(name, target)
    if target._components then
        return target._components[name]
    end
end

M.disable = function(name, target)
    if target._components then
        if target._components[name] then
            target._components[name]:disable()
        end
    end
end

M.enable = function(name, target)
    if target._components then
        local component = target._components[name]
        if component then
            component:enable()
        end
    end
end

M.remove = function(name, target)
    if target._components then
        local component = target._components[name]
        if component then
            component:disable()
            target._components[name] = nil
        end
    end
end

return M