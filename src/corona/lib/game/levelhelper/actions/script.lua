-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("script", {
    {name = "name", default = "base", type = "string", limit = {max = 10000, min = 0}, desc="游戏名字"},
    -- {name = "list", default = "", type = "string", limit = {max=10000, min=0}, desc = "可控制对象列表" }
})

function Action.execute(ctx, obj)
	-- if obj.list ~= "" then
		-- local str = obj.list:gsub("[{}]", "")
		-- local list = str:fastSplit("[^,]+")
		-- local objects = {}
		-- local loaderID = obj.target.loaderID 
		-- local gameEndObject
		-- for i=1, #list do
		-- 	local lhObject = Helper.findLevelObject(ctx, list[i], loaderID)
		-- 	objects[#objects + 1] = lhObject
		-- end
		local script = obj.target._script
		if script == nil then
			local Script = import("game.levelhelper.scripts." .. obj.name)
			-- local event = _.extend({target = obj.target}, obj.extension)
			script = Script:new(ctx, obj)
			obj.target._script = script
		end
		script:run()
	-- end
end

return Action