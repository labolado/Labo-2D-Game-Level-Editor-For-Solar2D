-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("mini_game_play", {
    -- {name = "name", required = true, type = "string", limit = {max = 10000, min = -10000}, desc="关卡片段名字"},
    {name = "id", default = "", type = "string", limit = {max = 10000, min = 0}, desc="游戏标识"}
})

function Action.execute(ctx, obj)
	-- local game = Helper.findMiniGame(ctx, obj)
	local game = ctx.game
	_D("mini_game_play name:", game, obj.GAME)
	if game then
		game:start()
	end
end

return Action
