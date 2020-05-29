-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local FileUtil    = require("godot.lib.file_util")
local SceneHelper = require("app.lib.scene_helper")
local SceneInfo   = require("app.ui.scene_info")

local myScene = SceneHelper.createMyScene()

function myScene:onCreate(event)
    local scene = self
    local sceneGroup = self.view

    display.addFullScreenColorBackground(sceneGroup, _HC("#cdeff8ff"))

    local numObjects = 12
    local boundary = {
        xMin = _L + 100,
        xMax = _R - 100,
        yMin = _T + 100,
        yMax = _B - 100,
        paddingX = 0,
        paddingY = 0,
    }
    local row = 3
    local column = 4
    local moveW = _RW
    local moveH = _RH
    local rectW = boundary.xMax - boundary.xMin
    local rectH = boundary.yMax - boundary.yMin
    local w = rectW / column
    local h = rectH / row
    local dx = (rectW - column * w) / (column + 1)
    local dy = (rectH - row * h) / (row + 1)
    local xMin, yMin = boundary.xMin, boundary.yMin
    local d = dx
    if dx < dy then
        d = dx
        boundary.paddingY = (rectH - (row * h + (row + 1) * d)) * 0.5
        yMin = yMin + boundary.paddingY
    else
        d = dy
        boundary.paddingX = (rectW - (column * w + (column + 1) * d)) * 0.5
        xMin = xMin + boundary.paddingX
    end
    boundary.paddingX = boundary.paddingX + d
    boundary.paddingY = boundary.paddingY + d

    local n = 0
    for m = 1, numObjects, row * column do
        n = n + 1
        local xBegin = (n - 1) * moveW
        local yBegin = (n - 1) * moveH
        for i = 1, row do
            for j = 1, column do
                local x = xBegin + xMin + (j - 0.5) * w + j * d
                local y = yMin + (i - 0.5) * h + i * d
                local idx = (n - 1) * row * column + (i - 1) * column + j
                local bttn = self:createButton(idx)
                bttn:translate(x, y)
                sceneGroup:insert(bttn)
            end
        end
    end
end

function myScene:createButton(idx)
    local g = display.newGroup()
    local rect = display.newRoundedRect(g, 0, 0, 400, 400, 32)
    local text = display.newText(g, idx, 0, 0, native.systemFont, 100)
    text:setFillColor(0, 0, 0, 1)
    Component.add("button", g, {
        onRelease = function(e)
            -- logOnScreen(idx)
            if FileUtil:exists("assets/levels/export/level" .. idx .. ".json", system.ResourceDirectory) then
                SceneHelper.gotoScene(SceneInfo.game(idx))
            else
                SceneHelper.gotoScene(SceneInfo.game(1))
            end
        end
    })
    return g
end

function myScene:onHide(event)
    if event.phase == "will" then
    end
end

function myScene:onDestroy(event)
end

return myScene.getScene()
