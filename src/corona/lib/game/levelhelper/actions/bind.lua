-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 通过weld关节绑定物体
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("bind", {
	{name = "obj1", default="",type = "string", limit = {max = 100, min = 1}, desc="joint连接对象A"},
	{name = "obj2", default="",  type = "string", limit = {max = 100, min = 1}, desc="joint连接对象B"},
    {name = "anchor", default="", type = "string", limit = {max = 10000, min = -10000}, desc="旋转点"},
    {name = "type", default=1, type = "int", limit = {max = 2, min = 1}, desc="连接类型,1是weld，固定连接 2是pivot,旋转连接"}
})

function Action.execute(ctx, act)
	local physics = ctx.physics
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
    local isNPC = false
    if act.obj2 == "" then
    	bodyB = ctx.car:getBody()
        ctx.car:changeHeadPhysicType("dynamic")
    else
    	bodyB = Helper.findLevelObject(ctx, act.obj2, act.target.loaderID)
        local npc = Helper.getNpcCarBodyByTarget(ctx, bodyB)
        if npc ~= nil then
            bodyB = npc
            isNPC = true
        end
    end
    if bodyA.bodyType == nil then
        ctx.physics.addBody(bodyA, "kinematic", {isSensor = true} )
        bodyA.isSensor = true
    end
    if bodyB.bodyType == nil then
        ctx.physics.addBody(bodyB, "kinematic", {isSensor = true} )
        bodyB.isSensor = true
    end
    local id = tostring(bodyA) .. tostring(bodyB)
    Helper.clearTargetJoint(ctx, id)

    local x, y
    if isNPC then
        x, y = bodyA.x, bodyA.y
    else
        x, y = bodyB.x, bodyB.y
    end
    if act.anchor ~= "" then
        local anchor = Helper.findLevelObject(ctx, act.anchor, act.target.loaderID)
        x, y = anchor.x, anchor.y
    end
    -- bodyA.bodyType = "dynamic"
    -- if act.anchor ~= "" then
    --     local anchor = Helper.findLevelObject(ctx, act.anchor, bodyA.loaderID)
    --     x, y = anchor.x, anchor.y
    -- end
    local jointObj = {}
    jointObj.target = id

    local jtype = "weld"
    if act.type == 2 then
        jtype = "pivot"
    end

    if isNPC then
        jointObj.joint = physics.newJoint(jtype, bodyB, bodyA, x, y)
    else
        jointObj.joint = physics.newJoint(jtype, bodyA, bodyB, x, y)
    end
    -- if act.extension then
    --     if jtype == "weld" then
    --         jointObj.joint.dampingRatio = tonumber(act.extension.dampingRatio) or 1
    --         jointObj.joint.frequency = tonumber(act.extension.frequency) or 0
    --         _D(tonumber(act.extension.frequency))
    --     end
    -- else
    --     if jtype == "weld" then
    --         jointObj.joint.dampingRatio = 1
    --         jointObj.joint.frequency = 0
    --     end
    -- end
    _D("Bind " .. id)
    ctx.physicsJoints[#ctx.physicsJoints + 1] = jointObj

    function jointObj:removeSelf()
        self.joint:removeSelf()
        self.joint = nil
    end
end

return Action
