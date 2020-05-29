-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


--@usage
-- local camera = Camera:new(parent)
-- camera:setBoundary(GE.ui.boundary)
-- camera:addLayer("bg", bkGroup, 0.3)
-- camera:addLayer("dog", bkGroup, 0.4)
-- camera:track()

local Camera = class("Camera")

function Camera:initialize(parent, ...)
    self.isTracking = false
    self.layers = {}
    self._position = { x = display.contentCenterX, y = display.contentCenterY }
    self.view = parent
    self._scaleCall = nil
    self.isScaling = false
    self.scaleParams = {}
    self._offset = {0, 0}
    self:init(...)
end

function Camera:init(...)
end

function Camera:getView()
    return self.view
end

function Camera:getCurrentOffset()
    return self._offset
end

function Camera:setPosition(x, y)
    self._position.x = x
    self._position.y = y
end

function Camera:translatePosition(x, y)
    self._position.x = self._position.x + x
    self._position.y = self._position.y + y
end

function Camera:setFocus(object, speedRatio, onComplete)
    if self._focusObject and object ~= self._focusObject then
        self:faceTo(object, speedRatio or 0.08, onComplete)
    else
        self._focusObject = object
        if type(onComplete) == "function" then onComplete() end
    end
end

function Camera:addLayer(name, layer, moveRatioX, moveRatioY, scaleRatio, lockX, lockY, lockScale)
    layer.moveRatioX = moveRatioX or 1
    layer.moveRatioY = moveRatioY or 1
    if moveRatioX == 0 and moveRatioY == 0 then
        layer.isDynamic = false
    else
        layer.isDynamic = true
    end
    layer.scaleRatio = scaleRatio or 1
    layer.lockX = lockX
    layer.lockY = lockY
    layer.lockScale = lockScale
    layer.coordinate = layer.coordinate or layer.parent
    self.layers[name] = layer
end

function Camera:getLayer(name)
    return self.layers[name]
end

function Camera:rmoveLayer(name)
    local layer = self.layers[name]
    -- local index = table.indexOf(self.layers, layer)
    -- layer:removeSelf()
    -- layer = nil
    -- table.remove(self.layers, index)
    self.layers[name] = nil
end

function Camera:setBoundary(boundary)
    self.boundary = boundary
end

function Camera:_layerMove(layer, xOffset, yOffset)
    if layer.lockX then
        xOffset = 0
    end
    if layer.lockY then
        yOffset = 0
    end
    if layer.renderTarget then
        self:_layerRenderTargetMove(layer, xOffset, yOffset)
    else
        local wx, wy = layer:localToContent(0, 0)
        local twx, twy = wx + xOffset * layer.moveRatioX, wy + yOffset * layer.moveRatioY
        local lx, ly = layer.coordinate:contentToLocal(wx, wy)
        local tlx, tly = layer.coordinate:contentToLocal(twx, twy)
        layer:translate(tlx - lx, tly - ly)
    end
end

function Camera:_layerParentRenderTargetContentToLocal(layer, x, y)
    return layer.coordinate:contentToLocal(layer.renderTarget.view:contentToLocal(x, y))
end

function Camera:_layerRenderTargetContentToLocal(layer, x, y)
    return layer:contentToLocal(layer.renderTarget.view:contentToLocal(x, y))
end

function Camera:_layerRenderTargetLocalToContent(layer, x, y)
    return layer.renderTarget.view:localToContent(layer:localToContent(x, y))
end

function Camera:_layerRenderTargetMove(layer, xOffset, yOffset)
    local wx, wy = self:_layerRenderTargetLocalToContent(layer, 0, 0)
    local twx, twy = wx + xOffset * layer.moveRatioX, wy + yOffset * layer.moveRatioY
    local lx, ly = self:_layerParentRenderTargetContentToLocal(layer, wx, wy)
    local tlx, tly = self:_layerParentRenderTargetContentToLocal(layer, twx, twy)
    layer:translate(tlx - lx, tly - ly)
end

function Camera:_layerScale(layer, scale, scaleAnchor)
    if layer.lockScale then return end
    local ratio = layer.scaleRatio
    local _ratio = 1 - ratio
    -- local _ratio = layer.moveRatio
    -- local ratio = 1 - _ratio
    local ratioScale = _ratio + scale * ratio
    layer:scale( ratioScale, ratioScale )
end

function Camera:_tracking(layer, xOffset, yOffset, scale)
    if (layer.isDynamic) then
        if scale then
            self:_layerScale(layer, scale)
        end
        self:_layerMove(layer, xOffset, yOffset)
    end
end

function Camera:_viewTracking( xOffset, yOffset, scale )
    _.each(self.layers, function(layer, name)
        self:_tracking(layer, xOffset, yOffset, scale)
    end)
end

function Camera:_calculateOffset()
    local x, y = self._focusObject:localToContent( 0, 0 )
    local tempX = self._position.x - x
    local tempY = self._position.y - y
    if (self._position.y > self._focusObject.y) then
        tempY = tempY
    else
        tempY = 0
    end
    -- self._position.x = self._focusObject.x
    -- self._position.y = self._focusObject.y
    -- local offset = { x = tempX, y = tempY }
    self._offset[1], self._offset[2] = tempX, tempY
    return tempX, tempY
end

--- 缩放镜头
-- @param mainLayerName player所在的组的名字
-- @param scale 缩放大小
-- @param scaleAnchor 缩放的锚点, 屏幕坐标 {x=number,y=number}
-- @param speedRatio 用于控制缩放的速度, 值为小数(0.03)
-- @param onComplete 完成时的回调
function Camera:_scaleCall()
    local mainLayerName = self.scaleParams.mainLayerName
    local scale = self.scaleParams.scale
    local scaleAnchor = self.scaleParams.scaleAnchor
    local spRatio = self.scaleParams.speedRatio
    local onComplete = self.scaleParams.onComplete
    local mainLayer = self:getLayer(mainLayerName)
    if equalToZero(scale - mainLayer.xScale, 0.009) then
        if self._faceToCall == nil then
            -- self.._scaleCall = nil
            self.isScaling = false
            if onComplete then
                onComplete()
                self.scaleParams.onComplete = nil
            end
        end
    end
    local nextScale = mainLayer.xScale + (scale - mainLayer.xScale) * spRatio
    local ratio = nextScale / mainLayer.xScale
    for name, layer in pairs(self.layers) do
        self:_layerScale(layer, ratio, scaleAnchor)
    end
end

function Camera:scale(mainLayerName, scale, scaleAnchor, speedRatio, onComplete)
    self.scaleParams.mainLayerName = mainLayerName
    self.scaleParams.scaleAnchor = scaleAnchor
    self.scaleParams.onComplete = onComplete
    self.isScaling = true
    self.scaleParams.scale = scale
    self.scaleParams.speedRatio = speedRatio
    return true
end

--- 调整镜头焦点
-- @param object focusPoint
-- @param speedRatio 用于控制镜头位移的速度, 值为小数(如 0.08)
-- @param onComplete 回调
function Camera:faceTo(object, speedRatio, onComplete)
    self._focusObject = object
    local ox, oy = self:_calculateOffset()
    if equalToZero(ox, 1) then
        return false
    end
    self._faceToCall = function(camera)
        local ox, oy = camera:_calculateOffset()
        local spRatio = speedRatio
        if equalToZero(ox, 1) then
            camera._faceToCall = nil
            if onComplete then onComplete() end
            spRatio = 1
        end
        camera:_viewTracking(ox * spRatio, oy * spRatio)
    end
    return true
end

function Camera:update()
    if self.isScaling then
        self:_scaleCall()
        -- return
    end
    if self._faceToCall then
        self:_faceToCall()
        return
    end
    local ox, oy = self:_calculateOffset()
    self:_viewTracking(ox, oy)
end

function Camera:moveToxMin(time, screenW, screenH)
    local boundary = self.boundary
    local offset = (boundary.width - screenW) - 60
    self.view.x = self.view.x + offset
    -- transition.to( self.view, { x = self.view.x + offset, time = time })
    for name, layer in pairs(self.layers) do
        if (layer.isDynamic) then
            -- transition.to( layer, { x = layer.x - offset * layer.moveRatio, time = time })
            layer.x = layer.x - offset * layer.moveRatioX
        end
    end
end

function Camera:moveToxMax(time, screenW, screenH)
    local boundary = self.boundary
    local offset = (boundary.width - screenW) - 60
    self.view.x = self.view.x - offset
    -- transition.to( self.view, { x = self.view.x - offset, time = time })
    for name, layer in pairs(self.layers) do
        if (layer.isDynamic) then
            -- transition.to( layer, { x = layer.x + offset * layer.moveRatio, time = time })
            layer.x = layer.x + offset * layer.moveRatioX
        end
    end
end

function Camera:track()
    if not self.isTracking then
        Runtime:addEventListener("enterFrame", self)
        self.isTracking = true
    end
end

function Camera:stopTrack()
    if self.isTracking then
        Runtime:removeEventListener("enterFrame", self)
        self.isTracking = false
    end
end

function Camera:enterFrame()
    self:update()
end

function Camera:removeSelf()
    self:stopTrack()
    if (self.view ~= nil) then
        display.cleanGroup(self.view)
        self.view = nil
    end
    self.layers = nil
    for k,v in pairs(self) do
        self[k] = nil
    end
end

return Camera
