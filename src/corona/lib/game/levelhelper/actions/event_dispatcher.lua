-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("event_dispatcher", {
    {name = "id", default = "", type = "string", limit = {max = 100, min = 0}, desc="游戏标识"},
    {name = "event", default = "", type = "string", limit = {max = 100, min = 0}, desc="事件名"},
})

function Action.execute(ctx, obj)
	-- local game = ctx.game
	local game = obj.GAME
	if game then
		local sigName = obj.event
		if sigName == "" then sigName = game.SIG_DEFAULT or obj.event end
		if obj.id ~= "" then
			sigName = string.format("%s-%s", sigName, obj.id)
		end
		_D("GAME = " .. tostring(game))
		_D("event_dispatcher, sigName = " .. sigName)
		local event = _.extend({target = obj.target}, obj.extension)
		game:sigEmit(sigName, event)
	end
end

return Action
