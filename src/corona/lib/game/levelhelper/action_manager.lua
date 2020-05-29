-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- usage:
-- local ActionManager = import("game.levelhelper.action_manager")
-- local ctx = {}
-- local target = display.newCircle(0, 0, 100)
-- target.id = "id"
-- local act = ActionManager.create(ctx, "rotate",  target,  {speed = "1"})
-- act:execute()
local AM = {}

local Signal = import("game.signal")

local nameAlias = {
    ["enable_car_ctrl"] = "enable_ctrl",
    ["disable_car_ctrl"] = "disable_ctrl",
    ["spine"] = "null",
    ["audio"] = "null",
    ["audio_bg"] = "null"
}

local actionNames = {
 
    "rope",
    "rotate",
    "speed",
    "rotate_to",
    "move_left_right",
    "move_up_down",
    "move_to",
    "physic_to_dynamic",
    "physic_to_static",
    "destroy",
    "prop",
    "camera",
    "camera_move",
    "camera_transform",
    "game_camera_transform",
    "stop",
    "car_ctrl",
  
    "lh_joint_ctrl",
    "lh_create_joint",
    "physic_boundary",
    "mini_game_play",
    "mini_game_stop",
    "mini_game_excute",
    "level_insert",
    "level_insert_game",
    "counter",
    "bind",
    "unbind",
    "set_level_props",
    "car_prop",
    "set",
    "if",
    "let",
    "collide_began",
    "collide_ended",
    "path",
    "game_end",
    "event_dispatcher",
    "event_register",
    "load",
    "script",
    "to_physic",
    "remove_physic",
    "add_to_layer",
    "null"
}

local Actions =  pack(pkgImports(..., _.collect(actionNames, function(name)  return "actions."  .. name end)))

local getActionByName = function(name, target)

	local ret = _.find(Actions, function(act) return (nameAlias[name] or name) == act.name end)

    if name == nil then
        name = ""
    end

	assert(ret ~= nil,  "action name " .. name .. " not exists, target=" .. tostring(target and target.lhUniqueName) )

	return ret
end

function AM.create(ctx, actionName, target, properties)
	properties.target = target
	local actModel = getActionByName(actionName, target)

    -- ctx.actionSignal = Signal:new()

	local act = actModel:new(ctx, properties)

 	return act
end

return AM
