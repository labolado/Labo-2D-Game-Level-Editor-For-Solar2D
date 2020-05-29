-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--
local Action = pkgImport(..., "base"):extend("camera", {
    {name = "lock", default = false, type = "bool", desc="是否锁住x轴跟踪"},
    {name = "lockx", default = false, type = "bool", desc="是否锁住x轴跟踪"},
    {name = "locky", default = false, type = "bool", desc="是否锁住y轴跟踪"},
    {name = "layer", default = "", type = "string", limit = {max = 100000, min=0}, desc="层名"},
})

-- function Action.init(ctx, obj)
-- end

function Action.execute(ctx, obj)
    -- Action.init(ctx, obj)
    if ctx.camera then
        _D("camera!camera!camera!camera! " .. tostring(obj.lock))
        ctx.camera:lockXTracking(obj.lockx)
        ctx.camera:lockYTracking(obj.locky)
        if obj.lock then
        	ctx.camera:stopTrack()
        else
        	ctx.camera:track()
        end
    end
end

return Action
