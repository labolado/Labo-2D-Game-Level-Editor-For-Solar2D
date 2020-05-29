-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 天气
local Action = pkgImport(..., "base"):extend("stop", {})

-- function Action.init(ctx, obj)

--     function obj:start()
--         ctx.car:speedUp(obj.delta)
--         _D(obj.delay)
--     end
-- end

function Action.execute(ctx, obj)
    -- obj:start()
    if ctx.car then
        _.each(ctx.car.wheels, function(wheel)
            wheel.angularDamping = 5
        end)
        ctx.car:setLinearSpeed(200, 0)
        ctx.sndMgr:fadeOutAlarm()
    end
end

return Action