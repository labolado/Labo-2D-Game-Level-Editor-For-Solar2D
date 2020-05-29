-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
--使指定的物理对象进行旋转
local Action = pkgImport(..., "base"):extend("physic_to_dynamic", {
})

function Action.init(ctx, obj)
    obj.target.bodyType = "static"
    function obj:start()
        self.target.bodyType = "dynamic"
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
