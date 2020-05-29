-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Vector = require("lib.thirdparty.polygon.vector-light")
local PhysicsRope = class("PhysicsRope")
local physics = require("physics")
local GodotSprite = require("godot.godot_loader").GodotSprite

local _point = Vector.lerp
local _lengthOf = Vector.dist
local _angleOf = Vector.angle
local _mathCeil = math.ceil

local _default = {
	density = 5,
	bounce = 0,
	friction = 0.2,
	groupIndex = -10
}

function PhysicsRope:initialize(startObject, endObjects, textureFile, options)
	options = _.extend(_.clone(_default), options)

	local parent = startObject.parent
	local index = display.groupIndexOf(parent, startObject)

	local wh
	local createTextureMethod
	local createType = 0

	if type(textureFile) == "string" then
		wh = Image:getImageInfo(textureFile)
		createTextureMethod = function()
			return Image:newImageRect(textureFile)
		end
	elseif type(textureFile) == "table" then
		createType = 1
		wh = {textureFile.width * textureFile.xScale, textureFile.height * textureFile.yScale}
		createTextureMethod = function()
			-- local spr = LevelHelperLoader:createSpriteFromSHDocument(textureFile.shSpriteName, textureFile.shSheetName, textureFile.shSceneName)
			-- local spr = LHSprite:spriteWithDictionary(textureFile.spriteInfo)
			-- spr:createPhysicObjectForSprite(spr.spriteInfo)
			local spr = GodotSprite:new(textureFile.godotData)
			-- spr:createPhysicObjectForSprite(spr.physicProperties)
			spr:translate(-spr.x, -spr.y)
			spr:rotate(-spr.rotation)
			spr:scale(1 / spr.xScale, 1 / spr.yScale)
			spr.width = wh[1]
			spr.height = wh[2]
			spr.bodyType = "dynamic"
			spr.isVisible = true
			-- _DUMP(spr.lhFixtures[1].fixtureShape[1])
			return spr
		end
	end

	local segments = {}
	segments[#segments + 1] = startObject
	local lengthToStart = 0
	local startNode = startObject
	for n=1, #endObjects do
		local endNode = endObjects[n]
		local sx, sy = startNode.x, startNode.y
		local ex, ey = endNode.x, endNode.y
		local length = _lengthOf(sx, sy, ex, ey)
		local angle = _angleOf(ex - sx, ey - sy)
		local count = _mathCeil(length / wh[1])
		local delta = length / count

		for i=1, count do
			local t = (i - 0.5) / count
			local x, y = _point(t, sx, sy, ex, ey)
			-- local seg = Image:newImageRect(textureFile)
			local seg = createTextureMethod(textureFile)
			seg:rotate(angle)
			seg:translate(x, y)
			parent:insert(index, seg)

			local xScale = delta / wh[1]
			if createType == 0 then
				physics.addBody(seg, "dynamic", {
					filter = {groupIndex = options.groupIndex},
					density = options.density,
					bounce = options.bounce,
					friction = options.friction
				})
				_D(options.density)
			else
				seg:scale(xScale, xScale)
				seg:createPhysicObjectForSprite(seg.physicProperties)
				seg:scale(1 / seg.xScale, 1 / seg.yScale)
				seg.width = wh[1]
				seg.height = wh[2]
				seg.bodyType = "dynamic"
				seg.isVisible = true
				seg.isSensor = false
			end
			seg.height = seg.height * xScale
			seg.width = delta + 8
			-- seg:scale((seg.width + 8) / seg.width, 1)
			-- seg.width = seg.width + 8
			seg.ropeLength = delta
			seg.lengthToStart = lengthToStart
			segments[#segments + 1] = seg

			lengthToStart = lengthToStart + delta
			startNode = endNode
		end
	end

	local lengthToEnd = 0
	for n=#segments, 2, -1 do
		local seg = segments[n]
		lengthToEnd = lengthToEnd + seg.ropeLength
		seg.lengthToEnd = lengthToEnd
	end

	segments[#segments + 1] = endObjects[#endObjects]
	self.segments = segments
	self.ropeJoints = {}
	self.pivotJoints = {}

	-- self.delta = delta
	self:createBridgeJoints()
end

function PhysicsRope:createBridgeJoints()
	local segments = self.segments
	-- local delta = self.delta
	local startNode = segments[1]
	local count = #segments
	local endNode = segments[count]
	for i=2, count - 1 do
		local seg1 = segments[i - 1]
		local seg2 = segments[i]
		local delta = seg2.ropeLength
		local lengthToStart = seg2.lengthToStart
		local lengthToEnd = seg2.lengthToEnd
		local rJoint = physics.newJoint("rope", startNode, seg2, 0, 0, -delta * 0.5, 0)
		-- rJoint.maxLength = (i - 2) * delta
		rJoint.maxLength = lengthToStart
		_.push(self.ropeJoints, rJoint)
		rJoint = physics.newJoint("rope", endNode, seg2, 0, 0, delta * 0.5, 0)
		-- rJoint.maxLength = (count - i - 1) * delta
		rJoint.maxLength = lengthToEnd
		_.push(self.ropeJoints, rJoint)

		local anchorX, anchorY = seg2:localToContent(-delta * 0.5, 0)
		local pJoint = physics.newJoint("pivot", seg1, seg2, anchorX, anchorY)
		_.push(self.pivotJoints, pJoint)
		pJoint.isLimitEnabled = true
			--pJoint:setRotationLimits( -2, 2 )

		if i == count - 1 then
			anchorX, anchorY = seg2:localToContent(delta * 0.5, 0)
			pJoint = physics.newJoint("pivot", seg2, endNode, anchorX, anchorY)
			-- pJoint.isLimitEnabled = true
			-- pJoint:setRotationLimits( -2, 2 )
			-- pJoint.isMotorEnabled = true
			-- pJoint.maxMotorTorque = 10000
			_.push(self.pivotJoints, pJoint)
		end
	end
end

function PhysicsRope:removeSelf()
	for i=1, #self.ropeJoints do
		self.ropeJoints[i]:removeSelf()
	end
	for i=1, #self.pivotJoints do
		self.pivotJoints[i]:removeSelf()
	end
	-- for i=1, #self.segments do
	-- 	self.segments[i]:removeSelf()
	-- end
	for k, v in pairs(self) do
		self[k] = nil
	end
end

return PhysicsRope
