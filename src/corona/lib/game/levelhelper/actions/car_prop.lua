-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local TypeParser = pkgImport(..., "type_parser")
--使指定的物理对象进行旋转
local Action = pkgImport(..., "base"):extend("car_prop", {})

function Action.execute(ctx, obj)
    local target = obj.target
    local setValue = function(v, k)
        if type(v) ~= "function" and type(v) ~= "table" then
            if k == "gravity" then
                local value = TypeParser.float({max = 1000, min = -1000}, v, k, obj)
                if value == 1 then
                    ctx.car:setGravityScale(value)
                elseif value == -1 then
                    ctx.car:gravityScaleReverse()
                else
                    ctx.car:gravityScaleRestore()
                end
            end
        end
    end
    if obj.extension then _.each(obj.extension, setValue) end
end

return Action