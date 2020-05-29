-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local TouchMgr = require("lib.system.touch_manager")

function TouchMgr.getActiveTouches(target)
    return TouchMgr._getActiveTouches(target)
end

function TouchMgr.getActiveTouchesCount( t_obj )
    local count = 0
    for te_id, value in pairs( TouchMgr._FOCUS ) do
        if t_obj == value then
            count = count + 1
        end
    end
    return list
end

function TouchMgr.getFocusTarget(event_id)
    return TouchMgr._FOCUS[ event_id ]
end

function TouchMgr.canFocus(e_id, target)
    local result = true
    local focusTarget = TouchMgr.getFocusTarget(e_id)
    if focusTarget ~= nil and focusTarget ~= target then
        result = false
    end
    return result
end

-- function TouchMgr.cancelTouch(event, ctx)
function TouchMgr.cancelTouch(event, ctx)
    local target = TouchMgr._FOCUS[event.id]
    if target then
        local struct = TouchMgr._OBJECT[target]
        if struct then
            local e = _.clone(event)
            e.phase = "cancelled"
            e.isFocused = true
            e.isFromTouchManager = true
            -- target:dispatchEvent(e)
            struct:dispatch(e)
            -- ctx:log("TMgr cancelTouch", target, event.id, event.phase)
        end
    end
end

function TouchMgr.clearAllFocus()
    for k,v in pairs(TouchMgr._FOCUS) do
        TouchMgr._FOCUS[k] = nil
    end
end

function TouchMgr.cleanUp()
    local focusDict = TouchMgr._FOCUS
    for k,v in pairs(focusDict) do
        focusDict[k] = nil
    end
    local objectDict = TouchMgr._OBJECT
    for k,v in pairs(objectDict) do
        objectDict[k] = nil
    end
end

function TouchMgr.unregister( t_obj, handler )
    if TouchMgr._OBJECT[ t_obj ] == nil then return end
    if handler == nil then handler=t_obj end
    --==--
    local struct = TouchMgr._getRegisteredObjectStruct( t_obj )
    local active = TouchMgr._getActiveTouches( t_obj )
    struct:removeListener( handler, active )
    TouchMgr._removeRegisteredObjectStruct( t_obj )
end

return TouchMgr
