-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("if", {
    {name = "cond", type = "string", limit = {max = 10000, min = 0}, desc="条件"},
    {name = "order", type = "string", limit = {max = 10000, min = 0}, desc="命令"}
})

-- if,cond={$a==true, $b==true},order={}
function Action.execute(ctx, act)
	local cond = act.cond or act.extension.condition
	-- local list = _.split(act.cond:gsub("[{}]", ""), ",")
	local list = string.fastSplit(act.cond:gsub("[{}]", ""), ",")
	for i=1, #list do
		local info = list[i]
		local variableName, value = info:match("([^=]+)==([^=]+)")
		local variable = Helper.getVariable(ctx, variableName)
		if variable == value and act.order then
			Helper.runActions(ctx, act.order:gsub("[{}]", ""), act.target)
		end
	end
end

return Action
