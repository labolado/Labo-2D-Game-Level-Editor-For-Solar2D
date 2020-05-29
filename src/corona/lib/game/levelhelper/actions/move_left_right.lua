-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--使指定的物理对象进行旋转
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("move_left_right", {
    {name = "speed", required = true, type = "int", limit = {max = 10000, min = -10000}, desc="移动速度"},
    {name = "left", default = 50, type = "int", limit = {max = 1000000, min = 0}, desc="向左移动距离"},
    {name = "right", default = 50, type = "int", limit = {max = 1000000, min = 0}, desc="向右移动距离"},
    -- {name = "x", default = .5, type = "float", limit = {max = 1, min = 0}, desc="x坐标"}

})

function Action.init(ctx, obj)
    Helper.clearTargetJoint(ctx, obj.target)
    local physics = ctx.physics
    local target = obj.target
    local dot = display.newRect(0, 0, 500, 500)
    dot:translate( target.x + 400, target.y )

   -- physics.setDrawMode("hybrid")

    dot.isVisible = false
    target.parent:insert(dot)
    -- target.bodyType = "dynamic"
    target.gravityScale = 0
    target.isFixedRotation = true
    physics.addBody( dot, "static", { density = 10, filter = {groupIndex = -1}, isSensor = true })
    local piston = physics.newJoint( "piston", dot, target, dot.x, dot.y, 1, 0 )
    obj.joint = piston
    ctx.physicsJoints[#ctx.physicsJoints + 1] = obj

    local dir = 25 * sign(target.xScale)
    local initX = target.x
    local checkFlag = true
    local scale = 1 -- getWorldScale(target)
    local left = obj.left * IPAD_SCALE / scale
    local right = obj.right * IPAD_SCALE / scale
    function obj:enterFrame(e)
        if checkFlag then
            if target.x < initX - left or
                target.x > initX + right then
                checkFlag = false
                dir = -dir
                piston.motorSpeed = obj.speed * 0.01 * dir
                -- target:setLinearVelocity( 0, 0 )
                self.target.bodyType = "static"
                ctx.timerMgr:setTimeout(100, function()
                    piston.motorSpeed = obj.speed * dir
                    self.target.bodyType = "dynamic"
                    ctx.timerMgr:setTimeout(100, function()
                        checkFlag = true
                    end)
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
        piston.isMotorEnabled = true
        piston.maxMotorForce = 200000
        piston.motorSpeed = self.speed * dir
        ctx.timerMgr:setTimeout(1, function()
            self.target.bodyType = "dynamic"
        end)
    end
    Runtime:addEventListener( "enterFrame", obj )
end

function Action.execute(ctx, obj)
    -- if not obj.isInitialized then
        -- obj.isInitialized = true
        Action.init(ctx, obj)
    -- end
    obj:start()
    _D("=========== Start " .. tostring(obj.target.lhUniqueName) .. " ==========")
    _D("name=" .. Action.name)
    _D("speed=" .. obj.speed)
    _D("left=" .. obj.left)
    _D("right=" .. obj.right)
end


return Action
