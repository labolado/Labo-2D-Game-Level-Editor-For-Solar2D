-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- Bezier path movement
local Action = pkgImport(..., "base"):extend("path", {
    {name = "name", default = "", type = "string", limit = {max = 10000, min = 0}, desc="路径在levelhelper中的名字"},
    {name = "play", default = true, type = "bool", desc="是否播放"},
})

function Action.execute(ctx, act)
	local target = act.target
    if act.play then
    	target:startPathMovement()
    else
        target:stopPathMovement()
    end
end

return Action
