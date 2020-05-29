-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local math_abs = math.abs

local PI = (4*math.atan(1))
local quickPI = 180 / PI
local atan2 = math.atan2
function angleOf( a, b )
	return atan2( b.y - a.y, b.x - a.x ) * quickPI -- 180 / PI -- math.pi
end
function angleOf2(ax, ay, bx, by)
	return atan2(by - ay, bx - ax) * quickPI
end

function lengthOf( a, b )
	local width, height = b.x-a.x, b.y-a.y
	return (width*width + height*height)^0.5
end
function lengthOf2( ax,ay, bx,by )
	local width, height = bx-ax, by-ay
	return (width*width + height*height)^0.5
end

function checkBoxIntersection(box1, box2)
	if box1.xMax<box2.xMin or
		box1.xMin>box2.xMax or
		box1.yMin>box2.yMax or
		box1.yMax<box2.yMin then
		return false
	end
	return true
end

function checkPointInBox(point, box)
	if point.x >= box.xMin and point.x <= box.xMax and
		point.y >= box.yMin and point.y <= box.yMax then
		return true
	end

	return false
end

function checkPointInBox2( x, y, box)
	if x >= box.xMin and x <= box.xMax and
		y >= box.yMin and y <= box.yMax then
		return true
	end

	return false
end

function clamp(value, min_inclusive, max_inclusive)
	return value < min_inclusive and min_inclusive or (value < max_inclusive and value or max_inclusive)
end

function clamp2(value, min_inclusive, max_inclusive)
	local flag = false
	local res = value
	if (value <= min_inclusive) then
		flag = true
		res = min_inclusive
	elseif (value >= max_inclusive) then
		flag = true
		res = max_inclusive
	end
	return res, flag
end

function clamp3( value, min_inclusive, max_inclusive )
	local flag = false
	if (value >= min_inclusive) and (value <= max_inclusive) then
		flag = true
	end
	return flag
end

function equalToZero(value, accuracy)
	local accuracy = accuracy or 0.0000001
	if math_abs(value - 0) < accuracy then
		return true
	end
	return false
end

function sign(num)
    return num > 0 and 1 or (num < 0 and -1 or 0)
end

function displayGroupIndexOf( displayGroup, displayObject, start )
	if not displayGroup then return 0 end
	start = start or 1

	for index = start, displayGroup.numChildren, 1 do
	  if displayObject == displayGroup[index] then
	    return index
	  end
	end

	return 0
end

function objectTransIn(target, params)
	params.delay = params.delay or 0
	params.time = params.time or 300
    target.flag = target.flag or 1
    local res = false
    if target.flag == 1 then
    	res = true
        target.flag = -1
        if params.transMgr then
        	params.transMgr:cancel( target )
        	params.transMgr:add(target, params)
        else
	        transition.cancel( target )
	        transition.to( target, params )
		end
    end
    return res
end

----------------------------------------------------------------
function objectTransOut(target, params)
	params.delay = params.delay or 0
	params.time = params.time or 300
    target.flag = target.flag or -1
    local res = false
    if target.flag == -1 then
    	res = true
        target.flag = 1
        if params.transMgr then
        	params.transMgr:cancel( target )
        	params.transMgr:add(target, params)
        else
	        transition.cancel( target )
	        transition.to( target, params )
		end
    end
    return res
end


function getOffsetFromParent( object )
	local x, y = object.x, object.y
	if object == display.currentStage then
		return x, y
	end
	local target = object.parent
	while (target ~= display.currentStage) do
		x = x + target.x
		y = y + target.y
		target = target.parent
	end

	return x, y
end

function angleTranslate(rotation)
	local angle = sign(rotation) * (math_abs(rotation) % 360)
	if angle > 180 then
	    angle = angle - 360
	elseif angle < -180 then
	    angle = 360 + angle
	end
	return angle
end

function getMassCenter(members)
    assert(#members > 0, "GetMassCenter Error! No members ")
    local mass = 0
    local x, y = 0, 0
    for i=1, #members do
        mass = mass + members[i].mass
    end
    for i=1, #members do
        local m = members[i]
        local mx, my = m:getMassWorldCenter()
        x = x + mx * m.mass
        y = y + my * m.mass
    end
    return x / mass, y / mass
end

--- Used for debug
function rangeDisplay( bounds )
	local x = (bounds.xMin + bounds.xMax) * 0.5
	local y = (bounds.yMin + bounds.yMax) * 0.5
	local w = bounds.xMax - bounds.xMin
	local h = bounds.yMax - bounds.yMin
	local rect = display.newRect( x, y, w, h )
	rect.fill = nil
	rect.strokeWidth = 5
	rect:setStrokeColor(1, 0, 0, 0.5)

	timer.performWithDelay(3000, function()
		rect:removeSelf()
	end)
	return rect
end

function pointDisplay(x, y)
	local dot = display.newCircle(x, y, 8)
	dot:setFillColor(1, 0, 0, 0.5)

	timer.performWithDelay(3000, function()
		dot:removeSelf()
	end)
	return dot
end

function logOnScreen(...)
	local args = {...}
	for i=1, #args do
	    args[i] = tostring(args[i])
	end
	local text = table.concat(args, " ")
	local txt = display.newText(text, _CX, _T + 100, native.systemFont, 80)
	txt:setFillColor(1, 0, 1, 1)
	-- _D(...)
	timer.performWithDelay(4000, function()
		txt:removeSelf()
	end)
end
