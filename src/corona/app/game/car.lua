-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Poly = require("lib.thirdparty.polygon.poly_helper")
local SignalsManager = require("lib.game.signals_manager")

local Car = class("Car", Node)
Car:include(SignalsManager)

local unpack = unpack
local _getMassCenter = getMassCenter
local _angleTranslate = angleTranslate
local _equalToZero = equalToZero

local mathAbs = math.abs
local function _length(x1, y1, x2, y2)
    local w, h = x2-x1, y2-y1
    return (w*w + h*h)^0.5
end
local function _trangleArea(shape)
    local px, py = shape[1], shape[2]
    local qx, qy = shape[3], shape[4]
    local rx, ry = shape[5], shape[6]
    return mathAbs((qy - py) * (rx - qx) - (qx - px) * (ry - qy))
end
local function _calcArea(shapes)
    local m = 0
    local delete = {}
    for i=1, #shapes do
        local area
        local info = shapes[i]
        if info.shape then
            area = _trangleArea(info.shape)
        elseif info.box then
            local box = info.box
            area = box.halfWidth * box.halfHeight * 4
        end
        if _equalToZero(area, 1) then
            delete[#delete + 1] = info
        else
            m = m + area
        end
    end
    for i=1, #delete do
        table.remove(shapes, delete[i])
    end
    return m
end
local function _calcAndSetDensity(mass, unitMass, shapes)
    local area = _calcArea(shapes)
    local density = mass / (area * unitMass )
    for i=1, #shapes do
        shapes[i].density = density
    end
end

Car.static.calcAndSetDensity = _calcAndSetDensity

function Car:initialize(ctx, scale)
    self:initModule()
    self:create(scale)
    self:initProperties(ctx, scale)
    self.chassis = {}
    self.attachments = {}
end

function Car:create(scaleValue)
    local body = display.newImageRect(self, "assets/car/body.png", 266 * scaleValue, 204 * scaleValue)
    local wheel1 = display.newImageRect(self, "assets/car/wheel.png", 100 * scaleValue, 100 * scaleValue)
    local wheel2 = display.newImageRect(self, "assets/car/wheel.png", 100 * scaleValue, 100 * scaleValue)
    wheel1:translate(-75, 100)
    wheel2:translate(75, 100)
    self.body = body
    self.wheels = {wheel1, wheel2}
    self.members = {body, wheel1, wheel2}
end

function Car:createChassis(body, wheels)
    local h = -math.huge
    local y = -math.huge
    for i=1, #wheels do
        local wheel = wheels[i]
        if wheel.contentHeight > h then
            h = wheel.contentHeight
        end
        if wheel.y > y then
            y = wheel.y
        end
    end
    if #wheels <= 0 then
        y = body.y + body.contentHeight * 0.5
        h = body.contentHeight * 0.25
    else
        -- h = math.max(wheels[1].contentHeight, wheels[1].contentHeight)
        h = wheels[1].contentHeight
    end
    local w = body.contentWidth
    -- _D("chassis", body.x, body.y, y)
    w = math.max(w, 32)
    h = math.max(h, 100)
    local chassis = display.newRect(self, body.x, y, w, h)
    -- chassis:translate(0, wheels[1].y)
    -- chassis:translate(0, y)
    chassis:setFillColor(0, 0, 1, 0.5)
    chassis.isVisible = false
    return chassis
end

function Car:initProperties(ctx, scale)
    self.ctx = ctx
    self.scaleRatio = scale

    local gameScale = 2
    if ctx and ctx.physics then
        self._unitMass = ctx.physics.toMKS("length", 1) ^ 2
    end

    self._bodyAngularDamping  = 0.1
    self._wheelAngularDamping = 5 * gameScale
    self._piston              = 60
    self._frequency           = 30
    self._dampingRatio        = 0.1
    self._connectRotationLimit = 45

    self._driveSpeed          = 0
    self._maxSpeed            = 100
    self._initMaxSpeed        = self._maxSpeed
    self._standardMass        = 5.9 + 8.18 * 2 + 7.66
    self._bodyMass            = 5.9
    self._chassisMass         = 7.66
    self._chainMass           = 0.5
    self._wheelMass           = 1.8
    self._speedDelta          = 10
    self._dirChange           = false
    self._isPower             = false
    self._isStart             = false
    self._driveDir            = -1
    self._joints = {}
    self._motors = {}
    self._touchCount = 0
    self._isInTheAir = true
    self._turnTimer = nil
end

local _defaultFilter = {categoryBits = 0x0001, maskBits = 0x003f, groupIndex = -1}
local _bodyPhysics = {
    density     = 0.256,
    friction    = 0.3,
    bounce      = 0,
    isSensor    = false,
    isBullet    = true,
    filter      = _defaultFilter,
}

local _wheelPhysics = {
    density     = 2.5,
    friction    = 5,
    bounce      = 0,
    isSensor    = false,
    isBullet    = false,
    filter      = _defaultFilter,
}

local _chassisPhysics = {
    density     = 2.1,
    friction    = 0.1,
    bounce      = 0,
    isSensor    = true,
    isBullet    = false,
    filter      = _defaultFilter,
}

function Car:setPhysicFileter(filter)
    _bodyPhysics.filter = filter
    _wheelPhysics.filter = filter
    _chassisPhysics.filter = filter
end

function Car:initPhysics(filter)
    filter = filter or _defaultFilter
    self:setPhysicFileter(filter)

    local body = self.body
    local wheels = self.wheels
    local chassis = self:createChassis(body, wheels)
    _.push(self.chassis, chassis)
    self:createSimpleBodyPhysics(body, chassis)
    self:createWheelsPhysics(wheels)
    self:createChassisPhysics(chassis)
    local weld = physics.newJoint("weld", chassis, body, chassis.x, chassis.y)
    _.each(wheels, function(wheel)
        wheel.angularDamping = self._wheelAngularDamping
        wheel.isBullet = true
        wheel.linearDamping = 0

        local motor = physics.newJoint("wheel", body, wheel, wheel.x, wheel.y, 0, self._piston)
        motor.springFrequency      = self._frequency
        motor.springDampingRatio   = self._dampingRatio
        _.push(self._joints, motor)
        _.push(self._motors, motor)
    end)
end

function Car:initCollisionListener()
    self._isInTheAir = true
    -- local _collidedCallBacks = self._collidedCallBacks
    local function collision(this, e)
        if e.phase == "began" then
            if e.other.isVisible then
                self._touchCount = self._touchCount + 1
                self._isInTheAir = false
            end
        elseif e.phase == "ended" then
            if e.other.isVisible then
                self._touchCount = self._touchCount - 1
                if self._touchCount == 0 then
                    self._isInTheAir = true
                end
            end
        end
        self.signals.emit("car_collided", e)
    end
    self._touchCount = 0
    self.body.collision = collision
    self.body:addEventListener("collision")
    for i=1, #self.wheels do
        local wheel = self.wheels[i]
        wheel.tag = 1
        wheel.collision = collision
        wheel:addEventListener("collision")
    end
end


function Car:createSimpleBodyPhysics(body, chassis)
    local unitMass = self._unitMass
    local shapes = {}
    local x, y = chassis.x - body.x, chassis.y - body.y
    local box = {
        x = x,
        y = y,
        halfWidth = chassis.width * 0.5,
        halfHeight = chassis.height * 0.5,
        angle = 0
    }
    local density = (self._chassisMass) / (box.halfWidth * box.halfHeight * 4 * self._unitMass)
    local shape = _.clone(_bodyPhysics)
    shape.isSensor = true
    shape.box = box
    shape.density = density
    shapes[#shapes + 1] = shape

    box = {
        x = 0,
        y = 0,
        halfWidth = body.width * 0.45,
        halfHeight = body.height * 0.45,
        angle = 0
    }
    density = (self._bodyMass) / (box.halfWidth * box.halfHeight * 4 * self._unitMass)
    shape = _.clone(_bodyPhysics)
    shape.box = box
    shape.density = density
    shapes[#shapes + 1] = shape

    physics.addBody(body, "dynamic", unpack(shapes))
    body.angularDamping = self._bodyAngularDamping
    -- body.gravityScale = 0
    body.linearDamping = 0.01
    body.isBullet = true
end

function Car:createWheelsPhysics(wheels)
    local physics = self.ctx.physics
    -- local wheels = self.wheels
    local refValue = 150
    local min = math.min
    for i=1, #wheels do
        local wheel = wheels[i]
        local shape1 = _.clone(_wheelPhysics)
        local wheelPhysicScale = wheel.wheelPhysicScale or 1
        local r = min(wheel.contentWidth, wheel.contentHeight) * wheelPhysicScale
        wheel.speedRatio = r / refValue
        shape1.radius = r * 0.5

        local area1 = math.pi * shape1.radius * shape1.radius
        local area2 = 0
        local density = self._wheelMass / ((area1 + area2) * self._unitMass)
        shape1.density = density

        physics.addBody(wheel, "dynamic", shape1)
        wheel.gravityScale = 1
    end
end

function Car:createChassisPhysics(chassis)
    -- local polygon = Poly.createByWH(chassis.contentWidth, chassis.contentHeight, chassis, 1)
    local polygon = Poly.createByWH(64, 64, chassis, 1)
    local shapes = polygon:toTriangles(chassis, _chassisPhysics)
    _calcAndSetDensity(1, self._unitMass, shapes)
    physics.addBody(chassis, "dynamic", unpack(shapes))
    chassis.angularDamping = self._bodyAngularDamping
end

local abs = math.abs
function Car:drive()
    local ctx = self.ctx
    -- self:updateFrontBodys()
    if not self._isStart then return end
    local body = self:getBody()

    if self._isPower then
        if self._dirChange then
            local dir = -self._driveDir
            local speed, flag = clamp2(abs(self._driveSpeed - dir * self._speedDelta), 0, self._maxSpeed)
            self._driveSpeed = speed * dir
            if flag then self._dirChange = false end
        else
            local speed = clamp(abs(self._driveSpeed) + self._speedDelta, 0, self._maxSpeed)
            self._driveSpeed = speed * self._driveDir
        end
    else
        if abs(self._driveSpeed) > 0 then
            local speed, flag = clamp2(abs(self._driveSpeed) - self._speedDelta, 0, self._maxSpeed)
            self._driveSpeed = speed * self._driveDir
            if flag then
                self._dirChange = false
            end
        end
    end
    self:setSpeed( self._driveSpeed )
end

function Car:touch(e)
    local chassis = self.chassis[1]
    local ctx = self.ctx
    if self._isInTheAir or self._turnTimer  then
        chassis.angularDamping = self._bodyAngularDamping
        display.currentStage:setFocus(self, nil)
        self.isFocused = false
        return false
    end
    if (e.phase == "began") then
        -- ctx.sndMgr:carTouch()
        local mass = self:getMass()
        local mx, my = _getMassCenter(self.members)
        chassis:applyLinearImpulse(0, -210 * mass / ctx.PHYSICS_RATE / self._standardMass, mx, my)
        -- chassis:applyLinearImpulse(0, -220 * mass / self._standardMass, mx, my)

        self._turnTimer = ctx.timerMgr:setInterval(20, function(e)
            local rotation = _angleTranslate(chassis.rotation)
            local force = -rotation * 3.5 * mass/ ctx.PHYSICS_RATE_SQUARE / self._standardMass
            -- local force = -rotation * 3.5 * mass / self._standardMass
            chassis:applyAngularImpulse( force )
            if e.count > 50 then
                ctx.timerMgr:clearTimer(e.source)
                self._turnTimer = nil
            end
        end)
        display.currentStage:setFocus( self, e.id )
        self.isFocused = true
        return true
    elseif self.isFocused then
        if (e.phase == "ended") then
            chassis.angularDamping = self._bodyAngularDamping
            display.currentStage:setFocus(self, nil)
            self.isFocused = false
            return true
        end
    end
end

function Car:addCollisionCallBack(func)
    self:sigRegister("car_collided", func)
end

function Car:clearCollisionCallBack()
    self:sigClear("car_collided")
end

function Car:setSpeed(speed)
    _.each(self.wheels, function(wheel, i)
        wheel:applyTorque(speed * wheel.speedRatio / self.ctx.PHYSICS_RATE_SQUARE)
    end)
end

function Car:setPosition(x, y)
    for i=1, self.numChildren do
        local child = self[i]
        if child._localInitPos then
            child.x = child._localInitPos.x
            child.y = child._localInitPos.y
        else
            child._localInitPos = {x = child.x, y = child.y}
        end
    end
    local rx, ry = display.getWorldPosition(self)
    rx, ry = self.parent:contentToLocal(rx, ry)
    local dx, dy = x - rx, y - ry
    for i=1, self.numChildren do
        local child = self[i]
        child:translate(dx, dy)
    end
end

function Car:setGravityScale(value)
end

function Car:gravityScaleReverse()
end

function Car:gravityScaleRestore()
end

function Car:setCarDamping(value)
end

function Car:resetCarDamping()
end

function Car:changeHeadPhysicType(bodyType)
    -- self.chassis[1].bodyType = bodyType
    self.body.bodyType = bodyType
end

function Car:setLinearSpeed(vx, vy)
    _.each(self.members, function(child)
        child:setLinearVelocity(vx, vy)
    end)
end

function Car:speedUp(speed)
    self._maxSpeed = self._initMaxSpeed + speed * 0.2
end

function Car:setSpeedScale(scale)
    self._maxSpeed = self._initMaxSpeed * scale
end

function Car:getCurrentSpeedScale()
    return self._driveSpeed / self._maxSpeed
end

function Car:setPower(bool)
    self._isPower = bool
end

function Car:isPowering()
    return self._isPower
end

function Car:isStarted()
    return self._isStart
end

function Car:setDriveDir(direction)
    if self._driveDir ~= direction then
        self._dirChange = true
    end
    self._driveDir = direction
end

-- getter
function Car:getMaxSpeed()
    return self._maxSpeed
end

function Car:getChassis()
    -- if #self.chassis > 2 then
    --     return self.chassis[3]
    -- else
    --     return self.chassis[#self.chassis]
    -- end
    return self.body
end

function Car:getFocusObject()
    -- return self._focusObject
    return self.body
end

function Car:getBody()
    return self.body
end

function Car:updateFrontBodys()
end

function Car:getTail()
    return body
end

function Car:getWheels()
    return self.wheels
end

function Car:getHeadPos()
    return self.body.contentBounds.xMax
end

function Car:getDriveDir()
    return self._driveDir
end

function Car:getSpeed()
    return self._driveSpeed
end

function Car:getLinearSpeed()
    -- local vx, vy = self.body:getLinearVelocity()
    local vx, vy = self:getBody():getLinearVelocity()
    return vx
end

function Car:getMass()
    local mass = 0
    for i=1, #self.members do
        mass = mass + self.members[i].mass
    end
    return mass
end
function Car:start(filter)
    self:initPhysics(filter)
    self:initCollisionListener()
    self:removeEventListener("touch", self)
    self:addEventListener("touch", self)
    self._isStart = true
end

local _slideSpeed = 80 --1200
function Car:stop(callBack)
    local ctx = self.ctx
    self._isPower = false
    self._isStart = false
    self:setSpeed(0)
    _.each(self.members, function(child)
        -- child.angularDamping = 0.5
        child:setLinearVelocity( _slideSpeed, 0 )
    end)

    self:removeEventListener( "touch" )
    self._stopCheckTimer = ctx.timerMgr:setInterval(10, function()
        -- local vx, vy = self.body:getLinearVelocity()
        local vx, vy = self:getLinearSpeed()
        if _equalToZero(vx, 40) then
            ctx.timerMgr:clearTimer(self._stopCheckTimer)
            self:setLinearSpeed(0, 0)
            callBack()
        end
    end)
end

function Car:stopImmediately()
    self._isPower = false
    self:setSpeed(0)
    self._driveSpeed = 0
    _.each(self.members, function(child)
        child:setLinearVelocity( 0, 0 )
    end)
    if self.ctx and self.ctx.sndMgr and self.ctx.sndMgr.carMoveStop then
        self.ctx.sndMgr:carMoveStop()
    end
end

function Car:enterFrame(e)
end

function Car:clearPhysics()
    _.each(self._joints, function(joint)
        joint:removeSelf()
    end)
    _.each(self.members, function(elem)
        physics.removeBody(elem)
    end)
    _.each(self.attachments, function(obj)
        if obj.isParticle then
            obj:clearSelf()
        end
    end)
    if self.preview then
        self.preview:removeSelf()
        if self.preview.ghost then
            self.preview.ghost:removeSelf()
        end
    end
    Runtime:removeEventListener("enterFrame", self)
end

function Car:setCanJump(bool)
end

function Car:onRemove()
    self:sigClearAll()
    self:removeEventListener("touch", self)
end

return Car
