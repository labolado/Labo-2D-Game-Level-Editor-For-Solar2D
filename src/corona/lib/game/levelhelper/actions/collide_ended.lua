-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("collide_ended", {
    {name = "with", required=true, type = "string", limit = {max = 10000, min = 0}, desc="要监测的对象"},
    {name = "order", default="", type = "string", limit = {max = 10000, min = 0}, desc="碰撞是执行的命令"},
    {name = "repeatable", default = true, type = "bool", desc="是否可重复碰撞"}
})

function Action.init(ctx, act)	
	local mine = act.target
	local with
	if act.extension then
		with = act.extension.ext_with or Helper.findLevelObject(ctx, act.with, mine.loaderID)
	else
		with = Helper.findLevelObject(ctx, act.with, mine.loaderID)
	end
	local order = act.order:gsub("[{}]", "")
	local count = 0
	function act:collision(e)
		local other = e.other
		if other == with then
		    if e.phase == "began" then
		        count = count + 1
		    elseif e.phase == "ended" then
		        count = count - 1
		        if count == 0 then
	                ctx.timerMgr:setTimeout(10, function()
	                	Helper.runActions(ctx, order, mine)
	                	if not self.repeatable then
		                    mine:removeEventListener("collision", self)
		                end
	                end)
		        end
		    end
		end
	end
	mine:addEventListener("collision", act)
end

function Action.execute(ctx, obj)
    Action.init(ctx, obj)
end

return Action