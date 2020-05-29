-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
bottomInset = topInset
_W      = display.contentWidth                 --屏幕宽度
_H      = display.contentHeight                --屏幕高度
_AW     = display.actualContentWidth - (leftInset + rightInset)
_AH     = display.actualContentHeight - (topInset + bottomInset)
_T      = display.screenOriginY + topInset
_B      = _T + _AH
_L      = display.screenOriginX + leftInset
_R      = _L + _AW
_RW     = _R - _L
_RH     = _B - _T
_CX     = display.contentCenterX
_CY     = display.contentCenterY

IPAD_SCALE = 1

local GodotGlobal = require("godot.godot_global")

pkgImport = GodotGlobal.pkgImport
currentPackage = GodotGlobal.currentPackage

EMPTY = function() end
SCREEN_BOUNDS = {
    xMin = _L,
    xMax = _R,
    yMin = _T,
    yMax = _B
}

function ppi(value)
    return IPAD_SCALE * value
end

function import(libName)
    return require("lib." .. libName)
end

--@param path = ...
--@param libNames {"a.test"}
--@usage: isubs(..., {"game_ui", "state.play", "state.idle")
function pkgImports(path, libNames)
    local libs = {}
    _.each(libNames, function(v, k)
        libs[k] = pkgImport(path, v)
    end)
    return unpack(libs)
end

function pack(...)
    return arg
end

require("lib.system_ext")

class = GodotGlobal.class
_ = GodotGlobal._

Node = import("graphics.node")

TouchManager = import("system.touch_manager_ext")

Image = require("app.lib.image")

Component = import("ui.component")

_HC = GodotGlobal.hexColor
_UC = GodotGlobal.unpackHexColor
uHexColor = GodotGlobal.unpackHexColor

_D = function(...)
    local args = {...}
    for i=1, #args do
        args[i] = tostring(args[i])
    end
    print(table.concat(args, ", "))
end

function displayGroupToArray(group)
    local array = {}
    for i=1, group.numChildren do
        array[i] = group[i]
    end
    return array
end

function _.gEach(group, func)
    for i=1, group.numChildren do
        func(group[i], i, group)
    end
end

function dictGet(t, key, default)
    local value = t[key]
    if value == nil then
        return default
    else
        return value
    end
end

function zoomObject(obj, range, scaleType)
    local scaleType = scaleType or "letterBox"
    local xScale = range[1] / obj.contentWidth
    local yScale = range[2] / obj.contentHeight
    if scaleType == "zoomEven" then
        local ratio = math.max(xScale, yScale)
        obj:scale(ratio, ratio)
    elseif scaleType == "letterBox" then
        local ratio = math.min(xScale, yScale)
        obj:scale(ratio, ratio)
    elseif scaleType == "zoomStretch" then
        obj:scale(xScale, yScale)
    elseif scaleType == "clamp" then
        local ratio = math.min(xScale, yScale)
        if ratio < 1 then
            obj:scale(ratio, ratio)
        end
    elseif scaleType == "clampToWidth" then
        local value = math.min(1, xScale)
        obj:scale(value, value)
    elseif scaleType == "clampToHeight" then
        local value = math.min(1, yScale)
        obj:scale(value, value)
    elseif scaleType == "zoomToWidth" then
        obj:scale(xScale, xScale)
    elseif scaleType == "zoomToHeight" then
        obj:scale(yScale, yScale)
    end
end
