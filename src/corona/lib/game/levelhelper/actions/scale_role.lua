-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local Action = pkgImport(..., "base"):extend("scale_role", {
    {name = "value", required = true, type = "number", limit = {max = 10, min = -10}, desc="缩放系数"}
})

function Action.execute(ctx, obj)
	local role = obj.ROLE
	local game = obj.GAME
	if role and game then
		role:setScale(obj.value)
	end
end

return Action
