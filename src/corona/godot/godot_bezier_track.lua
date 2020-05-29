local class = GodotGlobal.class
local _UC = GodotGlobal.unpackHexColor

local GodotBezierTrack = class("GodotBezierTrack", function()
	local obj = display.newGroup()
	obj._uniqueTableId = tostring(obj)
	return obj
end)

function GodotBezierTrack.static.new(self, ...)
	local instance = self:allocate()
	instance:addEventListener("finalize")
	instance:initialize(...)
	return instance
end

function GodotBezierTrack:finalize(e)
	self:onRemove()
    for k,v in pairs(self) do
    	if k:find("^_") == nil then
	    	self[k] = nil
	    end
    end
end

function GodotBezierTrack:__tostring()
	return self._uniqueTableId
end

function GodotBezierTrack:onRemove()
end

local Shader = GodotGlobal.Shader
local _godotDir = "res://corona/"
-- local _baseDir = APP.config.game.roadAssetsDir
local _baseDir = ""
local _centering = display.resetGroupCenter
local _default_options = GodotGlobal.DEFAULT_OPTIONS
local _D = GodotGlobal.log

local Vec = GodotGlobal.Vector
local pointOnCurve
local calculateEvenlySpacedPoints
local unpack = unpack
local type = type
local mathAbs = math.abs
local _equalToZero = GodotGlobal.equalToZero

local function log2(value)
	return math.log(value) / math.log(2)
end
local function _isPowerOfTwo(value)
	return (math.ceil(log2(value)) == math.floor(log2(value)))
end

local function _trangleArea(shape)
    local px, py = shape[1], shape[2]
    local qx, qy = shape[3], shape[4]
    local rx, ry = shape[5], shape[6]
    return mathAbs((qy - py) * (rx - qx) - (qx - px) * (ry - qy))
end

local function _getBounds(points)
	local xMin, yMin, xMax, yMax = math.huge, math.huge, -math.huge, -math.huge
	local min = math.min
	local max = math.max
	for i=1, #points do
		local x, y = points[i][1], points[i][2]
		xMin = min(xMin, x)
		xMax = max(xMax, x)
		yMin = min(yMin, y)
		yMax = max(yMax, y)
	end
	return {
		xMin = xMin,
		yMin = yMin,
		xMax = xMax,
		yMax = yMax
	}
end

local function _loadRepeatTexture(filename, name, baseDir)
	name = name or "repeat"
	display.setDefault( "textureWrapX", name )
	display.setDefault( "textureWrapY", name )
	-- display.setDefault( "minTextureFilter", "nearest" )
	-- display.setDefault( "minTextureFilter", "linear" )
	local tex = graphics.newTexture({type="image", filename=filename, baseDir=baseDir or system.ResourceDirectory})
	-- display.setDefault( "minTextureFilter", "linear" )
	display.setDefault( "textureWrapX", "clampToEdge" )
	display.setDefault( "textureWrapY", "clampToEdge" )
	return tex
end

local function _groundChangeMaterial(self, mat)
	-- _DUMP("!-> GodotBezierTrack ground: ", mat)
	-- local ratio = 1 -- RATIO
	if self.textureName ~= mat.filename then
		local oldTexture = self.texture
		-- local tx = mat.tiling[1]
		-- local ty = mat.tiling[2]
		-- local tx = self.width / mat.width
		-- local ty = self.height / mat.height
		local tx = 1
		local ty = 1
		if mat.isPowerOfTwo then
			local newTex = _loadRepeatTexture(mat.filename, "repeat")
			self.fill = {type = "image", filename = newTex.filename, baseDir = newTex.baseDir}
			self.fill.scaleX = 1 / tx
			self.fill.scaleY = 1 / ty
			-- self.fill.rotation = self.tilingRotation
			self.texture = newTex
		else
			local newTex = _loadRepeatTexture(mat.filename, "clampToEdge")
			self.fill = {type = "image", filename = newTex.filename, baseDir = newTex.baseDir}
			self.fill.effect = Shader.filters.tiling
			-- local rotation = self.tilingRotation
			self.fill.scaleX = 1 / tx
			self.fill.scaleY = 1 / ty
			-- self.fill.rotation = rotation
			self.texture = newTex
		end
		-- self.fill.x = 0
		-- self.fill.y = -0.5
		self.textureName = mat.filename
		if oldTexture and type(oldTexture.releaseSelf) == "function" then
			oldTexture:releaseSelf()
		end
	end
end

local function _trackChangeMaterial(self, mat)
	-- _DUMP("!-> GodotBezierTrack track: ", mat)
	if self.textureName ~= mat.filename then
		local oldTexture = self.texture
		-- local ratio = mat.height / self.roadHeight
		-- local tilingX = self.numPoints * self.spacing * ratio / mat.width
		if mat.isPowerOfTwo then
			local newTex = _loadRepeatTexture(mat.filename, "repeat")
			self.fill = {type = "image", filename = newTex.filename, baseDir = newTex.baseDir}
			-- self.fill.scaleX = 1 / tilingX
			self.fill.scaleX = 1
			self.fill.scaleY = 1
			self.texture = newTex
		else
			local newTex = _loadRepeatTexture(mat.filename, "clampToEdge")
			self.fill = {type = "image", filename = newTex.filename, baseDir = newTex.baseDir}
			self.fill.effect = Shader.filters.tiling
			-- self.fill.effect.tilingX = tilingX
			-- self.fill.effect.tilingY = 1
			self.fill.scaleX = 1
			self.fill.scaleY = 1
			self.texture = newTex
		end
		self.textureName = mat.filename
		if oldTexture and type(oldTexture.releaseSelf) == "function" then
			oldTexture:releaseSelf()
		end
	end
end

pointOnCurve = function(p1, p2, p3, p4, t)
    local var1 = 1 - t
    local var2 = var1 * var1 * var1
    local var3 = t * t * t
    local x = var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x
    local y = var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y

	return x, y
end

calculateEvenlySpacedPoints = function(curves, spacing, resolution) -- keep original points
	resolution = resolution or 1
	local c = curves[1]
	-- local p = c:pointForKey("StartPoint")
	local evenlySpacedPoints = {}
	evenlySpacedPoints[1] = c[1]
	evenlySpacedPoints[2] = c[2]
	local prevPointX, prevPointY = evenlySpacedPoints[1], evenlySpacedPoints[2]
	local dstSinceLastEvenPoint = 0
	local len = #curves - 1
	local dist = Vec.dist
	local normalize = Vec.normalize
	local ceil = math.ceil
	for i= 1, len do
		local curve = curves[i]
		local curve2 = curves[i + 1]
		local p1 = {x = curve[1], y = curve[2]}
		local p2 = {x = p1.x + curve[5], y = p1.y + curve[6]}
		local p4 = {x = curve2[1], y = curve2[2]}
		local p3 = {x = p4.x + curve2[3], y = p4.y + curve2[4]}

		local controlNetLength = dist(p1.x, p1.y, p2.x, p2.y) + dist(p2.x, p2.y, p3.x, p3.y) + dist(p3.x, p3.y, p4.x, p4.y)
		local estimatedCurveLength = dist(p1.x, p1.y, p4.x, p4.y) + controlNetLength * 0.5
		local divisions = ceil(estimatedCurveLength * resolution)
		local t = 0
		local step = 1 / divisions
		while t < 1 do
			t = t + step
			-- local pointOnCurveX, pointOnCurveY = _quadraticBezier(p1x, p1y, p2x, p2y, p3x, p3y, t)
			local pointOnCurveX, pointOnCurveY = pointOnCurve(p1, p2, p3, p4, t)
			dstSinceLastEvenPoint = dstSinceLastEvenPoint + dist(prevPointX, prevPointY, pointOnCurveX, pointOnCurveY)

			if t >= 1 then
				dstSinceLastEvenPoint = 0
				evenlySpacedPoints[#evenlySpacedPoints + 1] = p4.x
				evenlySpacedPoints[#evenlySpacedPoints + 1] = p4.y
				prevPointX, prevPointY = p4.x, p4.y
			else
				while dstSinceLastEvenPoint >= spacing do
					local overshootDst = dstSinceLastEvenPoint - spacing
					local normalX, normalY = normalize(prevPointX - pointOnCurveX, prevPointY - pointOnCurveY)
					local newPointX = pointOnCurveX + normalX * overshootDst
					local newPointY = pointOnCurveY + normalY * overshootDst
					evenlySpacedPoints[#evenlySpacedPoints + 1] = newPointX
					evenlySpacedPoints[#evenlySpacedPoints + 1] = newPointY
					dstSinceLastEvenPoint = overshootDst
					prevPointX, prevPointY = newPointX, newPointY
				end
			end

			prevPointX, prevPointY = pointOnCurveX, pointOnCurveY
		end
		if i == len then
			if dstSinceLastEvenPoint > 0 then
				evenlySpacedPoints[#evenlySpacedPoints + 1] = p4.x
				evenlySpacedPoints[#evenlySpacedPoints + 1] = p4.y
			end
		end
	end
	return evenlySpacedPoints
end

function GodotBezierTrack:initialize(info, options)
	_D("Create terrian: ", info.name)
	self.options = options or _default_options
	self.godotData = info
	self.physicProperties = info.physic_properties
	self.curvePoints = info.curve
	self.edgePoints = info.edge_points
	self.spacing = info.spacing or 512
	self.isClosed = info.is_closed
	self.name = info.name
	self.lhUniqueName = info.name

	if info.ground then
		self.ground = self:createGround(info.ground, self.options)
	end
	if info.track then
		self.track = self:createTrack(info.track)

		if self.ground == nil and self._lhFixture == nil then
			self._lhFixture = self:createFixturesData(self.track)
		end
	end

	self.lhUserCustomInfo = info.custom_info

	if type(info.visible) == "boolean" then
		self.isVisible = info.visible
	end
	self:translate(info.x, info.y)
	self:scale(info.xScale, info.yScale)
	self:rotate(math.deg(info.rotation))
	_centering(self)
	self.anchorOffset = {x = self.x - info.x, y = self.y - info.y}
end

function GodotBezierTrack:createTrack(elem)
	local group = display.newGroup()
	local meshes = elem.mesh
	-- local tracks = {}
	for i=1, #meshes do
		local data = meshes[i]
		local meshData = data.mesh
		local filename = data.texture:gsub(_godotDir, _baseDir)
		local mesh = display.newMesh{
			mode = "indexed",
			vertices = meshData[1],
			indices = meshData[2],
			uvs = meshData[3]
		}
		mesh:translate(mesh.path:getVertexOffset())
		mesh.changeMaterial = _trackChangeMaterial
		local wh = data.wh
		if wh then
			mesh:changeMaterial({
				width = wh[1],
				height = wh[2],
				filename = filename,
				isPowerOfTwo = _isPowerOfTwo(wh[1]) and _isPowerOfTwo(wh[2])
			})
		end
		mesh:setFillColor(_UC(elem.color))
		group:insert(mesh)
		-- tracks[i] = mesh
	end
	self:insert(group)
	return group
end

function GodotBezierTrack:createGround(elem, options)
	local meshData = elem.mesh
	local mesh = display.newMesh{
		mode = "indexed",
		vertices = meshData[1],
		indices = meshData[2],
		uvs = meshData[3]
	}
	mesh:translate(mesh.path:getVertexOffset())
	mesh.changeMaterial = _groundChangeMaterial
	if elem.res_path then
		local filename = elem.res_path:gsub(_godotDir, _baseDir)
		local wh = elem.wh
		-- _D("!-> GodotBezierTrack ground: " .. filename)
		if wh then
			mesh:changeMaterial({
				width = wh[1],
				height = wh[2],
				tiling = elem.tiling,
				filename = filename,
				isPowerOfTwo = _isPowerOfTwo(wh[1]) and _isPowerOfTwo(wh[2])
			})
		end
	end
	mesh:setFillColor(_UC(elem.color))
	if options.groundHeightOffset and (not self.isClosed) then
		local bounds = _getBounds(self.curvePoints)
		local height = (bounds.yMax - bounds.yMin) + options.groundHeightOffset
		local container = display.newContainer(self, mesh.width, height)
		container:insert(mesh)
		container:translate(mesh.x, mesh.y - (mesh.height - height) * 0.5)
		mesh:translate(-mesh.x, -mesh.y + (mesh.height - height) * 0.5)
	else
		self:insert(mesh)
	end

	self._lhFixture = self:createFixturesData(mesh, meshData[1], meshData[2])

	return mesh
end

function GodotBezierTrack:createFixturesData(ground, verts, tris)
	local physicProperties = self.physicProperties
	if physicProperties and self.options.nophysic ~= 1 then
		local physicType = physicProperties.object_type
		local fixtureType = physicProperties.fixture_type
		if physicType ~= "nophysic" then
			local localVerts = {}
			if fixtureType == "edge" or fixtureType == "edge_godot" or (verts == nil and tris == nil) then
				-- local curve = self.curvePoints
				-- for i=1, #curve do
				-- 	local p = curve[i]
				-- 	local n = 2 * i
				-- 	localVerts[n - 1], localVerts[n] = ground:contentToLocal(p[1], p[2])
				-- end
				local points = self.edgePoints
				if points == nil then
					points = calculateEvenlySpacedPoints(self.curvePoints, self.spacing, 1)
				end
				for i=1, #points, 2 do
					localVerts[i], localVerts[i + 1] = ground:contentToLocal(points[i], points[i + 1])
				end
			else
				for i=1, #verts, 2 do
					localVerts[i], localVerts[i + 1] = ground:contentToLocal(verts[i], verts[i + 1])
				end
			end
			local fixInfo = physicProperties.fixtures[1]
			local fixture = {
				coordinate = ground,
				vertices = localVerts,
				indices = tris
			}
			return fixture
		end
	end
end

function GodotBezierTrack:createPhysicObjectForSprite(physicProperties)
	if type(physicProperties) == "table" and physicProperties.object_type ~= "nophysic" then
		local fixtureType = physicProperties.fixture_type
		local fixInfo = physicProperties.fixtures[1]
		if self.ground == nil then
			fixtureType = "edge"
		end

		local density = fixInfo.density
		local friction = fixInfo.friction
		local bounce = fixInfo.bounce
		local isSensor = fixInfo.is_sensor
		local filter = {
			categoryBits = fixInfo.category,
			maskBits 	 = fixInfo.mask,
			groupIndex 	 = fixInfo.group_index
		}
		if filter.groupIndex == 0 then
			filter.groupIndex = -11
		end
		if fixtureType == "box" then
			physics.addBody(self, physicProperties.object_type, {
				density = density,
				friction = friction,
				bounce = bounce,
				isSensor = isSensor,
				filter = filter,
				box = {halfWidth=self.contentWidth * 0.5, halfHeight=self.contentHeight * 0.5, x=0, y=0, angle=0},
			})
		elseif fixtureType == "circle" then
			physics.addBody(self, physicProperties.object_type, {
				density = density,
				friction = friction,
				bounce = bounce,
				isSensor = isSensor,
				filter = filter,
				radius = self.contentWidth * 0.5
			})
		elseif fixtureType == "polygon" then
			local lhFixture = self._lhFixture
			local ground = lhFixture.coordinate
			local verts = lhFixture.vertices
			local tris = lhFixture.indices
			local shapes = {}
			local n = 1
			for i=1, #tris, 3 do
				local a, b, c = 2*tris[i], 2*tris[i+1], 2*tris[i+2]
				local ax, ay = self:contentToLocal(ground:localToContent(verts[a - 1], verts[a]))
				local bx, by = self:contentToLocal(ground:localToContent(verts[b - 1], verts[b]))
				local cx, cy = self:contentToLocal(ground:localToContent(verts[c - 1], verts[c]))
				local shape = {ax, ay, bx, by, cx, cy}
				local area = _trangleArea(shape)
				if _equalToZero(area, 1) then
					_D("shape is zero", area)
				else
					-- _D(area)
					shapes[n] = {
						density = density,
						friction = friction,
						bounce = bounce,
						isSensor = isSensor,
						filter = filter,
						shape = shape
					}
					n = n + 1
				end
			end
			physics.addBody(self, physicProperties.object_type, unpack(shapes))
		elseif fixtureType == "edge" or fixtureType == "edge_godot" then
			local lhFixture = self._lhFixture
			local ground = lhFixture.coordinate
			local verts = lhFixture.vertices
			local chain = {}
			for i=1, #verts, 2 do
				chain[i], chain[i+1] = self:contentToLocal(ground:localToContent(verts[i], verts[i + 1]))
			end
			physics.addBody(self, physicProperties.object_type, {
				density = density,
				friction = friction,
				bounce = bounce,
				isSensor = isSensor,
				filter = filter,
				chain = chain,
				connectFirstAndLastChainVertex = self.isCLosed -- bezierDict.lhIsClosed
			})
		end

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

return GodotBezierTrack
