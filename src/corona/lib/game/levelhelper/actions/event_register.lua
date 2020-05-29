-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("event_register", {
    {name = "id", default = "", type = "string", limit = {max = 10000, min = 0}, desc="游戏标识"},
    {name = "once", default = false, type = "bool", limit = {max = 10000, min = 0}, desc="是否一次性事件"},
    {name = "event", type = "string", limit = {max = 100, min = -100}, desc="事件名"},
    {name = "listener", type = "string", limit = {max = 10000, min = 0}, desc="命令"}
})

function Action.execute(ctx, obj)
	local game = obj.GAME
	local sigName = obj.event
	local listener = obj.listener
	_D("event_register", sigName, listener)
	if game and sigName:len() > 0 and listener:len() > 0 then
		if obj.id == "self" then
			sigName = string.format("%s-%s", sigName, tostring(obj.target.lhUniqueName))
		elseif obj.id ~= "" then
			sigName = string.format("%s-%s", sigName, obj.id)
		end
		local tmp
		if listener:starts("game:") then
			local handlerName = listener:gsub("game:", "")
			local handler = game[handlerName]
			if type(handler) == "function" then
				tmp = function(event)
					handler(game, event)
				end
			else
				tmp = EMPTY
			end
		else
			tmp = function()
				-- Helper.runActions(ctx, listener:gsub("[{}]", ""), obj.target)
				Helper.parseAndRun(ctx, listener, obj.target)
			end
		end
		if obj.once then
			game:sigRegisterOnce(sigName, tmp)
			_D("event_register_once, sigName = " .. sigName, listener)
		else
			game:sigRegister(sigName, tmp)
			_D("event_register, sigName = " .. sigName, listener)
		end
	end
end

return Action
