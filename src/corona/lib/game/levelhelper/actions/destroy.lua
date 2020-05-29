-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--删除指定的对象
local Action = pkgImport(..., "base"):extend("destroy", {
})

function Action.init(ctx, obj)
    -- obj.target.bodyType = "static"
    -- function obj:start()
    --     ctx.timerMgr:setTimeout(20, function()
    --         self.target.bodyType = "dynamic"
    --     end)
    -- end
end

function Action.execute(ctx, obj)
    if obj.removed ~= true then
        obj.target:removeSelf()
        obj.target = nil
        obj.removed = true
    end
end


return Action
