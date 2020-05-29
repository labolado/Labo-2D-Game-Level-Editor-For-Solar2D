-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--使指定的物理对象进行旋转
local VectorLight = import("thirdparty.polygon.vector-light")
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("move_to", {
    {name = "speed", default=100, type = "int", limit = {max = 10000, min = -10000}, desc="移动速度"},
    {name = "goal", default = "", type = "string", limit = {max = 10000, min = -10000}, desc="终点" },
    {name = "x", default = true, type = "bool", desc="是否取goal的x值"},
    {name = "y", default = true, type = "bool", desc="是否取goal的y值"},
    {name = "dx", default = 0, type = "float", limit = {max = math.huge, min = -math.huge}, desc="相对位置x"},
    {name = "dy", default = 0, type = "float", limit = {max = math.huge, min = -math.huge}, desc="相对位置y"},
    {name = "max_Force", default = 200000, type = "float", limit = {max = math.huge, min = 0}, desc="关节最大力量"},
    {name = "check_complete", default = true, type = "bool", desc="是否检查到达目标"}
})

function Action.init(ctx, obj)
    Helper.clearTargetJoint(ctx, obj.target)
    local physics = ctx.physics
    local target = obj.target
    local x, y = target.x, target.y
    if obj.goal ~= "" then
        local goal = Helper.findLevelObject(ctx, obj.goal, target.loaderID)
        assert(goal ~= nil, "Move to " .. obj.goal .. "! " .. obj.goal .. " not exist!")
        if obj.x then x = goal.x end
        if obj.y then y = goal.y end
    else
        x, y = x + obj.dx, y + obj.dy
    end
    if equalToZero(x - target.x, 0.1) and equalToZero(y - target.y, 0.1) then
        obj.start = EMPTY
        ctx.timerMgr:setTimeout(1, function()
            obj.target.bodyType = "static"
            Helper.onActionComplete(ctx, obj)
        end)
        return
    end
    local axisX, axisY = VectorLight.normalize(x - target.x, y - target.y)

    local dot = display.newRect(0, 0, 20, 20)
    dot:translate( target.x, target.y )
    dot.isVisible = false
    target.parent:insert(dot)
    -- target.bodyType = "dynamic"
    target.gravityScale = 0
    target.isFixedRotation = true
    physics.addBody( dot, "static", { density = 10, filter = {groupIndex = -1}, isSensor = true })
    local piston = physics.newJoint( "piston", dot, target, dot.x, dot.y, axisX, axisY )
    obj.joint = piston
    ctx.physicsJoints[#ctx.physicsJoints + 1] = obj

    -- local dir = 25 * sign(target.xScale)
    -- local dir = 25
    local checkFlag = true
    local fps = 1 / display.fps
    local defaultLimit = 200 * fps
    function obj:enterFrame(e)
        if checkFlag then
            local currDelta = math.abs(self.joint.motorSpeed * 1.5 * fps)
            local delta = defaultLimit > currDelta and defaultLimit or currDelta
            -- _D(lengthOf2(target.x, target.y, x, y))
            -- _D(currDelta, lengthOf2(target.x, target.y, x, y))
            if lengthOf2(target.x, target.y, x, y) < delta then
                checkFlag = false
                self.joint.isMotorEnabled = false
                self.joint.motorSpeed = 0
		        ctx.timerMgr:setTimeout(1, function()
		            self.target.bodyType = "static"
                    Helper.onActionComplete(ctx, obj)
		        end)
            end
        end
    end

    function obj:removeSelf()
        self.joint:removeSelf()
        dot:removeSelf()
        Runtime:removeEventListener("enterFrame", self)
        self.joint = nil
        dot = nil
    end
    function obj:start()
        self.joint.isMotorEnabled = true
        self.joint.maxMotorForce = self.max_Force
        self.joint.motorSpeed = self.speed
        ctx.timerMgr:setTimeout(1, function()
            self.target.bodyType = "dynamic"
        end)
    end

    function obj:onControlUpdate(e)
        if self.joint and e.moveSpeed then
            self.joint.motorSpeed = e.moveSpeed
        end
    end

    if obj.check_complete then
        Runtime:addEventListener( "enterFrame", obj )
    end
end

function Action.execute(ctx, obj)
    Action.init(ctx, obj)
    obj:start()
end

return Action