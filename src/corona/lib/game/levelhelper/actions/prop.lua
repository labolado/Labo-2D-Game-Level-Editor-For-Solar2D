-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local TypeParser = pkgImport(..., "type_parser")
local Action = pkgImport(..., "base"):extend("prop", {
    -- {name = "alpha", default = 1, type = "float", limit = {max = 10000, min = -10000}, desc="透明度"},
    -- {name = "visible", default = true, type = "bool", limit = {max = 10000, min = -10000}, desc="是否可见"},
    -- {name = "sensor", default = false, type = "bool", limit = {max = 10000, min = -10000}, desc="是否传感器"},
    -- {name = "color", default = "#ffffffff", type = "string", limit = {max = 10000, min = -10000}, desc="颜色"},
})

local GodotTerrian = require("godot.godot_loader").GodotTerrian

function Action.init(ctx, obj)

    function obj:start()
        local target = self.target
        local setValue = function(v, k)
            if type(v) ~= "function" and type(v) ~= "table" then
                if k == "color" then
                    if target.class ~= GodotTerrian then
                        target:setFillColor( uHexColor(v) )
                    end
                elseif k == "sensor" then
                    target.isSensor = TypeParser.bool(nil, v, k, obj)
                elseif k == "visible" then
                    target.isVisible = TypeParser.bool(nil, v, k, obj)
                elseif k == "alpha" then
                    target.alpha = TypeParser.float({max = 1, min = 0}, v, k, obj)
                elseif k == "gravityScale" then
                    target.gravityScale = TypeParser.float({max = 1000, min = -1000}, v, k, obj)
                elseif k == "angularVelocity" then
                    target.angularVelocity = TypeParser.float({max = 1000, min = -1000}, v, k, obj)
                elseif k == "angularDamping" then
                    target.angularDamping = TypeParser.float({max = 1000, min = 0}, v, k, obj)
                elseif k == "linearDamping" then
                    target.linearDamping = TypeParser.float({max = 1000, min = 0}, v, k, obj)
                elseif k == "isHitTestable" then
                    target.isHitTestable = TypeParser.bool(nil, v, k, obj)
                elseif k == "isFixedRotation" then
                    target.isFixedRotation = TypeParser.bool(nil, v, k, obj)
                elseif k == "anchorX" or k == "anchorY" then
                    target[k] = TypeParser.float({max = 1, min = -1}, v, k, obj)
                elseif k == "linearVelocity" then
                    local vx, vy = v:match("([^_]+)_([^_]+)")
                    local limit = {max = 100000, min = -100000}
                    vx = TypeParser.float(limit, vx, k, obj)
                    vy = TypeParser.float(limit, vy, k, obj)
                    target:setLinearVelocity(vx, vy)
                elseif k == "lhPath" then
                    if v == "start" then
                        target:startPathMovement()
                        -- target.lhPathNode:setSpeed(1)
                    elseif v == "pause" then
                        target:pausePathMovement()
                    elseif v == "stop" then
                        target:stopPathMovement()
                    end
                elseif k == "removePhysics" then
                    local physics = ctx.physics
                    physics.removeBody(target)
                else
                    if target.class == GodotTerrian then
                        if k:starts("ext") then
                            target[k] = v
                        end
                    else
                        target[k] = v
                    end
                end
            end
        end
        -- _.each(self, setValue)
        if self.extension then _.each(self.extension, setValue) end
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
