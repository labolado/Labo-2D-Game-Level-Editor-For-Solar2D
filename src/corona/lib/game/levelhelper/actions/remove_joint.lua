-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 删除 levelHelper 关节
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("remove_joint", {
    {name = "name", default = "", type = "string", limit = {max = 10000, min = 0}, desc="关节的名字"},
})

function Action.execute(ctx, obj)
    if obj.name == "" then
        Helper.clearTargetJoint(ctx, obj.target)
    else
        local loader = obj.target.loaderID
        loader:removeJoint(obj.name)
    end
end

return Action