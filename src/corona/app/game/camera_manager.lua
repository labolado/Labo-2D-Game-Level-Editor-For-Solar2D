-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local BaseCamera = import("game.camera")
local CameraManager = class("CameraManager", BaseCamera)

local pixelPerfectClamp = pixelPerfectClamp
function CameraManager:init(ctx, scale)
    local scaleValue = _RW * scale / display.contentWidth
    local lloader = ctx.levelLoader

    if ctx.bgLoader then
        ctx.bgLoader:addToCamera(self)
    end
    if ctx.bgCloudLoader then
        ctx.bgCloudLoader:addToCamera(self)
    end
    self:addLayer("foremost", lloader.foremost, 1.15, 1, 0.1, false, true, false)
    self:addLayer("frontCover", lloader.frontCover, 1, 1, 0, false, false, true)
    self:addLayer("front", lloader.front, 1)
    self:addLayer("grounds", lloader.grounds, 1)
    self:addLayer("player", lloader.player, 1)
    self:addLayer("behind", lloader.behind, 1)
    self:addLayer("backmost", lloader.backmost, 0.5, 1, 0.1, false, true, false)
    -- self:addLayer("background", lloader.background, 0.25, 1, 0.1, false, true, true)
    -- lloader.player:insert(1, ctx.car.particleParent)
    lloader.player:insert(1, ctx.car)
    -- self.particleParent = ctx.car.particleParent

    self:setFocus(ctx.car:getFocusObject()) -- Set the focus to the player

    self._position.y = self._position.y + 300 -- _CY
    self._position.x = self._position.x - 300 * scaleValue -- _CX

    self.lockX = false
    self.lockY = false

    -- zoom
    self.zoomFactor = 0
    self.controllableScale = false
    self.zoomCallbackOnce = nil
    self.zoomAnchor = {}
    self.scaleMin = 0.6
    self.limit = 1536
    self.body = ctx.car:getChassis()
    self.ctx = ctx
    self.initScaleValue = scaleValue
    self.originScale = 1
    -- self.startX = self.body.x
    -- self.startY = self.body.y + 300 * IPAD_PRO
    -- self.startY = self.body.y
end

function CameraManager:_calculateOffset()
    local x, y = self._focusObject:localToContent( 0, 0 )
    local tempX = self._position.x - x
    local tempY = self._position.y - y
    -- if (self._position.y > self._focusObject.y) then
    --     tempY = tempY
    -- else
    --     tempY = 0
    -- end
    -- self._position.x = self._focusObject.x
    -- self._position.y = self._focusObject.y
    -- local offset = { x = tempX, y = tempY }
    return tempX, tempY
    -- return pixelPerfectClamp(tempX, tempY)
end

function CameraManager:_layerMove(layer, xOffset, yOffset)
    BaseCamera._layerMove(self, layer, xOffset, yOffset)
    if layer.clampInfo then
        local bounds = layer.contentBounds
        local info = layer.clampInfo
        if bounds.yMin > info.yMin then
            local x, y = layer.coordinate:contentToLocal(0, info.yMin)
            -- layer:translate(0, y - layer.y)
            self.ctx.transMgr:cancel(layer)
            self.ctx.transMgr:add(layer, {time=300, y = y - 10})
        elseif bounds.yMax < info.yMax then
            local x, y = layer.coordinate:contentToLocal(0, info.yMax)
            -- layer:translate(0, y - layer.y)
            self.ctx.transMgr:cancel(layer)
            self.ctx.transMgr:add(layer, {time=300, y = y + 10})
        end
    end
end

function CameraManager:_layerScale(layer, scale, scaleAnchor)
    if layer.lockScale then return end
    local ratio = layer.scaleRatio
    local _ratio = 1 - ratio
    -- local _ratio = layer.moveRatio
    -- local ratio = 1 - _ratio
    local ratioScale = _ratio + scale * ratio
    -- layer:scale( ratioScale, ratioScale )

    if scaleAnchor == nil then
        scaleAnchor = {}
        scaleAnchor.x, scaleAnchor.y = self.body:localToContent(0, 0)
    end
    if layer.renderTarget then
        local x, y = self:_layerRenderTargetContentToLocal(layer, scaleAnchor.x, scaleAnchor.y)
        layer:scale(ratioScale, ratioScale)
        local tx, ty = self:_layerRenderTargetLocalToContent(layer, x, y)
        local lx, ly = self:_layerParentRenderTargetContentToLocal(layer, scaleAnchor.x, scaleAnchor.y)
        local ltx, lty = self:_layerParentRenderTargetContentToLocal(layer, tx, ty)
        layer:translate(lx - ltx, ly - lty)
    else
        local x, y = layer:contentToLocal(scaleAnchor.x, scaleAnchor.y)
        layer:scale(ratioScale, ratioScale)
        -- local w, h = pixelPerfectClamp(layer.contentWidth * ratioScale, layer.contentHeight * ratioScale)
        -- layer:scale(w / layer.contentWidth, h / layer.contentHeight)
        -- if layer.clampBackground then
        --     if layer.contentHeight < _RH then
        --         local sc = (_RH + 8 )/ layer.contentHeight
        --         layer:scale(sc, sc)
        --     end
        -- end
        local tx, ty = layer:localToContent(x, y)
        local lx, ly = layer.coordinate:contentToLocal(scaleAnchor.x, scaleAnchor.y)
        local ltx, lty = layer.coordinate:contentToLocal(tx, ty)
        layer:translate(lx - ltx, ly - lty)
        -- layer:translate(pixelPerfectClamp(lx - ltx, ly - lty))
    end

    if layer.clampInfo then
        local bounds = layer.contentBounds
        local info = layer.clampInfo
        if bounds.yMin > info.yMin then
            local x, y = layer.coordinate:contentToLocal(0, info.yMin)
            -- layer:translate(0, y - layer.y)
            self.ctx.transMgr:cancel(layer)
            self.ctx.transMgr:add(layer, {time=300, y = y})
        elseif bounds.yMax < info.yMax then
            local x, y = layer.coordinate:contentToLocal(0, info.yMax)
            -- layer:translate(0, y - layer.y)
            self.ctx.transMgr:cancel(layer)
            self.ctx.transMgr:add(layer, {time=300, y = y})
        end
    end
end

function CameraManager:start()
    -- local bgGroup = ctx.bgLoader.bgGroup
-- local scale = APP.config.game.sceneScale
    -- self.view:scale(scale, scale)
    local scale = self.initScaleValue
    self.view:scale(scale, scale)
    local ox, oy = self:_calculateOffset()
    -- _D("!CameraManager", ox, oy)
    self.view:translate(ox, oy)
    -- self:track()
end

function CameraManager:addLayer(name, layer, moveRatioX, moveRatioY, scaleRatio, lockX, lockY, lockScale)
    BaseCamera.addLayer(self, name, layer, moveRatioX, moveRatioY, scaleRatio, lockX, lockY, lockScale)
    layer.initMoveRatioX = layer.moveRatioX
    layer.initMoveRatioY = layer.moveRatioY
    layer.initTransfrom = {
        x = layer.x,
        y = layer.y,
        xScale = layer.xScale,
        yScale = layer.yScale
    }
    layer.coordinate = layer.coordinate or layer.parent
    -- layer.x, layer.y = pixelPerfectClamp(layer.x, layer.y)
end

function CameraManager:resetAllLayersTransform(except)
    for name, layer in pairs(self.layers) do
        if not (type(except) == "table" and _.include(except, name)) then
            layer.x = layer.initTransfrom.x
            layer.y = layer.initTransfrom.y
            layer.xScale = layer.initTransfrom.xScale
            layer.yScale = layer.initTransfrom.yScale
        end
    end
end

function CameraManager:getAllLayer()
    return self.layers
end

function CameraManager:getFocusObject()
    return self._focusObject
end

function CameraManager:lockXTracking(lockOrNot)
    if (not self.lockX) and lockOrNot then
        self.lockX = true
    elseif self.lockX and (not lockOrNot) then
        self.lockX = false
        self:faceTo(self._focusObject, 0.01)
    end
    _.each(self.layers, function(layer, name)
        -- if name ~= "cloud1" then
            layer.lockX = lockOrNot
        -- end
    end)
end

function CameraManager:lockYTracking(lockOrNot)
    if (not self.lockY) and lockOrNot then
        self.lockY = true
    elseif self.lockY and (not lockOrNot) then
        self.lockY = false
        -- self:faceTo(self._focusObject, 0.01)
    else
        return
    end
    _.each(self.layers, function(layer)
        -- if name ~= "cloud1" then
        if layer.clampInfo == nil then
            -- layer.lockY = lockOrNot
            local value = layer.initMoveRatioY
            local time = 3500
            local easingFunc
            if lockOrNot then
                value = 0
                time = 500
                easingFunc = easing.outCubic
            end
            self.ctx.transMgr:cancel(layer)
            self.ctx.transMgr:add(layer, {
                time = time,
                transition = easingFunc,
                moveRatioY = value
            })
        end
    end)
end

function CameraManager:faceTo(object, speedRatio, onComplete)
    self._focusObject = object
    local ox, oy = self:_calculateOffset()
    if equalToZero(ox, 4) and equalToZero(oy, 4) then
        return false
    end
    local spRatio = speedRatio
    self._faceToCall = function(cam)
        local ox, oy = cam:_calculateOffset()
        if equalToZero(ox, 4) and equalToZero(oy, 4) then
            cam._faceToCall = nil
            if onComplete then onComplete() end
            spRatio = 1
        end
        cam:_viewTracking(ox * spRatio, oy * spRatio)
        spRatio = clamp(spRatio * 1.05, 0, 1)
    end
    return true
end

local abs = math.abs
function CameraManager:zoom(spRatio)
    local res = false
    self.zoomAnchor.x, self.zoomAnchor.y = self.body:localToContent( 0, 0 )
    if self.startY == nil then
        self.startY = self.body.y
    end
    local distance = abs(self.body.y - self.startY)
    if distance > self.limit then
        local scale = self.originScale - (distance - self.limit) * 0.0006
        scale = clamp(scale, self.scaleMin, 1)
        local layerName = "grounds"
        self:scale(layerName, scale, self.zoomAnchor, spRatio, self.zoomCallbackOnce)
        res = true
    end
    return res
end

function CameraManager:setZoomFactor(factor)
    self.zoomFactor = factor
end

function CameraManager:scaleBy(factor, speed, callback)
    self.controllableScale = true
    self.zoomAnchor.x, self.zoomAnchor.y = self.body:localToContent( 0, 0 )
    self:registerZoomCallbackOnce(callback)
    if factor == 0 then
        local done = self:zoom(speed)
        if not done then
            self:scale("grounds", self.originScale, self.zoomAnchor, speed or 0.03, self.zoomCallbackOnce)
        end
    else
        self:scale("grounds", self.originScale + factor, self.zoomAnchor, speed or 0.03, self.zoomCallbackOnce)
    end
end

function CameraManager:registerZoomCallbackOnce(callback)
    if callback then
        self.zoomCallbackOnce = function()
            callback()
            self.zoomCallbackOnce = nil
            -- self.controllableScale = false
        end
    end
end

function CameraManager:setAutoScale(bool)
    self.controllableScale = not bool
end

function CameraManager:layer_position_clamping()
    -- for name, layer in pairs(self.layers) do
    --     if layer.renderTarget then
    --         local wx, wy = pixelPerfectClamp(self:_layerRenderTargetLocalToContent(layer, 0, 0))
    --         layer.x, layer.y = self:_layerParentRenderTargetContentToLocal(layer, wx, wy)
    --     else
    --         local wx, wy = pixelPerfectClamp(layer:localToContent(0, 0))
    --         layer.x, layer.y = layer.coordinate:contentToLocal(wx, wy)
    --     end
    -- end
end

function CameraManager:update()
    -- local xOffset, yOffset = self:_calculateOffset()
    BaseCamera.update(self)
    if not self.controllableScale then
        self:zoom(0.03)
    end
    -- self:layer_position_clamping()

    -- local layer = self.particleParent
    -- local wx, wy = layer:localToContent(0, 0)
    -- local twx, twy = wx + xOffset, wy + yOffset
    -- local lx, ly = layer.parent:contentToLocal(wx, wy)
    -- local tlx, tly = layer.parent:contentToLocal(twx, twy)
    -- layer:translate(lx - tlx, 0)
end

function CameraManager:pause()
    self:stopTrack()
end

function CameraManager:resume()
    self:track()
end
return CameraManager
