-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--移动摄像头
local Action = pkgImport(..., "base"):extend("camera_move", {
    {name = "x", default = 0, type = "float", limit = {max=10000,min=-10000}, desc="x轴移动的距离"},
    {name = "y", default = 0, type = "float", limit = {max=10000,min=-10000},desc="y轴移动的距离"},
    --{name = "layer", default = "", type = "string", limit = {max = 100000, min=0}, desc="层名"},
})

-- function Action.init(ctx, obj)
-- end

function Action.execute(ctx, obj)
    -- Action.init(ctx, obj)
    if ctx.camera then
         local pos = ctx.camera._position
         ctx.camera:setPosition(pos.x + obj.x, pos.y + obj.y)
    end
end

return Action