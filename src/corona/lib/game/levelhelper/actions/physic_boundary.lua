-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 添加物理边界
local Action = pkgImport(..., "base"):extend("physic_boundary", {
	{name = "enable", default = true, type = "bool", desc="表示添加或者删除"},
	{name = "left", default = true, type = "bool", desc=""},
	{name = "right", default = true, type = "bool", desc=""},
	{name = "top", default = true, type = "bool", desc=""},
	{name = "bottom", default = true, type = "bool", desc=""},
})

function Action.execute(ctx, params)
	local target = params.target
	local physics = ctx.physics
	if params.enable then
		if target.boundary then
			target.boundary:removeSelf()
		end
		local rect = display.newRect(0, 0, 10, 10)
		rect:setFillColor(1, 0, 0, 1)
		rect:translate(target.x, target.y)
		rect.isVisible=false
		target.parent:insert(rect)
		target.boundary = rect

		--[[
		回
		--]]
		local d1 = 30
		local d2 = 110
		local ax, ay = rect:contentToLocal(_L - d1, _T - d1)
		local bx, by = rect:contentToLocal(_R + d1, _T - d1)
		local cx, cy = rect:contentToLocal(_L - d1, _B + d1)
		local dx, dy = rect:contentToLocal(_R + d1, _B + d1)

		local ex, ey = rect:contentToLocal(_L - d2, _T - d2)
		local fx, fy = rect:contentToLocal(_R + d2, _T - d2)
		local hx, hy = rect:contentToLocal(_L - d2, _B + d2)
		local gx, gy = rect:contentToLocal(_R + d2, _B + d2)

	    local filter = { groupIndex = -1 }
	    local shapes = {}
		if params.left then
		    shapes[#shapes + 1] = { friction=0.8, bounce=0.0, filter = filter, shape={ex,ey, ax,ay, cx,cy, hx,hy} } -- left
		end
	    if params.right then
		    shapes[#shapes + 1] = { friction=0.2, bounce=0.4, filter = filter, shape={bx,by, fx,fy, gx,gy, dx,dy} } -- right
		end
	    if params.top then
		    shapes[#shapes + 1] = { friction=0.2, bounce=0.4, filter = filter, shape={ax,ay, ex,ey, fx,fy, bx,by} } -- top
		end
	    if params.bottom then
		    shapes[#shapes + 1] = { friction=0.8, bounce=0.0, filter = filter, shape={cx,cy, dx,dy, gx,gy, hx,hy} } -- bottom
		end
		physics.addBody(rect, "static", unpack(shapes))
		-- _D("physic_boundary", #shapes, tostring(params.left), tostring(params.right), tostring(params.top), tostring(params.bottom))
	else
		if target.boundary then
			target.boundary:removeSelf()
			target.boundary = nil
		end
	end
end

return Action