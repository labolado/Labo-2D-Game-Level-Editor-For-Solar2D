-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 解除weld关节绑定
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("unbind", {
	{name = "obj1", default="", type = "string", limit = {max = 100, min = 0}, desc="joint连接对象A"},
	{name = "obj2", default="", type = "string", limit = {max = 100, min = 0}, desc="joint连接对象B"},
})

function Action.execute(ctx, act)
    local bodyA
    local bodyB
    if act.obj1 == "" then
        bodyA = act.target
    else
        if act.obj1 == "_PLAYER_" then
            bodyA = ctx.car:getBody()
        else
            bodyA = Helper.findLevelObject(ctx, act.obj1, act.target.loaderID)
        end
    end
    if act.obj2 == "" then
        bodyB = ctx.car:getBody()
        ctx.car:changeHeadPhysicType("dynamic")
    else
        bodyB = Helper.findLevelObject(ctx, act.obj2, act.target.loaderID)
        local npc = Helper.getNpcCarBodyByTarget(ctx, bodyB)
        if npc ~= nil then
            bodyB = npc
        end
    end
    local id = tostring(bodyA) .. tostring(bodyB)
    _D("unbind " .. id)
    Helper.clearTargetJoint(ctx, id)
end

return Action
