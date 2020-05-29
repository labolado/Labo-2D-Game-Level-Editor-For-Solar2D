-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("physic_to_static", {})

function Action.init(ctx, obj)
    function obj:start()
        -- _D("physic_to_static!physic_to_static!physic_to_static!")
        Helper.clearTargetJoint(ctx, self.target)
        self.target.bodyType = "static"
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
