-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


--该类用于直接设定坐标移动一个物理对象

local T = {}

function T:new(physicObject, opts)
    local self = {}
    opts = opts or {}
    opts.maxForce =  opts.maxForce or 9999999

    setmetatable(self, {__index = T} )
    local x = opts.x or physicObject.x
    local y = opts.y or physicObject.y
    self.initPos = {x = x, y = y}
    self.physicObject = physicObject
    --Log:debug(self.physicObject.mdrag_id)
    self.touchJoint = physics.newJoint("touch", physicObject, x, y)
    -- self.touchJoint.maxForce = opts.maxForce
    self.touchJoint.maxForce = opts.maxForce
    -- self.touchJoint.frequency = 30
    -- self.touchJoint.dampingRatio = 0

    return self
end

function T:getObject()
    return self.physicObject
end

function T:pause()
    self.touchJoint.maxForce = 0
end

function T:resume()
    self.touchJoint.maxForce = 9999999
end

function T:translate(x, y)
    self.touchJoint:setTarget(self.initPos.x + x, self.initPos.y +  y)
end

function T:translateTo(x, y)
    self.touchJoint:setTarget(x, y)
end

function T:removeSelf()

    if self.touchJoint ~= nil then
        self.touchJoint:removeSelf()
        self.touchJoint = nil
    end
    self.physicObject =  nil

end

return T
