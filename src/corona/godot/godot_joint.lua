local class = GodotGlobal.class
local _ = GodotGlobal._
local physics = require("physics")
local GodotJoint = class("GodotJoint")

local _isDebug = false
local _clone = _.clone
local _anchorOffset = {x = 0, y = 0}

local function createPivotJoint(self, a, b, info)
	local anchorA = info.anchor_a
	if _isDebug then
		display.newCircle(a.parent, a.x + anchorA[1], a.y + anchorA[2], 8):setFillColor(1, 0, 0, 1)
	end
	local joint = physics.newJoint("pivot", a, b, a.x + anchorA[1], a.y + anchorA[2])
	if joint then
		joint.isMotorEnabled = info.isMotorEnabled
		joint.maxMotorTorque = info.maxMotorTorque
		joint.motorSpeed = info.motorSpeed
		joint.isLimitEnabled = info.isLimitEnabled
		joint:setRotationLimits(info.rotationLimit[1], info.rotationLimit[2])
		self.joint = joint
	end
end

local function createWeldJoint(self, a, b, info)
	local anchorA = info.anchor_a
	if _isDebug then
		display.newCircle(a.parent, a.x + anchorA[1], a.y + anchorA[2], 8):setFillColor(1, 0, 0, 1)
	end
	local joint = physics.newJoint("weld", a, b, a.x + anchorA[1], a.y + anchorA[2])
	print(joint, a.name, b.name, info.name)
	if joint then
		if info.dampingRatio ~= 0 or info.frequency ~= 0 then
			joint.dampingRatio = info.dampingRatio
			joint.frequency = info.frequency
		end
		self.joint = joint
	end
end

local function createWheelJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local axis = info.axis
	local joint = physics.newJoint("wheel", a, b, a.x + anchorA[1], a.y + anchorA[2], axis[1], axis[2])
	if joint then
		joint.springDampingRatio = info.springDampingRatio
		joint.springFrequency = info.springFrequency
		joint.isMotorEnabled = info.isMotorEnabled
		joint.maxMotorTorque = info.maxMotorTorque
		joint.motorSpeed = info.motorSpeed
		self.joint = joint
	end
end

local function createPistonJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local axis = info.axis
	local joint = physics.newJoint("piston", a, b, a.x + anchorA[1], a.y + anchorA[2], axis[1], axis[2])
	if joint then
		joint.isMotorEnabled = info.isMotorEnabled
		joint.maxMotorForce = info.maxMotorForce
		joint.motorSpeed = info.motorSpeed
		joint.isLimitEnabled = info.isLimitEnabled
		joint:setLimits(info.limit[1], info.limit[2])
		self.joint = joint
	end
end

local function createRopeJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local anchorB = info.anchor_b
	-- local joint = physics.newJoint( "rope", bodyA, bodyB, offsetA_x, offsetA_y, offsetB_x, offsetB_y )
	local joint = physics.newJoint("rope", a, b, anchorA[1], anchorA[2], anchorB[1], anchorB[2])
	if joint then
		if info.maxLength > 1 then
			joint.maxLength = info.maxLength
		end
		self.joint = joint
	end
end

local function createDistanceJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local anchorB = info.anchor_b
	local joint = physics.newJoint("distance", a, b,
									a.x + anchorA[1],
									a.y + anchorA[2],
									b.x + anchorB[1],
									b.y + anchorB[2])
	if joint then
		joint.dampingRatio = info.dampingRatio
		joint.frequency = info.frequency
		self.joint = joint
	end
end

local function createFrictionJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local joint = physics.newJoint("friction", a, b, a.x + anchorA[1], a.y + anchorA[2])
	if joint then
		joint.maxForce = info.maxForce
		joint.maxTorque = info.maxTorque
		self.joint = joint
	end
end

local function createPulleyJoint(self, a, b, info)
	local anchorA = info.anchor_a
	local statA = info.rope_anchor_a
	local statB = info.rope_anchor_b
	local bodyA = info.anchor_a
	local bodyB = info.anchor_b
	local joint = physics.newJoint("pulley", a, b,
									a.x + statA[1], a.y + statA[2],
									b.x + statB[1], b.y + statB[2],
									a.x + bodyA[1], a.y + bodyA[2],
									b.x + bodyB[1], b.y + bodyB[2],
									info.ratio)
	self.joint = joint
end

local function createGearJoint(self, loader, info)
	local a = loader:spriteWithUniqueName(info.a)
	local b = loader:spriteWithUniqueName(info.b)
	local joint1 = loader:jointWithUniqueName(info.joint_a)
	local joint2 = loader:jointWithUniqueName(info.joint_b)
	local joint = physics.newJoint("gear", a, b, joint1, joint2, info.ratio)
	self.joint = joint
end

function GodotJoint:initialize(info, loader)
	self.name = info.name
	self.lhUniqueName = info.name
	if info.type == "gear" then
		createGearJoint(self, loader, info)
	else
		local a = loader:spriteWithUniqueName(info.a)
		local b = loader:spriteWithUniqueName(info.b)
		local newInfo = info
		if a.anchorOffset ~= nil or b.anchorOffset ~= nil then
			local anchorOffsetA = a.anchorOffset or _anchorOffset
			local anchorOffsetB = b.anchorOffset or _anchorOffset
			newInfo = _clone(info)
			newInfo.anchor_a = _clone(info.anchor_a)
			newInfo.anchor_b = _clone(info.anchor_b)
			newInfo.anchor_a[1] = newInfo.anchor_a[1] - anchorOffsetA.x
			newInfo.anchor_a[2] = newInfo.anchor_a[2] - anchorOffsetA.y
			newInfo.anchor_b[1] = newInfo.anchor_b[1] - anchorOffsetB.x
			newInfo.anchor_b[2] = newInfo.anchor_b[2] - anchorOffsetB.y
		end
		if newInfo.type == "pivot" then
			createPivotJoint(self, a, b, newInfo)
		elseif newInfo.type == "weld" then
			createWeldJoint(self, a, b, newInfo)
		elseif newInfo.type == "wheel" then
			createWheelJoint(self, a, b, newInfo)
		elseif newInfo.type == "rope" then
			createRopeJoint(self, a, b, newInfo)
		elseif newInfo.type == "distance" then
			createDistanceJoint(self, a, b, newInfo)
		elseif newInfo.type == "piston" then
			createPistonJoint(self, a, b, newInfo)
		elseif newInfo.type == "friction" then
			createFrictionJoint(self, a, b, newInfo)
		elseif newInfo.type == "pulley" then
			if newInfo ~= info then
				local anchorOffsetA = a.anchorOffset or _anchorOffset
				local anchorOffsetB = b.anchorOffset or _anchorOffset
				newInfo.rope_anchor_a = _clone(info.rope_anchor_a)
				newInfo.rope_anchor_b = _clone(info.rope_anchor_b)
				newInfo.rope_anchor_a[1] = newInfo.rope_anchor_a[1] - anchorOffsetA.x
				newInfo.rope_anchor_a[2] = newInfo.rope_anchor_a[2] - anchorOffsetA.y
				newInfo.rope_anchor_b[1] = newInfo.rope_anchor_b[1] - anchorOffsetB.x
				newInfo.rope_anchor_b[2] = newInfo.rope_anchor_b[2] - anchorOffsetB.y
			end
			createPulleyJoint(self, a, b, newInfo)
		end
	end
end

function GodotJoint:getCoronaJoint()
	return self.joint
end

function GodotJoint:removeSelf()
	if self.joint then
		self.joint:removeSelf()
		self.joint = nil
	end
end

return GodotJoint
