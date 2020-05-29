-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local require = require
-- local Loading = require("app.ui.status.loading")
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("level_insert_game", {
    {name = "name", default = "godot", type = "string", limit = {max = 10000, min = 0}, desc="子关卡名字"},
    {name = "script", default = "default", type = "string", limit = {max = 10000, min = 0}, desc="游戏脚本"},
    {name = "loading", default = false, type = "bool", limit = {max = 100, min = 0}, desc="是否需要跳转loading页面"},
    {name = "isUnity", default = false , type = "bool", limit = {max = 10000, min = -10000}, desc="关卡片段名字"},
})

local _controlObjectsTag = "T1"
local _gameEndTag = "MINI_GAME_END"
local miniGameBaseDir = "lib.game.levelhelper.mini_games."
function Action.execute(parentCtx, obj)
	local function load()
		local CustomCLassParser = require("lib.game.levelhelper.custom_class_parser")
		local script = obj.script
		local contextScript
		local gameScript
		local ctx
		if script == "default" then
			contextScript = require(miniGameBaseDir .. "base_context")
			-- gameScript = require(scriptDir .. ".game")
			ctx = contextScript:new(parentCtx, obj.target)
			-- ctx = parentCtx
			-- ctx = _.clone(parentCtx)
			-- ctx.variables = {}
			-- ctx.miniGames = parentCtx.miniGames
			-- ctx.customSignal = parentCtx.customSignal
			-- ctx.actionSignal = parentCtx.actionSignal
			local parser = CustomCLassParser:new(ctx)
			ctx.parser = parser
		else
			local scriptDir = miniGameBaseDir .. script
			contextScript = require(scriptDir .. ".context")
			gameScript = require(scriptDir .. ".game")
			ctx = contextScript:new(parentCtx, obj.target)
			local parser = CustomCLassParser:new(ctx)
			ctx.parser = parser
		end

		local str = string.format("level_insert,name=%s,isUnity=%s", obj.name, tostring(obj.isUnity))
		local loader = Helper.runAction(ctx, str, obj.target)
		-- _D("LOADER = " .. tostring(loader))
		if loader then
			local allCoronaSprites = loader.allCoronaSprites
			local objects = {}
			local gameEndObject
			for i=1, #allCoronaSprites do
				local spr = allCoronaSprites[i]
				-- local texDict = spr.spriteInfo:dictForKey("TextureProperties")
				-- spr.color = texDict:rectForKey("Color");
				if spr.ext_id ~= nil then
					if spr.ext_id == _gameEndTag then
						gameEndObject = spr
					else
						objects[#objects + 1] = spr
					end
				end
			end

			local gameOptions = obj.extension
			if gameScript == nil then
				local extension = loader.extension
				if extension then
					_D("level_insert_game " .. obj.name, extension.script, extension.ui, extension.ui_type)
					gameScript = require(miniGameBaseDir .. extension.script)
					gameOptions = extension
				else
					gameScript = require(miniGameBaseDir .. "default.game")
					gameOptions = obj.extension
				end
			end
			local game = gameScript:new(loader, ctx, objects, gameEndObject, gameOptions)
			ctx.game = game
			_D("!-> level_insert_game: ", obj.target.lhUniqueName, game)
			loader.miniGameID = obj.target
			_.push(ctx.miniGames, game)
		end
	end
	-- if obj.loading then
	-- 	Loading:start2(100, load)
	-- else
		load()
	-- end
end

return Action
