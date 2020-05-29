-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("mini_game_excute", {
    {name = "id", default = "", type = "string", limit = {max = 10000, min = 0}, desc="游戏标识"},
    {name = "signal", default = "", type = "string", limit = {max = 100, min = -100}, desc="信号名"},
})

function Action.execute(ctx, obj)
	-- local game = Helper.findMiniGame(ctx, obj)
	local game = ctx.game
	if game then
		local sigName = obj.signal
		if sigName == "" then sigName = game.SIG_DEFAULT or obj.signal end
		_D("mini_game_excute, sigName = " .. sigName)
		game:sigEmit(sigName, obj.extension or {})
	end
end

return Action
