local function pkgImport(path, name, level)
	local basePath = path:match("^(.+)%.[^%.]+")
    return require(basePath .. '.' .. name)
end

GodotGlobal = pkgImport(..., "godot_global")

local class           = GodotGlobal.class
local _               = GodotGlobal._
local Data            = GodotGlobal.DataManager
local DEFAULT_OPTIONS = GodotGlobal.DEFAULT_OPTIONS

local GodotNode           = pkgImport(..., "godot_node")
local GodotSprite         = pkgImport(..., "godot_sprite")
local GodotAnimatedSprite = pkgImport(..., "godot_animated_sprite")
local GodotTerrian        = pkgImport(..., "godot_bezier_track")
local GodotPathFollow     = pkgImport(..., "godot_path_follow")
local GodotJoint          = pkgImport(..., "godot_joint")

local GodotLoader = class("GodotLoader")

GodotLoader.static.GodotNode = GodotNode
GodotLoader.static.GodotSprite = GodotSprite
GodotLoader.static.GodotTerrian = GodotTerrian

local clone = _.clone
local _godotDir = "res://corona/"
-- local _baseDir = APP.config.game.roadAssetsDir
local _baseDir = ""
-- local _godotDir2 = "res://"

function GodotLoader:initialize(levelFile, options)
	options = options or DEFAULT_OPTIONS

	if type(options.onCreateSprite) == "function" then
		self.onCreateSprite = options.onCreateSprite
	end

	self.options = options
	self.numSprites = 0
	self.allCoronaSprites = {}
	self.allJointsData = {}
	self.allJoints = {}

	if levelFile ~= nil then
		local data
		if type(levelFile) == "table" then
			data = levelFile
			self.levelFile = data.layout[1].name
		else
			data = Data:loadJson(levelFile, options.baseDir or system.ResourceDirectory)
			self.levelFile = levelFile
		end
		self.data = data

		local layout = data.layout
		self.view = self:createNode(layout[1])
	end
end

local function isInsertedNode(info)
	local result = false
	local custom = info.custom_info
	if custom and custom.onLoad then
		result = custom.onLoad:starts("level_insert")
	end
	return result
end

function GodotLoader:createNode(info)
	local group = GodotNode:new(info)
	if isInsertedNode(info) then
		local newInfo = clone(info)
		newInfo.custom_info = nil
		group.godotChildrenInfo = {layout = {newInfo}}
		self.numSprites = self.numSprites + 1
		self.allCoronaSprites[self.numSprites] = group
	else
		local children = info.children
		for i=1, #children do
			local elem = children[i]
			if elem.children then
				if elem.type == "path" then
					self:createPathFollow(elem, group)
				else
					local g = self:createNode(elem)
					-- g.name = elem.name
					group:insert(g)
				end
			else
				if elem.ground or elem.track then
					local bezierTrack = self:createBezierTrack(elem)
					self.numSprites = self.numSprites + 1
					self.allCoronaSprites[self.numSprites] = bezierTrack
					group:insert(bezierTrack)
				elseif elem.joint then
					self.allJointsData[#self.allJointsData + 1] = elem
				else
					local spr = self:createSprite(elem)
					self.numSprites = self.numSprites + 1
					self.allCoronaSprites[self.numSprites] = spr
					group:insert(spr)
				end
			end
		end
	end
	return group
end

function GodotLoader:createPathFollow(info, parent)
	local pathFollow = GodotPathFollow:new(info)
	local children = info.children
	local n = 1
	for i=1, #children do
		local elem = children[i]
		if elem.type == "sprite" or elem.type == "animated_sprite" then
			local spr = self:createSprite(elem)
			self.numSprites = self.numSprites + 1
			self.allCoronaSprites[self.numSprites] = spr
			parent:insert(spr)
			if n > 1 then
				local godotPathFollow = GodotPathFollow:new(info, pathFollow.curve)
				godotPathFollow:setTarget(spr)
				spr.godotPathFollow = godotPathFollow
			else
				pathFollow:setTarget(spr)
				spr.godotPathFollow = pathFollow
			end
			n = n + 1
		end
	end
	-- parent:insert(group)
	-- return group
end

function GodotLoader:createSprite(info)
	-- if info.res_path:find(_godotDir) ~= nil then
	info.res_path = info.res_path:gsub(_godotDir, _baseDir)
	-- else
		-- info.res_path = info.res_path:gsub(_godotDir2, "")
	-- end

	if self.onCreateSprite then
		return self.onCreateSprite(info)
	else
		if info.type == "animated_sprite" then
			return GodotAnimatedSprite:new(info)
		else
			return GodotSprite:new(info)
		end
	end
end

function GodotLoader:createRect()
end

function GodotLoader:createBezierTrack(info)
	return GodotTerrian:new(info)
end

function GodotLoader:createPhysics()
	local allCoronaSprites = self.allCoronaSprites
	for i=1, #allCoronaSprites do
		local spr = allCoronaSprites[i]
		spr:createPhysicObjectForSprite(spr.physicProperties)
	end
end

function GodotLoader:createJoints()
	local allJoints = self.allJoints
	local allJointsData = self.allJointsData
	local n = 1
	local t = {}
	for i=1, #allJointsData do
		local elem = allJointsData[i]
		if elem.type == "gear" then
			t[#t + 1] = elem
		else
			local joint = GodotJoint:new(elem, self)
			allJoints[n] = joint
			n = n + 1
		end
	end
	for i=1, #t do
		local elem = t[i]
		local joint = GodotJoint:new(elem, self)
		allJoints[n] = joint
		n = n + 1
	end
end

---[[
function GodotLoader:batchWithUniqueName(name)
	local view = self.view
	for i=1, view.numChildren do
		local child = view[i]
		if child.name == name then
			return child
		end
	end
end

function GodotLoader:spriteWithUniqueName(name)
	local sprites = self.allCoronaSprites
	for i=1, #sprites do
		local obj = sprites[i]
		if obj.lhUniqueName == name then
			return obj
		end
	end
end

function GodotLoader:spritesWithTag(tag)
	local sprites = self.allCoronaSprites
	local t = {}
	for i=1, #sprites do
		local obj = sprites[i]
		if obj.lhTag == tag then
			t[#t + 1] = obj
		end
	end
	return t
end

function GodotLoader:addPhysics(px, py)
	local allCoronaSprites = self.allCoronaSprites
	for i=1, #allCoronaSprites do
		local spr = allCoronaSprites[i]
		spr:translate(px, py)
		if spr.godotChildrenInfo == nil then
			spr:createPhysicObjectForSprite(spr.physicProperties)
		end
		spr.loaderID = self
		spr.levelName = self.levelFile
	end
	self:createJoints()
end

function GodotLoader:translateSprite(px, py)
    local allSprites = self.allCoronaSprites
	for i=1, #allSprites do
	    local spr = allSprites[i]
	    spr:translate( px, py )
	    spr.loaderID = self
	    spr.levelName = self.levelFile
	end
end

function GodotLoader:jointWithUniqueName(name)
	local allJoints = self.allJoints
	for i=1, #allJoints do
		local joint = allJoints[i]
		if joint.name == name then
			return joint
		end
	end
end

function GodotLoader:jointsWithPattern(pattern)
	local found = {}
	local allJoints = self.allJoints
	for i=1, #allJoints do
		local joint = allJoints[i]
		if joint.name:find(pattern) then
			found[#found + 1] = joint
		end
	end
	return found
end

function GodotLoader:removeJoint(name)
	local allJoints = self.allJoints
	local idx = -1
	for i=1, #allJoints do
		local joint = allJoints[i]
		if joint.name == name then
			idx = i
			break
		end
	end
	if idx > 0 then
		local joint = table.remove(allJoints, idx)
		joint:removeSelf()
	end
end

function GodotLoader:removeAllJoints()
	local allJoints = self.allJoints
	for i=1, #allJoints do
		local joint = allJoints[i]
		joint:removeSelf()
	end
end

function GodotLoader:startAllPaths()
    local allSprites = self.allCoronaSprites
	for i=1, #allSprites do
	    local spr = allSprites[i]
	    if spr.godotPathFollow then
	    	if spr.godotPathFollow.startAtLaunch then
				spr:startPathMovement()
			end
		end
	end
end
--]]

function GodotLoader:removeSelf()
	self.allJointsData = nil
	self.allJoints = nil
	self.allCoronaSprites = nil
	self.data = nil
	display.cleanGroup(self.view)
end

return GodotLoader
