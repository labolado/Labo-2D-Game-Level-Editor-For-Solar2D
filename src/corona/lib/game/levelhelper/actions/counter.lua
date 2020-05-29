-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("counter", {
    {name = "id", default = "", type = "string", limit = {max = 10000, min = 0}, desc="游戏标识"},
    {name = "delta", default = 0, type = "int", limit = {max = 1000, min = -1000}, desc="变化值"}
})

function Action.execute(ctx, obj)
	if obj.id == "" then	
		-- identifier = ctx.counters[obj.target.loaderID][1]
		local counters = ctx.counters[obj.target.loaderID]
		for i=1, #counters do
			local identifier = counters[i]
			if identifier and identifier.actionCounterValue then
				identifier.actionCounterValue = identifier.actionCounterValue + obj.delta
				_D("Monitor " .. identifier.lhUniqueName .. " counter = " .. identifier.actionCounterValue)
			end
		end
	else
		local identifier = Helper.findLevelObject(ctx, obj.id, obj.target.loaderID)
		if identifier and identifier.actionCounterValue then
			identifier.actionCounterValue = identifier.actionCounterValue + obj.delta
			_D("Unique monitor " .. obj.id ..  " counter = " .. identifier.actionCounterValue)
		end
	end
end

return Action
