local class = GodotGlobal.class
local pkgImport = GodotGlobal.pkgImport

local GodotSpriteBase = pkgImport(..., "godot_sprite_base")
local GodotSprite = class("GodotSprite", GodotSpriteBase)
local physics = require("physics")
local useColor = GodotGlobal.unpackHexColor
local unpack = unpack
local type = type
local mathAbs = math.abs
-- local _equalToZero = equalToZero
local RATE = 1
local RATE_SQUARE = RATE * RATE

local function _checkSign(value)
	if value > 0 then
		return true
	else
		return false
	end
end

local function _trangleArea(shape)
    local px, py = shape[1], shape[2]
    local qx, qy = shape[3], shape[4]
    local rx, ry = shape[5], shape[6]
    return mathAbs((qy - py) * (rx - qx) - (qx - px) * (ry - qy))
end

function GodotSprite:initialize(info)
	self.godotData = info
	self:setTexturePropertiesOnSprite(info)
end

function GodotSprite:setTexturePropertiesOnSprite(info)
	self.x = info.x
	self.y = info.y
	self.xScale = info.xScale
	self.yScale = info.yScale
	self.rotation = info.rotation
	self.name = info.name:match("[^;]+")
	self.lhUniqueName = self.name
	self.lhTag = info.tag or 0
	if type(info.visible) == "boolean" then
		self.isVisible = info.visible
	end
	self:setFillColor(useColor(info.color))
	if info.tag == 4 then
		self.lhTag = 6
	end
	if info.flip_h then
		self:scale(-1, 1)
	end
	if info.flip_v then
		self:scale(1, -1)
	end

	self.lhUserCustomInfo = info.custom_info
	self.physicProperties = info.physic_properties
end

function GodotSprite:createPhysicObjectForSprite(physicProperties)
	if type(physicProperties) == "table" and physicProperties.object_type ~= "nophysic" then
		local fixtures = physicProperties.fixtures
		local bodyFixtures = {}
		local n = 1
		local sx, sy = self.xScale, self.yScale
		local absSX, absSY = mathAbs(sx), mathAbs(sy)
		local positiveX = _checkSign(sx)
		local positiveY = _checkSign(sy)
		local needToReverse = ((not positiveX) and (not (positiveX == positiveY))) or ((not positiveY) and (not (positiveY == positiveX)))
		for i=1, #fixtures do
			local fixInfo = fixtures[i]
			local density = fixInfo.density * RATE_SQUARE
			local friction = fixInfo.friction
			local bounce = fixInfo.bounce
			local isSensor = fixInfo.is_sensor
			local collisionFilter = {
				categoryBits = fixInfo.category,
				maskBits 	 = fixInfo.mask,
				groupIndex 	 = fixInfo.group_index
			}
			if collisionFilter.maskBits == 65535 then
				collisionFilter.maskBits = 0x000f + 0x8000 -- 1, 2, 4, 8
			end

			if fixInfo.vertices then
				local indices = fixInfo.indices
				local vertices = fixInfo.vertices
				for j=1, #vertices, 2 do
					vertices[j] = vertices[j] * sx
					vertices[j + 1] = vertices[j + 1] * sy
				end
				for j=1, #indices, 3 do
					local a = indices[j] + 1
					local b = indices[j + 1] + 1
					local c = indices[j + 2] + 1
					local ay = 2 * a
					local ax = ay - 1
					local by = 2 * b
					local bx = by - 1
					local cy = 2 * c
					local cx = cy - 1
					local shape
					if needToReverse then
						shape = {vertices[cx], vertices[cy], vertices[bx], vertices[by], vertices[ax], vertices[ay]}
					else
						shape = {vertices[ax], vertices[ay], vertices[bx], vertices[by], vertices[cx], vertices[cy]}
					end
					-- if not _equalToZero(_trangleArea(shape), 8) then
						local fixture = {
							density = density,
							friction = friction,
							bounce = bounce,
							isSensor = isSensor,
							shape = shape,
							filter = collisionFilter
						}
						bodyFixtures[n] = fixture
						n = n + 1
					-- end
				end
			elseif fixInfo.box then
				local box = fixInfo.box
				local newBox = {
					x = box.x * sx,
					y = box.y * sy,
					halfWidth = box.halfWidth * absSX,
					halfHeight = box.halfHeight * absSY
				}
				bodyFixtures[n] = {
					density = density,
					friction = friction,
					bounce = bounce,
					isSensor = isSensor,
					box = newBox,
					filter = collisionFilter
				}
				n = n + 1
			elseif fixInfo.radius then
				bodyFixtures[n] = {
					density = density,
					friction = friction,
					bounce = bounce,
					isSensor = isSensor,
					radius = fixInfo.radius * absSX,
					filter = collisionFilter
				}
				n = n + 1
			end
		end

		physics.addBody(self, physicProperties.object_type, unpack(bodyFixtures))

		self.isFixedRotation = physicProperties.fixed_roation
		self.isBullet = physicProperties.is_bullet
		self.isSleepingAllowed = physicProperties.can_sleep
		self.linearDamping = physicProperties.linear_damping
		self.angularDamping = physicProperties.angular_damping
		self.angularVelocity = physicProperties.angular_velocity
		self.gravityScale = physicProperties.gravity_scale
		local velocity = physicProperties.linear_velocity
		self:setLinearVelocity(velocity[1], velocity[2])
	end
end

function GodotSprite:startPathMovement()
	if self.godotPathFollow then
		self.godotPathFollow:startPathMovement()
	end
end

function GodotSprite:stopPathMovement()
	if self.godotPathFollow then
		self.godotPathFollow:stopPathMovement()
	end
end

function GodotSprite:__tostring()
	return self._uniqueTableId
end

function GodotSprite:removeSelf()
	if self.godotPathFollow then
		self.godotPathFollow:clearSelf()
		self.godotPathFollow = nil
	end
	self:_super("removeSelf")
end

return GodotSprite
