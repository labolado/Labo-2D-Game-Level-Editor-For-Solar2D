-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local PhysicHelper = {}

-- group = display.newGroup()

--获取指定位置坐标是否在指定的物理对象上
--@param x,y,
--@param obj，需要检测的对象
function PhysicHelper.isOnBody(px, py, offsetX, offsetY, obj)
    -- -- group:removeSelf()
    -- -- group = display.newGroup()
    -- -- obj.parent:insert( group)
    -- local originX = x
    -- local originY = y
    -- local ox, oy = getOffsetFromParent(obj.parent)
    -- local osx, osy = getWorldScale(obj.parent)
    -- -- local ox, oy = -offsetX, -offsetY
    -- -- Log:debug("Offset theirs -------------> " .. ox .. " " .. oy)
    -- -- Log:debug("Offset mine -------------> "  .. offsetX .. " " .. offsetY)
    -- local x = (x - ox) / osx
    -- local y = (y - oy) / osy
    local x, y  = obj.parent:contentToLocal(px, py)
    local hits = physics.queryRegion(x -1, y-1, x+1, y +1)
    if (hits) then
        -- Log:debug("hit ok")

        for i, v in ipairs(hits) do
            if v == obj then
                local bounds = obj.contentBounds
                --local x, y = x,
                -- local rayHits1 = physics.rayCast((bounds.xMin - 1 - ox) / osx  ,y, x, y, "unsorted")
                -- local rayHits2 = physics.rayCast((bounds.xMax + 1 - ox) / osx ,y, x, y, "unsorted")
                -- local rayHits3 = physics.rayCast(x, (bounds.yMin - 1 - oy) / osy, x, y, "unsorted")
                -- local rayHits4 = physics.rayCast(x, (bounds.yMax + 1 - oy) / osy , x, y, "unsorted")
                local xMin, yMin = obj.parent:contentToLocal(bounds.xMin - 1, bounds.yMin - 1)
                local xMax, yMax = obj.parent:contentToLocal(bounds.xMax + 1, bounds.yMax + 1)
                local rayHits1 = physics.rayCast(xMin, y, x, y, "unsorted")
                local rayHits2 = physics.rayCast(xMax, y, x, y, "unsorted")
                local rayHits3 = physics.rayCast(x, yMin, x, y, "unsorted")
                local rayHits4 = physics.rayCast(x, yMax, x, y, "unsorted")

                -- local t = {
                --     {x = bounds.xMin - 1 - ox, y = originY - oy},
                --     {x = bounds.xMax + 1 - ox, y = originY - oy},
                --     {x = originX - ox, y = bounds.yMin - 1 - oy},
                --     {x = originX - ox, y = bounds.yMax + 1 - oy},
                -- }
                -- local function draw(dots, i)
                --     if dots ~= nil then
                --         _.each(dots, function(dot)
                --             local circle = display.newCircle(dot.position.x, dot.position.y, 10)
                --             circle:setFillColor(uHexColor("#ff0000ff"))
                --             circle.alpha = 0.8
                --             group:insert(circle)
                --         end)
                --     end
                --     circle = display.newCircle( t[i].x, t[i].y, 8 )
                --     circle:setFillColor( 0, 1, 0, 1 )
                --     group:insert( circle )
                -- end
                -- draw(rayHits1, 1)
                -- draw(rayHits2, 2)
                -- draw(rayHits3, 3)
                -- draw(rayHits4, 4)


                -- if rayHits1 and rayHits2 and rayHits3 and rayHits4 then
                if _.any(rayHits1, function(hit) return (hit.object == obj) end) and
                        _.any(rayHits2, function(hit) return (hit.object == obj) end) and
                        _.any(rayHits3, function(hit) return (hit.object == obj) end) and
                        _.any(rayHits4, function(hit) return (hit.object == obj) end) then
                    return true
                end
            end
        end
    end
    return false
end

return  PhysicHelper

