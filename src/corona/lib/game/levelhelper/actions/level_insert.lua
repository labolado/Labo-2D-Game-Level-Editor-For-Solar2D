-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- local Level = APP.import("lib.load_level")
local GodotLoader = require("godot.godot_loader")
local Action = pkgImport(..., "base"):extend("level_insert", {
    {name = "name", default = "", type = "string", limit = {max = 10000, min = -10000}, desc="关卡片段名字"},
    {name = "isUnity", default = false , type = "bool", limit = {max = 10000, min = -10000}, desc="关卡片段名字"},
})

local _push = _.push
local displayGroupIndexOf = displayGroupIndexOf
local unpack = unpack
local function _getBounds(t)
	local xMin = math.huge
	local xMax = -math.huge
	local yMin = math.huge
	local yMax = -math.huge
	for i=1, #t do
		local child = t[i]
		local bounds = child.contentBounds
		xMin = xMin > bounds.xMin and bounds.xMin or xMin
		xMax = xMax < bounds.xMax and bounds.xMax or xMax
		yMin = yMin > bounds.yMin and bounds.yMin or yMin
		yMax = yMax < bounds.yMax and bounds.yMax or yMax
	end
	return {xMin = xMin, xMax = xMax, yMin = yMin, yMax = yMax}
end
function Action.execute(ctx, obj)
	local levelLoader = ctx.levelLoader
	local parser = ctx.parser
	if levelLoader and parser then
		obj.target.isVisible = false
		local loader = GodotLoader:new(obj.target.godotChildrenInfo)
		loader.layer = loader.view
		loader.grounds = loader:batchWithUniqueName("road")
		local allCoronaSprites = loader.allCoronaSprites

		local startTags = loader:spritesWithTag(1)
		if #startTags > 0 then
		    levelLoader.carPosMark = startTags[#startTags]
		end

        local allGroups = {}
       	for idx=1, loader.layer.numChildren do
       		local group = loader.layer[idx]
            allGroups[idx] = group
        end

		if obj.isUnity then
			local index = displayGroupIndexOf(obj.target.parent, obj.target)
			obj.target.parent:insert(index, loader.layer)
		else
			local index = displayGroupIndexOf(loader.layer, loader.grounds)
			-- _.each(allGroups, function(group, idx)
			for idx=1, #allGroups do
				local group = allGroups[idx]
			    if idx < index then
			        levelLoader.behind:insert(group)
			    elseif idx == index then
			        levelLoader.grounds:insert(group)
			    else
			        levelLoader.front:insert(group)
			    end
			end
		end

		local lox, loy = 0, 0
		if ctx.physics then
			loader:addPhysics(lox, loy)
		else
			loader:translateSprite(lox, loy)
		end

		loader:startAllPaths()
        _push(levelLoader.loaders, loader)

		if ctx.game then
			_D("level_insert parseAndRegister: " .. obj.name)
		    parser:parseAndRegister(allCoronaSprites)
		end
        return loader
	end
end

return Action
