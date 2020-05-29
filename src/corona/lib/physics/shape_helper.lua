-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


--用于快速得到形状坐标，方便生成五路
local S = {}

local Polygon = import("thirdparty.polygon.polygon")

--三角化一个形状
--@param shapePoints 形状坐标点
--@param physicOpts 物理属性
function S.triangulate(shapePoints, physicOpts)
  
    local p = Polygon(unpack(shapePoints))
    local ts = p:triangulate()
    local triangles = {}
    _.each(ts, function(t)
        local tmp = table.clone(physicOpts)
        tmp.shape = t:totable_reverse()

        table.insert(triangles, tmp)
    end)
     -- Log:dump(triangles)
    return triangles
end
--生成一个椭圆物理形状
--@usage
-- local pshape = helper.newEllipse(0, 0, 300, 500, {physic = {friction=0.2, bounce=0.4}})
-- physics.addBody(rect, "static", unpack(pshape))
--@param xOffset x偏移
--@param yOffset y偏移
--@param w       长度
--@param h       宽度
--@param opts   一个表，用于设置可选参数，包括 intensity 点的密集度，默认0.2, physic,物体的物理属性
function S.newEllipse(xOffset, yOffset, w, h , opts)
    local points = {}
    local opts = opts or {}

    opts.intensity = opts.intensity or 0.5
    opts.physic = opts.physic or {}
    local xc, yc, cos, sin, l = xOffset, yOffset, math.cos, math.sin, nil
    local s, e = 0, 360
    s, e = math.rad(s), math.rad(e)
    w, h = w / 2, h / 2
    for t = s, e, opts.intensity  do
        local nx = xc + w * cos(t)
        local ny = yc - h * sin(t)
        table.insert(points,  nx)
        table.insert(points,  ny)
--
      -- local screenText = display.newText(t, nx, ny, native.systemoFont, 30)
      --  screenText.alpha = .5
       -- screenText:setFillColor(uHexColor("#ff0000aa"))

    end

    return S.triangulate(points, opts.physic)

end

return S