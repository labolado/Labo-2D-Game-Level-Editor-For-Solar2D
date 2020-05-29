-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Parser = class("Parser")

local Helper = pkgImport(..., "helper")
local ActionMgr = pkgImport(..., "action_manager")
local Signal = import("game.signal")

local _push = _.push
local str_format = string.format
local tostring, assert = tostring, assert
local getWorldPosition = display.getWorldPosition
local findLevelObject = Helper.findLevelObject

local function addCollideWithTrigger(ctx, sigName, lhObject, target)
    local count = 0
    local collision
    collision = function(e)
        local other = e.other
        -- local mine = e.target
        if other == target then
            if e.phase == "began" then
                if count == 0 then
                    if sigName:find("_collide_with_ended") == nil then
                        ctx.timerMgr:setTimeout(10, function()
                            ctx.customSignal.emit(sigName, lhObject)
                            if sigName:find("repeatable") == nil then
                                lhObject:removeEventListener( "collision", collision )
                                count = nil
                            end
                        end)
                    end
                end
                count = count + 1
            elseif e.phase == "ended" then
                count = count - 1
                if count == 0 then
                    if sigName:find("_collide_with_ended") ~= nil then
                        ctx.timerMgr:setTimeout(10, function()
                            ctx.customSignal.emit(sigName, lhObject)
                            if sigName:find("repeatable") == nil then
                                lhObject:removeEventListener( "collision", collision )
                                count = nil
                            end
                        end)
                    end
                end
            end
        end
    end
    lhObject:addEventListener( "collision", collision )
end

local function addTouchTrigger(ctx, object)
    local touch
    touch = function(e)
        if e.phase == "began" then
            ctx.customSignal.emit("on_" .. tostring(object) .. "_touch", object)
            object:removeEventListener("touch", touch)
        end
    end
    object:addEventListener("touch", touch)
end

local function addCounterTrigger(ctx, sigName, lhObject, str)
    local value = str:match("value=([^;]+)")
    local newStr = str
    if value then
        value = tonumber(value)
        lhObject.actionCounterValue = 0
        function lhObject:enterFrame(e)
            if self.actionCounterValue == value then
                ctx.customSignal.emit(sigName, lhObject)
                if sigName:find("repeatable") == nil then
                    Runtime:removeEventListener("enterFrame", self)
                    table.remove(ctx.counters[lhObject.loaderID], lhObject)
                end
            end
        end
        Runtime:addEventListener("enterFrame", lhObject)

        local t = ctx.counters[lhObject.loaderID] or {}
        _push(t, lhObject)
        ctx.counters[lhObject.loaderID] = t
        newStr = str:gsub("value=[^;]+;", "")
    end
    return newStr
end

local function collidedWithDecode(ctx, sigName, lhObject, str)
    local with = str:match("with=([^;]+)")
    local newStr = str
    if with then
        local target = findLevelObject(ctx, with, lhObject.loaderID)
        assert(target ~= nil, "OnCollidedWith target " .. with .. " not exist in " .. lhObject.levelName)
        target.hasCollidedWith = false
        addCollideWithTrigger(ctx, sigName, lhObject, target)
        -- newStr = str:gsub("with=" .. with .. ";", "")
        newStr = str:gsub("with=[^;]+;", "")
    end
    return newStr
end

local function onCarCollidedDecode(ctx, sigName, lhObject, str)
    local from = ""
    local newStr = str
    local prefix = str:match("from=([^;]+)")
    if prefix then
        from = "_" .. prefix .. "_"
        newStr = str:gsub("from=[^;]+;", "")
    end
    -- _D("from=" .. from)
    -- _D("order=" .. newStr)
    return from, newStr
end

local function encodeActionsInfo(actionStr)
    local t = {}
    local i = 1
    local newStr = actionStr:gsub("%b{}", function(v)
      local m = ("{%d}"):format(i)
      t[i] = v
      i = i + 1
      -- return ("{%d}"):format(i-1)
      return m
    end)
    return newStr, t
end

local function decodeActionInfo(str, t)
    local m = str:match("{(%d+)}")
    local newStr = str
    if m ~= nil then
       newStr = str:gsub(str, t[tonumber(m)])
    end
    return newStr
end

local function actionParser(ctx, lhObject, actionStr, key)
    local newActionStr, replaceInfo = encodeActionsInfo(actionStr)
    -- local actions = _.split(newActionStr, ";")
    local actions = newActionStr:fastSplit("[^;]+")
    local curActions = lhObject.actions[key] or {}
    -- _.each(actions, function(actInfo)
    for n=1, #actions do
        local actInfo = actions[n]
        if #curActions < #actions then
            -- local actPropeties = _.split(actInfo, ",")
            local actPropeties = actInfo:fastSplit("[^,]+")
            local properties = {}
            for i=2, #actPropeties do
                local key, value = actPropeties[i]:match("(.*)=(.*)")
                if key ~= nil and value ~= nil then
                    -- properties[key] = value
                    properties[key] = decodeActionInfo(value, replaceInfo)
                end
            end
            local target = lhObject
            local hasTargetProp = false
            if properties.target then
                local customTarget = findLevelObject(ctx, properties.target, lhObject.loaderID)
                assert(customTarget ~= nil, "target " .. properties.target .. " not exist in " .. lhObject.levelName .. " (!" .. lhObject.lhUniqueName .. ")")
                target = customTarget or lhObject
                hasTargetProp = true
            end
            properties.targetAltering = not (target == lhObject)
            properties.hasTargetProp = hasTargetProp
            -- properties.originalTarget = lhObject
            local act = ActionMgr.create(ctx, actPropeties[1], target, properties )
            curActions[#curActions + 1] = act
        end
    end
    lhObject.actions[key] = curActions
end

local function _addTable(self, ctx, name)
    if ctx[name] == nil then
        local t = {}
        ctx[name] = t
    end
    self[name] = ctx[name]
end

local function _addSignal(self, ctx, name)
    if ctx[name] == nil then
        local s = Signal:new()
        ctx[name] = s
    end
    self[name] = ctx[name]
end

function Parser:initialize(ctx)
    self.ctx = ctx
    self.sigs = {}

    _addTable(self, ctx, "physicsJoints")
    _addTable(self, ctx, "spineObjects")
    _addTable(self, ctx, "allWater")
    _addTable(self, ctx, "weather")
    _addTable(self, ctx, "particles")
    _addTable(self, ctx, "physicsParticles")
    _addTable(self, ctx, "miniGames")
    _addTable(self, ctx, "insertedGames")
    _addTable(self, ctx, "counters")
    _addTable(self, ctx, "variables")
    _addTable(self, ctx, "enterFrames")
    _addTable(self, ctx, "npcs")
    -- _addTable(self, ctx, "drawLayers")
    -- _addTable(self, ctx, "dialogs")
    _addSignal(self, ctx, "customSignal")
    _addSignal(self, ctx, "actionSignal")
end

function Parser:parse(lhObject)
    local ctx = self.ctx
    if lhObject.lhUserCustomInfo then
        local customInfo = lhObject.lhUserCustomInfo
        lhObject.actions = {}
        -- _.each(customInfo, function(v, k)
        local objectId = tostring(lhObject)
        for k, v in pairs(customInfo) do
            if v ~= "" then
                v = v:gsub("%s", "") -- 去掉空格
                local sigName
                if k == "setTag" then
                    -- sgName = "set_" .. tostring(lhObject) .. "_tag"
                    sigName = str_format("set_%s_tag", objectId)
                elseif k == "onLoad" then
                    -- sigName = "on_" .. objectId .. "_load"
                    sigName = str_format("on_%s_load", objectId)
                elseif k == "onRoleCollied" or k == "onRoleCollied1"  then
                    local from, newValue = onCarCollidedDecode(ctx, sigName, lhObject, v)
                    v = newValue
                    -- sigName = "on_" .. objectId .. from .. "_collide"
                    sigName = str_format("on_%s%s_collide", objectId, from)
                    lhObject.collidedWithCarStart = true
                    lhObject.collideCount = 0
                elseif k == "onCarEnd" or k == "onCarEnd1" then
                    local from, newValue = onCarCollidedDecode(ctx, sigName, lhObject, v)
                    v = newValue
                    -- sigName = "on_" .. objectId .. from .. "_collide_ended"
                    sigName = str_format("on_%s%s_collide_ended", objectId, from)
                    lhObject.collidedWithCarEnd = true
                    lhObject.collideCount = 0
                elseif k == "onRepeatableCollided" or k == "onRepeatableCollided1" then
                    local from, newValue = onCarCollidedDecode(ctx, sigName, lhObject, v)
                    v = newValue
                    -- sigName = "on_" .. objectId .. from .. "_repeatable_collide"
                    sigName = str_format("on_%s%s_repeatable_collide", objectId, from)
                    lhObject.collideCount = 0
                elseif k == "onReCarEnd" or k == "onReCarEnd1" then
                    local from, newValue = onCarCollidedDecode(ctx, sigName, lhObject, v)
                    v = newValue
                    -- sigName = "on_" .. objectId .. from .. "_repeatable_collide_ended"
                    sigName = str_format("on_%s%s_repeatable_collide_ended", objectId, from)
                    lhObject.collideCount = 0
                elseif k == "onCollidedWith" then
                    -- sigName = "on_" .. objectId .. "_collide_with_began"
                    sigName = str_format("on_%s_collide_with_began", objectId)
                    v = collidedWithDecode(ctx, sigName, lhObject, v)
                elseif k == "onCollidedWithEnded" then
                    -- sigName = "on_" .. objectId .. "_collide_with_ended"
                    sigName = str_format("on_%s_collide_with_ended", objectId)
                    v = collidedWithDecode(ctx, sigName, lhObject, v)
                elseif k == "onRptCollidedWith" then
                    -- sigName = "on_" .. objectId .. "_repeatable_collide_with_began"
                    sigName = str_format("on_%s_repeatable_collide_with_began", objectId)
                    v = collidedWithDecode(ctx, sigName, lhObject, v)
                elseif k == "onRptCollidedWithEnded" then
                    -- sigName = "on_" .. objectId .. "_repeatable_collide_with_ended"
                    sigName = str_format("on_%s_repeatable_collide_with_ended", objectId)
                    v = collidedWithDecode(ctx, sigName, lhObject, v)

                elseif k == "onTouch" then
                    -- sigName = "on_" .. objectId .. "_touch"
                    sigName = str_format("on_%s_touch", objectId)
                    -- if v ~= "" then
                        addTouchTrigger(ctx, lhObject)
                        -- _D(sigName)
                    -- end
                elseif k == "onButtonPress" then
                    -- sigName = "on_" .. objectId .. "_button_press"
                    sigName = str_format("on_%s_button_press", objectId)
                    local component = Component.add("button", lhObject)
                    component:sigRegister(component.SIG_ON_PRESS, function(e)
                        ctx.customSignal.emit(sigName, lhObject)
                    end)
                elseif k == "onButtonRelease" then
                    -- sigName = "on_" .. objectId .. "_button_release"
                    sigName = str_format("on_%s_button_release", objectId)
                    local component = Component.add("button", lhObject)
                    component:sigRegister(component.SIG_ON_RELEASE, function(e)
                        ctx.customSignal.emit(sigName, lhObject)
                    end)
                    component:sigRegister(component.SIG_ENSURE, function(e)
                        ctx.customSignal.emit(sigName, lhObject)
                    end)
                elseif k == "onPlayerTrigger" then
                    -- sigName = "on_" .. objectId .. "_player_trigger"
                    sigName = str_format("on_%s_player_trigger", objectId)
                elseif k == "onCamera" then
                    -- sigName = "on_" .. objectId .. '_camera'
                    sigName = str_format("on_%s_camera", objectId)
                elseif k == "onCounter" then
                    -- sigName = "on_" .. objectId .. "_counter"
                    sigName = str_format("on_%s_counter", objectId)
                    v = addCounterTrigger(ctx, sigName, lhObject, v)
                elseif k == "onRptCounter" then
                    -- sigName = "on_" .. objectId .. "_repeatable_counter"
                    sigName = str_format("on_%s_repeatable_counter", objectId)
                    v = addCounterTrigger(ctx, sigName, lhObject, v)
                end
                ctx.customSignal.register(sigName, function(lhObject)
                    local curActions = lhObject.actions[k]
                    for n=1, #curActions do
                        local act = curActions[n]
                        act:execute()
                    end
                    -- _.each(lhObject.actions[k], function(act)
                    --     act:execute()
                    -- end)
                end)
                actionParser(ctx, lhObject, v, k)
                _push(self.sigs, {sigName, lhObject, v})
            end
        end
    end
end

function Parser:register(allSprites)
    self:parseAndRegister(allSprites)
    self:addCarCollisionTrigger(self.ctx, self.ctx.car)
end

function Parser:parseAndRegister(sprites)
    local ctx = self.ctx
    -- _.each(sprites, function(obj)
    for i=1, #sprites do
        local obj = sprites[i]
        self:parse(obj)
    end
    -- Runtime:addEventListener("enterFrame", self)
    local delete = {}
    -- _.each(self.sigs, function(sig)
    local sigs = self.sigs
    for i=1, #sigs do
        local sig = sigs[i]
        if sig[1]:match("on_.*_load") then
            -- ctx.customSignal.emit(unpack(sig))
            delete[#delete + 1] = sig
        end
    end
    for i=1, #delete do
        table.remove(sigs, delete[i])
    end
    for i=1, #delete do
        ctx.customSignal.emit(unpack(delete[i]))
        ctx.customSignal.clear_name(delete[i][1])
    end
end

function Parser:addCarCollisionTrigger(ctx, role)
    -- local ctx = self.ctx
    self.triggerListener = function(e)
        -- customSignal
        local other = e.other

        -- 可重复碰撞
        -- _D("PARSER collision = " .. e.phase)
        if other.collideCount then
            if e.phase == "began" then
                if other.collideCount == 0 then
                    -- local sigName = "on_" .. tostring(other)
                    local sigName = tostring(other)
                    local x0, y0 = getWorldPosition(role)
                    local x1, y1 = other:localToContent(0, 0)
                    local from = "_left_"
                    if x0 > x1 then
                        from = "_right_"
                    end
                    local yFrom = "_top_"
                    if y0 > y1 then
                        yFrom = "_bottom_"
                    end
                    if other.collidedWithCarStart then
                        local signal = ctx.customSignal
                        -- if signal.hasRegistered(sigName .. "_collide") or
                        --     signal.hasRegistered(sigName .. from .. "_collide") or
                        --     signal.hasRegistered(sigName .. yFrom .. "_collide") then
                        local a = str_format("on_%s_collide", sigName)
                        local b = str_format("on_%s%s_collide", sigName, from)
                        local c = str_format("on_%s%s_collide", sigName, yFrom)
                        if signal.hasRegistered(a) or signal.hasRegistered(b) or signal.hasRegistered(c) then
                            other.collidedWithCarStart = false
                            ctx.timerMgr:setTimeout(20, function()
                                signal.emit(a, other)
                                signal.emit(b, other)
                                signal.emit(c, other)
                            end)
                        end
                    else
                        ctx.timerMgr:setTimeout(20, function()
                            -- ctx.customSignal.emit(sig[1], sig[2], sig[3])
                            local a = str_format("on_%s_repeatable_collide", sigName)
                            local b = str_format("on_%s%s_repeatable_collide", sigName, from)
                            local c = str_format("on_%s%s_repeatable_collide", sigName, yFrom)
                            ctx.customSignal.emit(a, other)
                            ctx.customSignal.emit(b, other)
                            ctx.customSignal.emit(c, other)
                        end)
                    end
                end
                other.collideCount = other.collideCount + 1
            elseif e.phase == "ended" then
                other.collideCount = other.collideCount - 1
                if other.collideCount == 0 then
                    -- local sigName = "on_" .. tostring(other)
                    local sigName = tostring(other)
                    local x0, y0 = getWorldPosition(role)
                    local x1, y1 = other:localToContent(0, 0)
                    local from = "_left_"
                    if x0 > x1 then
                        from = "_right_"
                    end
                    local yFrom = "_top_"
                    if y0 > y1 then
                        yFrom = "_bottom_"
                    end
                    if other.collidedWithCarEnd then
                        local signal = ctx.customSignal
                        local a = str_format("on_%s_collide_ended", sigName)
                        local b = str_format("on_%s%s_collide_ended", sigName, from)
                        local c = str_format("on_%s%s_collide_ended", sigName, yFrom)
                        if signal.hasRegistered(a) or signal.hasRegistered(b) or signal.hasRegistered(c) then
                            other.collidedWithCarEnd = false
                            ctx.timerMgr:setTimeout(20, function()
                                signal.emit(a, other)
                                signal.emit(b, other)
                                signal.emit(c, other)
                            end)
                        end
                    else
                        ctx.timerMgr:setTimeout(20, function()
                            local a = str_format("on_%s_repeatable_collide_ended", sigName)
                            local b = str_format("on_%s%s_repeatable_collide_ended", sigName, from)
                            local c = str_format("on_%s%s_repeatable_collide_ended", sigName, yFrom)
                            ctx.customSignal.emit(a, other)
                            ctx.customSignal.emit(b, other)
                            ctx.customSignal.emit(c, other)
                        end)
                    end
                end
            end
        end
    end
    role:addCollisionCallBack(self.triggerListener)
end

function Parser:clearSignal(lhObject)
    local ctx = self.ctx
    local str = tostring(lhObject)
    ctx.customSignal.clear_name(str_format("on_%s_tag", str))
    ctx.customSignal.clear_name(str_format("on_%s_load", str))
    ctx.customSignal.clear_name(str_format("on_%s_collide", str))
    ctx.customSignal.clear_name(str_format("on_%s_repeatable_collide", str))
    ctx.customSignal.clear_name(str_format("on_%s_repeatable_collide_ended", str))
    ctx.customSignal.clear_name(str_format("on_%s_collide_with_began", str))
    ctx.customSignal.clear_name(str_format("on_%s_collide_with_ended", str))
    ctx.customSignal.clear_name(str_format("on_%s_repeatable_collide_with_began", str))
    ctx.customSignal.clear_name(str_format("on_%s_repeatable_collide_with_ended", str))
    ctx.customSignal.clear_name(str_format("on_%s_touch", str))
    ctx.customSignal.clear_name(str_format("on_%s_button_press", str))
    ctx.customSignal.clear_name(str_format("on_%s_button_release", str))
    ctx.customSignal.clear_name(str_format("on_%s_player_trigger", str))
    ctx.customSignal.clear_name(str_format("on_%s_counter", str))
    ctx.customSignal.clear_name(str_format("on_%s_repeatable_counter", str))
    ctx.customSignal.clear_name(str_format("on_%s_place_doodle", str))
    ctx.customSignal.clear_name(str_format("on_%s_doodle_complete", str))
end

function Parser:replaceTarget(originalTarget, newTarget)
    local sigs = self.sigs
    local pairs = pairs
    local replace = function(lhObj, oldObj, newObj)
        for k,acts in pairs(lhObj.actions) do
            for j=1, #acts do
                local act = acts[j]
                if act.target == oldObj then
                    _D("FIND", tostring(act.name))
                    act.target = newObj
                end
            end
        end
        if lhObj.collidedWidthTarget == oldObj then
            lhObj.collidedWidthTarget = newObj
        end
    end
    for i=1, #sigs do
        local sig = sigs[i]
        local lhObject = sig[2]
        replace(lhObject, originalTarget, newTarget)
    end
    -- replace(originalTarget, originalTarget, newTarget)
end


local function _remove(self, name)
    local t = self[name]
    if t then
        for i=1, #t do
            t[i]:removeSelf()
        end
    end
end

local function _removeDict(self, name)
    local t = self[name]
    if t then
        for k, v in pairs(t) do
            v:removeSelf()
            t[k] = nil
        end
    end
end

function Parser:removeSelf()
    local ctx = self.ctx
    -- Runtime:removeEventListener( "enterFrame", self )
    if self.customSignal then
        self.customSignal.clear_all()
    end
    if self.actionSignal ~= nil then
        self.actionSignal.clear_all()
    end
    if ctx.mdragger ~= nil then
        --ctx.actionSignal:emit("disable_drag")
        ctx.mdragger = ctx.mdragger:removeSelf()
        ctx.mdragger = nil
    end
    if self.physicsJoints then
        _.each(self.physicsJoints, function(joint)
            joint:removeSelf()
        end)
    end
    if self.spineObjects then
        _.each(self.spineObjects, function(spineInfo)
            spineInfo:clear()
        end)
    end
    if self.counters then
        _.each(self.counters, function(t)
            for i=1, #t do
                Runtime:removeEventListener("enterFrame", t[i])
            end
        end)
    end
    _remove(self, "enterFrames")
    _remove(self, "allWater")
    _removeDict(self, "weather")
    _removeDict(self, "npcs")
    _removeDict(self, "particles")
    _remove(self, "miniGames")
    _remove(self, "insertedGames")
    _remove(self, "physicsParticles")
    -- _remove(self, "drawLayers")
    _remove(self, "dialogs")

    ctx.transMgr:cancelAll()
    ctx.timerMgr:cancelAll()
    -- graphics.releaseTextures({type = "canvas"})
    for k,v in pairs(self) do
        self[k] = nil
    end
end

Parser.static.encodeActionsInfo = encodeActionsInfo
Parser.static.decodeActionInfo = decodeActionInfo

return Parser
