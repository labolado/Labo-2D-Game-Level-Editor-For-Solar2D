-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Vector = require("lib.thirdparty.polygon.vector-light")
local FakeRope = class("FakeRope")
local physics = require("physics")
local GodotSprite = require("godot.godot_loader").GodotSprite

local checkBoxIntersection = checkBoxIntersection
local math_ceil = math.ceil
local math_modf = math.modf
local _lengthOf = Vector.dist
local _angleOf = Vector.angle
local _point = Vector.lerp

function FakeRope:createFromImage(textureFile)
	return Image:newImageRect(textureFile)
end

function FakeRope:createFromSprite(textureFile)
	-- local spr = LHSprite:spriteWithDictionary(textureFile.spriteInfo)
	local spr = GodotSprite:new(textureFile.godotData)
	spr:translate(-spr.x, -spr.y)
	spr:rotate(-spr.rotation)
	spr:scale(1 / spr.xScale, 1 / spr.yScale)
	return spr
end

function FakeRope:initialize(startObject, endObjects, textureFile, options)
	-- options = _.extend(_.clone(_default), options)
	local parent = startObject.parent
	local index = display.groupIndexOf(parent, startObject)
	local wh
	local createTextureMethod

	if type(textureFile) == "string" then
		wh = Image:getImageInfo(textureFile)
		createTextureMethod = self.createFromImage
	elseif type(textureFile) == "table" then
		wh = {textureFile.width * textureFile.xScale, textureFile.height * textureFile.yScale}
		createTextureMethod = self.createFromSprite
	end

	local segmentsDict = {}
	for i=1, #endObjects do
		-- local key = endObjects[i]
		segmentsDict[i] = {}
	end

	self.wh = wh
	self.parent = parent
	self.insertIndex = index
	self.textureFile = textureFile
	self.startObject = startObject
	self.endObjects = endObjects
	self.objects = _.push({}, startObject, unpack(endObjects))
	self.isStarted = false
	self.isPaused = false
	self.createTextureMethod = createTextureMethod
	self.segmentsDict = segmentsDict
end

function FakeRope:draw(parent, startObject, endObjects, textureFile)
	local wh = self.wh
	local segmentsDict = self.segmentsDict
	-- if segments then
	-- 	for i=1, #segments do
	-- 		segments[i]:removeSelf()
	-- 	end
	-- end
	-- segments = {}
	local createTextureMethod = self.createTextureMethod
	local index = self.insertIndex
	local startNode = startObject
	for n=1, #endObjects do
		local endNode = endObjects[n]
		local segments = segmentsDict[n]
		local sx, sy = startNode.x, startNode.y
		local ex, ey = endNode.x, endNode.y
		local length = _lengthOf(sx, sy, ex, ey)
		if length > 0 then
			local angle = _angleOf(ex - sx, ey - sy)
			local num = length / wh[1]
			-- local count = math_ceil(num)
			local integralPart, fractionalPart = math_modf(num)
			-- local delta = length / count
			local hasFractionalPart = fractionalPart ~= 0
			local count = hasFractionalPart and (integralPart + 1)  or integralPart
			local delta = wh[1]

			local currentCount = #segments
			if count < currentCount then
				-- _D("before", count, currentCount)
				for i=currentCount, count+1, -1 do
					local obj = segments[i]
					table.remove(segments, i)
					obj:removeSelf()
				end
			end
			currentCount = #segments
			-- _D("after", count, currentCount)

			for i=1, count do
				local t = (i - 0.5) / num
				if hasFractionalPart and i == count then
					t = (num - fractionalPart*0.5) / num
				end
				local x, y = _point(t, sx, sy, ex, ey)
				local seg
				if i > currentCount then
					seg = createTextureMethod(self, textureFile)
					parent:insert(index, seg)
					segments[#segments + 1] = seg
				else
					seg = segments[i]
				end
				seg:rotate(angle - seg.rotation)
				seg:translate(x - seg.x, y - seg.y)
				seg.isVisible = true
				seg.width = wh[1] + 8
				seg.height = wh[2]
				if hasFractionalPart and i == count then
					seg.width = seg.width * fractionalPart
				end
				startNode = endNode
			end
		end
	end
	-- self.segments = segments
end

function FakeRope:enterFrame(e)
	self.isPaused = self:checkEnteredScreen()
	if not self.isPaused then
		self:draw(self.parent, self.startObject, self.endObjects, self.textureFile)
		-- _D(e.time)
	end
end

function FakeRope:checkEnteredScreen()
	local objects = self.objects
	local result = true
	for i=1, #objects do
		local obj =objects[i]
		if checkBoxIntersection(obj.contentBounds, SCREEN_BOUNDS) then
			result = false
			break
		end
	end
	return result
end

function FakeRope:startUpdate()
	if not self.isStarted then
		self.isStarted = true
		Runtime:addEventListener("enterFrame", self)
	end
end

function FakeRope:stopUpdate()
	if self.isStarted then
		self.isStarted = false
		Runtime:removeEventListener("enterFrame", self)
	end
end

function FakeRope:removeSelf()
	-- for i=1, #self.segments do
	-- 	self.segments[i]:removeSelf()
	-- end
	local segmentsDict = self.segmentsDict
	if segmentsDict then
		for key, t in pairs(segmentsDict) do
			for i=1, #t do
				t[i]:removeSelf()
			end
			-- segmentsDict[key] = nil
		end
		self.segmentsDict = nil
	end
	self:stopUpdate()
	for k, v in pairs(self) do
		self[k] = nil
	end
end

return FakeRope
