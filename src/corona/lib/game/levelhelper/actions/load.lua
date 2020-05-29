-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local GodotLoader = require("godot.godot_loader")
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("load", {
    {name = "name", required = true, type = "string", limit = {max = 10000, min = 0}, desc="关卡名字"},
    {name = "script", default = "default", type = "string", limit = {max = 10000, min = 0}, desc="游戏脚本"},
    {name = "loading", default = true, type = "bool", limit = {max = 10, min = 0}, desc="是否需要跳转loading页面"},
    {name = "clear", default = true, type = "bool", limit = {max=10, min = 0}, desc="是否清除当前的关卡"},
    {name = "offsetX", default = 0, type = "number", limit = {max=10000, min = -10000}, desc="偏移X"},
    {name = "offsetY", default = 0, type = "number", limit = {max=10000, min = -10000}, desc="偏移Y"},
    -- {name = "position", default = true, type = "bool", limit = {max=10, min = 0}, desc="是否清除当前的关卡"}
    {name = "onStart", default = "", type = "string", limit = {max = 10000, min = 0}, desc="开始时执行"},
    {name = "onComplete", default = "", type = "string", limit = {max = 10000, min = 0}, desc="完成时执行"}
})

local _push = table.insert
local displayGroupIndexOf = displayGroupIndexOf
local unpack = unpack

local function _loadGodotLevel(level, options)
	local levelName = "assets/levels/export/" .. level .. ".json"
	local loader = GodotLoader:new(levelName)
	loader.layer = loader.view

	local offset = options.offset or { x = 0, y = 0 }
	if options.isPhysics then
		loader:addPhysics(offset.x, offset.y)
	end
	if options.startAllPaths then loader:startAllPaths() end

	function loader:destroy()
	end
	return loader
end

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

local function _load_level(ctx, obj)
	local levelLoader = ctx.levelLoader
	local parser = ctx.parser
	if levelLoader and parser then
		local options = { offset = { x = 0, y = 0}, isPhysics = false, startAllPaths = false  }
		local loader = _loadGodotLevel(obj.name, options)
		loader.levelUniqueName = obj.name
		loader.grounds = loader:batchWithUniqueName("road")
		local allCoronaSprites = loader.allCoronaSprites
		-- _D("level_insert_num:", #allCoronaSprites)

		local startTags = loader:spritesWithTag(1)
		if #startTags > 0 then
		    levelLoader.carPosMark = startTags[#startTags]
		end


		local index = displayGroupIndexOf(loader.layer, loader.grounds)
        local allGroups = {}
        -- _.gEach(loader.layer, function(group, idx)
       	for idx=1, loader.layer.numChildren do
       		local group = loader.layer[idx]
            allGroups[idx] = group
        end
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
        loader.allCoronaGroups = allGroups

		local lox, loy = obj.offsetX, obj.offsetY
		if ctx.physics then
			loader:addPhysics(lox, loy)
		else
			loader:translateSprite(lox, loy)
		end

		loader:startAllPaths()

        _push(levelLoader.loaders, loader)

		if ctx.game then
		    parser:parseAndRegister(allCoronaSprites)
		end
        return loader
	end
end

local function _load(parentCtx, obj)
	local CustomCLassParser = require("lib.game.levelhelper.custom_class_parser")
	local script = obj.script
	local scriptDir = "lib.game.levelhelper.mini_games." .. script
	local contextScript = require(scriptDir .. ".context")
	local gameScript = require(scriptDir .. ".game")
	local ctx = contextScript:new(parentCtx, obj.target)
	local parser = CustomCLassParser:new(ctx)
	ctx.parser = parser
	-- local loader = Helper.runAction(ctx, "level_insert,name=" .. obj.name, obj.target)
	-- _D("LOADER = " .. tostring(loader))
	local loader = _load_level(ctx, obj)
	if loader then
        ctx.currentLoader = loader
		local game = gameScript:new(loader, ctx, obj)
		-- loader.miniGameID = obj.target
		_.push(ctx.miniGames, game)
	end
end
function Action.execute(parentCtx, obj)
	if obj.clear then parentCtx:onClearBefore() end
	_load(parentCtx, obj)
	if obj.clear then
		parentCtx:clear()
	end

end

return Action
