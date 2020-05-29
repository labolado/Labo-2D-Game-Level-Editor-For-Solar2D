local Vec = GodotGlobal.Vector
local pkgImport = GodotGlobal.pkgImport
local class = GodotGlobal.class

local Curve = pkgImport(..., "curve")
local GodotPathFollow = class("GodotPathFollow")

local clamp = GodotGlobal.clamp
local fmod = math.fmod
local normalize = Vec.normalize
local angle = Vec.angle

local function pointEqual(a, b)
	return a[1] == b[1] and a[2] == b[2]
end

local function fposmod(px, py)
	local value = fmod(px, py)
	if (value < 0 and py > 0 ) or (value > 0 and py < 0) then
		value = value + py
	end
	return value
end

function GodotPathFollow:initialize(info, curve)
	self.name = info.name
	self.lhUserCustomInfo = info.custom_info
	self.version = info.version
	self.timeMax = info.time
	self.startAtLaunch = info.startAtLaunch
	self.relativeMove = info.relativeMove
	self.startAtEndPoint = info.startAtEndPoint
	self.cyclicMotion = info.cyclicMotion
	self.restartAtOtherEnd = info.restartAtOtherEnd
	self.flipHorizontalAtEnd = info.flipX
	self.flipVerticleAtEnd = info.flipY
	self.orientation = info.orientation
	self.cubicInterp = info.cubicInterp
	-- self.cubicInterp = false
	self.rotateAlonePath = info.rotate
	self.isStarted = false

	self._pathPosX = info.x
	self._pathPosY = info.y

	if curve then
		self.curve = curve
	else
		self.curve = Curve:new(info)
		self.curve:bake()
	end

	self._bakedMaxOfs = self.curve:getBakedLength()
	self.lookahead = info.lookahead / self._bakedMaxOfs

	-- if self.version == 1 then
	-- 	self.rotateAlonePath = self.orientation ~= 0
	-- end

	if self.startAtEndPoint then
		self._currentDir = -1
	else
		self._currentDir = 1
	end

	self._timePast = -1
	self._time = 0
	self._pathFirstPos = self:interpolateBaked(0)
	self._initAngle = 0

	self._targetOffset = nil

	-- self._debugLine = display.newLine(self._pathFirstPos)

	-- if self.startAtLaunch then
	-- 	self:startPathMovement()
	-- end
end

function GodotPathFollow:setTarget(target)
	self.target = target
	self._initAngle = target.rotation + 90
end

function GodotPathFollow:interpolateBaked(offset)
	if self._currentDir == 1 then
		return self.curve:interpolateBaked(offset * self._bakedMaxOfs, self.cubicInterp)
	else
		return self.curve:interpolateBaked((1 - offset) * self._bakedMaxOfs, self.cubicInterp)
	end
end

function GodotPathFollow:isCurveClosed()
	return self.curve:isClosed()
end

function GodotPathFollow:enterFrame(e)
	if self.isStarted and self.target ~= nil then
		local target = self.target
		local time = self._time

		local currentTime = e.time
		if self._timePast < 0 then
			self._timePast = currentTime
		end
		local delta = (currentTime - self._timePast) * 0.001
		time = time + delta
		local ratio = time / self.timeMax

		local pos = self:interpolateBaked(ratio)

		if self.relativeMove then
			local x = pos[1] + self._targetOffset[1] - target.x
			local y = pos[2] + self._targetOffset[2] - target.y
			target:translate(x, y)
			-- local px, py = target:localToContent(0, 0)
			-- local circle = display.newCircle(px, py, 2)
		else
			local x = pos[1] - target.x
			local y = pos[2] - target.y
			target:translate(x, y)
			-- local circle = display.newCircle(pos[1] + _CX, pos[2] + _CY, 2)
		end

		if self.cyclicMotion then
			if ratio > 1.0 then
				time = fmod(time, self.timeMax)

				if self.restartAtOtherEnd then
					time = 0
					self._currentDir = -self._currentDir
					-- self._pathFirstPos = self:interpolateBaked(0)
					-- self._targetOffset[1] = self.target.x - self._pathFirstPos[1]
					-- self._targetOffset[2] = self.target.y - self._pathFirstPos[2]
				end
				if self.flipHorizontalAtEnd then
					target:scale(-1, 1)
				end

				if self.flipVerticleAtEnd then
					target:scale(1, -1)
				end
			end
		end

		if self.rotateAlonePath then
			local offset = ratio * self._bakedMaxOfs
			if self.cyclicMotion then
				offset = fposmod(offset, self._bakedMaxOfs)
			else
				offset = clamp(offset, 0, self._bakedMaxOfs)
			end
			local ahead = offset + self.lookahead

			if self.cyclicMotion and ahead >= self._bakedMaxOfs then
				if self:isCurveClosed() then
					ahead = fmod(ahead, self._bakedMaxOfs)
				end
			end

			local aheadPos = self:interpolateBaked(ahead / self._bakedMaxOfs)
			local tangentToCurveX, tangentToCurveY
			if pointEqual(aheadPos, pos) then
				ahead = offset - self.lookahead
				aheadPos = self:interpolateBaked(ahead / self._bakedMaxOfs)
				tangentToCurveX, tangentToCurveY = normalize(aheadPos[1], aheadPos[2])
			else
				tangentToCurveX, tangentToCurveY = normalize(aheadPos[1] - pos[1], aheadPos[2] - pos[2])
			end

			target.rotation = self._initAngle + angle(tangentToCurveX, tangentToCurveY)
		end

		-- print(time, ratio, delta)
		self._time = time
		self._timePast = currentTime
	end
end

function GodotPathFollow:stopPathMovement()
	if self.isStarted then
		self.isStarted = false
		Runtime:removeEventListener("enterFrame", self)
	end
end

function GodotPathFollow:startPathMovement()
	if not self.isStarted then
		self.isStarted = true
		if self.target and self._targetOffset == nil then
			self._targetOffset = {
				self.target.x - self._pathFirstPos[1],
				self.target.y - self._pathFirstPos[2]
			}
		end
		Runtime:removeEventListener("enterFrame", self)
		Runtime:addEventListener("enterFrame", self)
	end
end

function GodotPathFollow:clearSelf()
	self.target = nil
	self.isStarted = false
	Runtime:removeEventListener("enterFrame", self)
end

return GodotPathFollow
