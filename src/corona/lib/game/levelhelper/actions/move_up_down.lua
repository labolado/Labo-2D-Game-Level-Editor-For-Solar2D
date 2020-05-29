-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--使指定的物理对象进行旋转
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("move_up_down", {
    {name = "speed", required = true, type = "int", limit = {max = 100000, min = -100000}, desc="移动速度"},
    {name = "up", default = 50, type = "int", limit = {max = 1000000, min = 0}, desc="向左移动距离"},
    {name = "down", default = 50, type = "int", limit = {max = 1000000, min = 0}, desc="向右移动距离"},
    -- {name = "x", default = .5, type = "float", limit = {max = 1, min = 0}, desc="x坐标"}

})

function Action.init(ctx, obj)
    Helper.clearTargetJoint(ctx, obj.target)
    local physics = ctx.physics
    local target = obj.target
    local dot = display.newRect(0, 0, 50, 50)
    dot:translate( target.x, target.y )
    dot.isVisible = false
    target.parent:insert(dot)
    -- target.bodyType = "dynamic"
    target.gravityScale = 0
    target.isFixedRotation = true
    physics.addBody( dot, "static", { density = 5, filter = {groupIndex = -1}, isSensor = true })
    local piston = physics.newJoint( "piston", dot, target, dot.x, dot.y, 0, 1 )
    obj.joint = piston
    ctx.physicsJoints[#ctx.physicsJoints + 1] = obj

    local dir = 25 * sign(target.yScale)
    local initX = target.y
    local checkFlag = true
    local scale = 1 -- getWorldScale(target)
    local up = obj.up * IPAD_SCALE / scale
    local down = obj.down * IPAD_SCALE / scale
    function obj:enterFrame(e)
        if checkFlag then
            if target.y < initX - up or
                target.y > initX + down then
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
end


return Action
