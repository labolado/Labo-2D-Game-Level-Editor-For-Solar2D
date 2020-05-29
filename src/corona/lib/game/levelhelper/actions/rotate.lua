-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
--使指定的物理对象进行旋转
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("rotate", {
    {name = "speed", default = 50, type = "int", limit = {max = 10000, min = -100000}, desc="旋转速度"},
    {name = "anchor", default="", type = "string", limit = {max = 10000, min = -10000}, desc="旋转点"}
})

function Action.init(ctx, obj)
    Helper.clearTargetJoint(ctx, obj.target)
    local physics = ctx.physics
    local target = obj.target
    local x, y = target.x, target.y
    if obj.anchor ~= "" then
        local anchor = Helper.findLevelObject(ctx, obj.anchor, obj.target.loaderID)
        x, y = anchor.x, anchor.y
    end

    local dot
    local npc = Helper.getNpcCarBodyByExtension(ctx, obj)
    if npc then
        dot = npc
    else
        dot = display.newRect(0, 0, 20, 20)
        dot:translate(x, y)
        dot.isVisible = false
        target.parent:insert(dot)
        physics.addBody(dot, "static", { filter = {groupIndex = -1}, isSensor = true })
    end
    target.bodyType = "dynamic"
    target.gravityScale = 0
    local pivot = physics.newJoint("pivot", dot, target, x, y)
    obj.joint = pivot
    ctx.physicsJoints[#ctx.physicsJoints + 1] = obj
    -- _D("!-> Rotate ", target.lhUniqueName)

    obj.motoDir = sign(obj.speed)
    function obj:start()
        self.joint.isMotorEnabled = true
        self.joint.maxMotorTorque = 300000
        self.joint.motorSpeed = self.speed
    end

    function obj:onControlUpdate(e)
        if self.joint and e.rotateSpeed then
            self.joint.motorSpeed = e.rotateSpeed * self.motoDir
        end
    end

    function obj:removeSelf()
        self.joint:removeSelf()
        dot:removeSelf()
        self.joint = nil
        dot = nil
    end
end

function Action.execute(ctx, obj)
    -- if not obj.isInitialized then
    --     obj.isInitialized = true
        Action.init(ctx, obj)
    -- end
    obj:start()
    -- _D("=========== Start " .. tostring(obj.target.lhUniqueName) .. " ==========")
    -- _D("name=" .. Action.name)
    -- _D("speed=" .. obj.speed)
    -- _D("x=" .. obj.x)
end


return Action
