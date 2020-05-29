-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("let", {
    {name = "targets", type = "string", limit = {max = 10000, min = 0}, desc="同一命令执行的对象群"},
    {name = "order", type = "string", limit = {max = 10000, min = 0}, desc="命令,可以是多个"}
})

-- let,targets={a,b,c,d},order={xxxa;xxxb;xxxc}
function Action.execute(ctx, act)
	local targets = act.targets
	-- local list = _.split(act.targets:gsub("[{}]", ""), ",")
	local value = act.targets:gsub("[{}]", "")
	local list = string.fastSplit(value, "[^,]+")
	local order = act.order:gsub("[{}]", "")
	for i=1, #list do
		local orderTarget = Helper.findLevelObject(ctx, list[i], act.target.loaderID)
		Helper.runActions(ctx, order, orderTarget)
	end
end

return Action
