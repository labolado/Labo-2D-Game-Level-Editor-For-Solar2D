local pkgImport = GodotGlobal.pkgImport
local class = GodotGlobal.class
local clamp = GodotGlobal.clamp
local tostring = tostring

local _godotDir = "res://corona/"
local _baseDir = ""

local GodotSprite = pkgImport(..., "godot_sprite")
local GodotAnimatedSprite = class("GodotAnimatedSprite", GodotSprite)

local function _getPath(path)
	return path:gsub(_godotDir, _baseDir)
end

function GodotAnimatedSprite:initialize(info)
	self.textureType = info.texture_type

	GodotSprite.initialize(self, info)

	local options = info.sheets
	local sequenceData = info.animations

	if self.textureType ~= "sprite_sheet" then
		self.isPlaying = false
		-- self.numFrames = #options.frames
		self.frame = info.frame + 1
		self.sequence = info.current
		self.timeScale = info.speed_scale

		self._lastTime = -1
		self._timePast = 0
		self._frames = options.frames
		self._animations = sequenceData
		self._loopCount = 0
		-- self._currentAnim = nil
		-- self._currentAnimDelta = nil
		-- local currentFrame = self._frames[self.frame]

		self:setSequence(info.current)
		self._textureFill = {
			type = "image",
			filename = ""
		}
		self:setFrame(self.frame)
		if info.playing then
			self:play()
		end

		Runtime:addEventListener("enterFrame", self)
	end
end

function GodotAnimatedSprite:enterFrame(e)
	if self.parent == nil then
		return false
	end
	local ct = e.time
	if self._lastTime < 0 then
		self._lastTime = ct
	end
	local delta = ct - self._lastTime

	if self.isPlaying then
		self._timePast = self._timePast + delta
		if self._timePast >= self._currentAnimDelta then
			local frame = self.frame
			self:_setFrame(frame)
			frame = frame + 1
			if frame >= self.numFrames then
				self.frame = 1
				self._loopCount = self._loopCount + 1
				if self._currentAnim.loopCount > 0 and self._loopCount >= self._currentAnim.loopCount then
					self._loopCount = 0
					self.isPlaying = false
				end
			else
				self.frame = frame
			end
			self._timePast = 0
		end
	end

	self._lastTime = ct
	return true
end

function GodotAnimatedSprite:pause()
	if self.textureType == "sprite_sheet" then
		self:_super("pause")
	else
		self.isPlaying = false
	end
end

function GodotAnimatedSprite:play()
	if self.textureType == "sprite_sheet" then
		self:_super("play")
	else
		self.isPlaying = true
	end
end

function GodotAnimatedSprite:setSequence(name)
	if self.textureType == "sprite_sheet" then
		self:_super("setSequence", name)
	else
		local found
		for i=1, #self._animations do
			local anim =  self._animations[i]
			if anim.name == name then
				found = anim
				break
			end
		end
		if found then
			self.sequence = name
			self.numFrames = #found.frames
			self._currentAnim = found
			self._currentAnimDelta = found.time / self.numFrames
		end
	end
end

function GodotAnimatedSprite:_setFrame(frameIndex)
	local idx = clamp(frameIndex, 1, self.numFrames)
	local frame = self._currentAnim.frames[idx]
	local current = self._frames[frame]
	self._textureFill.filename = _getPath(current.res_path)
	self.width = current.width
	self.height = current.height
	self.fill = self._textureFill
	self.frame = idx
end

function GodotAnimatedSprite:setFrame(frameIndex)
	if self.textureType == "sprite_sheet" then
		self:_super("setFrame", frameIndex)
	else
		self:_setFrame(frameIndex)
	end
end

function GodotAnimatedSprite:removeSelf()
	Runtime:removeEventListener("enterFrame", self)
	GodotSprite.removeSelf(self)
end

return GodotAnimatedSprite
