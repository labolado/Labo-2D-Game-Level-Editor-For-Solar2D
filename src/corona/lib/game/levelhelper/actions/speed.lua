-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 天气
local Action = pkgImport(..., "base"):extend("speed", {
    {name = "delta", default = 0, type = "int", limit = {max = 10000, min = -10000}, desc="速度变化值"},
})

function Action.init(ctx, obj)

    local game = obj.GAME
    function obj:start()
        if obj.delta <= 0 then
            -- game:setCarControllable(true)
            -- ctx.car:setPower(false)
            -- ctx.sndMgr:carMoveStop()
        else
            ctx.car:setPower(true)
            -- game:setCarControllable(false)
        end
        ctx.car:speedUp(obj.delta)
        -- _D(obj.delay)
    end
end

function Action.execute(ctx, obj)
    if not obj.isInitialized then
        obj.isInitialized = true
        Action.init(ctx, obj)
    end
    obj:start()
end

return Action
