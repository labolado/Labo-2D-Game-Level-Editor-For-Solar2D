-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("insert_game", {
    {name = "id", required = true, type = "string", limit = {max = 10000, min = 0}, desc="关卡标识"},
    {name = "script", default = "base", type = "string", limit = {max = 10000, min = 0}, desc="游戏名字"},
    {name = "list", default = "", type = "string", limit = {max=10000, min=0}, desc = "可控制对象列表" }
})

local _controlObjectsTag = "T1"
local _gameEndTag = "MINI_GAME_END"
function Action.execute(ctx, obj)
	if obj.list ~= "" then
		local str = obj.list:gsub("[{}]", "")
		local list = _.split(str, ",")
		local objects = {}
		local loaderID = obj.target.loaderID 
		local gameEndObject
		for i=1, #list do
			local lhObject = Helper.findLevelObject(ctx, list[i], loaderID)
			if lhObject.ext_id == _gameEndTag then
				gameEndObject = lhObject
			else
				objects[#objects + 1] = lhObject
			end
		end
		local Game = import("game.levelhelper.mini_games." .. obj.script)
		-- local Game = import(obj.script)
		local game = Game:new(loaderID, ctx, objects, gameEndObject, obj.extension or {})
		game.triggerID = obj.id
		_.push(ctx.insertedGames, game)
	end
end

return Action