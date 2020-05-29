-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 关卡内创建关节控制
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("lh_create_joint", {
	{name = "name", required=true, type = "string", limit = {max = 100, min = 0}, desc="joint类型"},
	{name = "other", required=true, type = "string", limit = {max = 100, min = 0}, desc="joint连接对象B"},
	{name = "anchor", default="", type = "string", limit = {max = 100, min = 0}, desc="链接点"},
})

function Action.execute(ctx, obj)
	local physics = ctx.physics
    Helper.clearTargetJoint(ctx, obj.target)

    local bodyA = obj.target
    local bodyB = Helper.findLevelObject(ctx, obj.other, bodyA.loaderID)
    bodyB = Helper.getNpcCarBodyByTarget(ctx, bodyB) or bodyB
    local x, y = bodyA.x, bodyA.y
    bodyA.bodyType = "dynamic"
    if obj.anchor ~= "" then
        local anchor = Helper.findLevelObject(ctx, obj.anchor, bodyA.loaderID)
        x, y = anchor.x, anchor.y
    end
    if obj.name == "weld" then
        obj.joint = physics.newJoint("weld", bodyA, bodyB, x, y)
		obj.joint.dampingRatio = 1
		obj.joint.frequency = 60
	    ctx.physicsJoints[#ctx.physicsJoints + 1] = obj
    elseif obj.name == "pivot" then
        local joint = physics.newJoint("pivot", objA, objB, x, y)
        -- joint.isMotorEnabled = jointInfo:boolForKey("EnableMotor")
        -- joint.motorSpeed = 0
        -- joint.maxMotorTorque = jointInfo:floatForKey("MaxTorque")
        -- joint.isLimitEnabled = jointInfo:boolForKey("EnableLimit")
        -- joint:setRotationLimits( jointInfo:floatForKey("LowerAngle"), jointInfo:floatForKey("UpperAngle") )
        obj.joint = joint
        ctx.physicsJoints[#ctx.physicsJoints + 1] = obj
    end

end

return Action
