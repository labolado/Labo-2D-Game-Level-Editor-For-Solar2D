-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- 实现了多点触摸状态下的 对指定拖拉效果
-- usage:
--  local mdrag = MDrag:new(1000)
--  mdrag:start()
--  mdrag:addObject(xx)


local PhysicTranslator = import("physics.physic_object_translator")
local PhysicMToucher = import("physics.physic_mtoucher")

local  abs = math.abs
local MDrag = {}


--


function MDrag:new(force, parent)

    local Dragger = {}
    local removed = false
    Dragger._dragObjects = {}
    Dragger._mtouchers = {}
    Dragger.offsetX = 0
    Dragger.offsetY = 0
    Dragger.isDebug = false
    Dragger.parent = parent
    Dragger._touchListeners = {}
    Dragger.force = force

    function Dragger:start()
    end


    -- --更新拖拉点的偏移
    -- function Dragger:updateOffset(offsetX, offsetY)
    --     self.offsetX = offsetX or 0
    --     self.offsetY = offsetY or 0

    --     --Log:debug("updateOffset")

    --     _.each(self._mtouchers, function(mt)

    --         mt:updateOffset(offsetX, offsetY)
    --     end)
    -- end

      local events = {}

    -- 取消当前正在执行的事件
    function Dragger:cancel()
        local this = self
        _.each(events, function(v, k)
            if v == nil then return end
            local ce = {}
            ce.phase = 'cancelled'
            ce.id = k
            ce.target = v:getObject()
            this:touch(ce)
        end)

    end




    function Dragger:touch(e)
        local target = e.target
        if removed == true then return end
        local ox, oy = getOffsetFromParent(target.parent)
        local xs, ys = display.getWorldScale(target.parent)
        local xs, ys = abs(xs), abs(ys)

        if e.phase == 'began' then
            self:onObjectTouchBegan(e)
            local x0, y0 = target.parent:contentToLocal(e.x, e.y)
            local pt = PhysicTranslator:new(target, { maxForce = self.force, x = x0, y = y0})
            events[e.id] = pt
        end
        if events[e.id] ~= nil then
            if e.phase == 'moved' then
                -- events[e.id]:translate((e.x - ox )/xs - target.x, (e.y - oy)/ys - target.y)
                -- local px, py = target.parent:contentToLocal(e.x, e.y)
                local pt = events[e.id]
                -- pt:translate(px - pt.initPos.x, py - pt.initPos.y)
                pt:translateTo(target.parent:contentToLocal(e.x, e.y))
                self:onObjectTouchMove(e)
            end

            if e.phase == 'ended' or e.phase == 'cancelled' then
                events[e.id]:removeSelf()
                events[e.id] = nil
                self:onObjectTouchEnd(e)
            end
        end
    end


    function Dragger:setDebug(bool)
        self.isDebug = bool

    end


    function Dragger:debug(msg)
        if self.isDebug == true then
            -- Log:debug("mtouch_dragger debug:" .. msg)
        end
    end



    --添加一个时间监听
    --可以添加一个function或一个object,如果是object的话，需要提供 onPMDrag 方法才行
    --@param funcOrObject 一个监听函数或者 object,Object必须带有   onPMDrag方法
    function Dragger:addListener(funcOrObject)
        table.insert(self._touchListeners, funcOrObject)

    end

    function Dragger:removeListener(func)
        table.removeElement(self._touchListeners, func)
        removed = true
    end

    --添加一个可拖拉的对象
    function Dragger:addObject(obj)
        obj.mdrag_id = #self._dragObjects + 1 .. ""
        table.insert(self._dragObjects, obj)
        local pmt = PhysicMToucher:new(obj, self.parent, self)
        pmt:updateOffset(self.offsetX, self.offsetY)
        table.insert(self._mtouchers,  pmt)
    end

    function Dragger:getObjects()
        return self._dragObjects
    end




    --删除一个对象
    function Dragger:removeObject(obj)
        self:cancel()
        local tmts = _.select(self._mtouchers, function(m) return m.getObject() == obj end)
        if #tmts > 0 then
            table.removeElement(self._dragObjects, obj)
            obj:removeEventListener("touch", obj)
            tmts[1]:removeSelf()
            table.removeElement(self._mtouchers, tmts[1])
            tmts[1] = nil
        end
    end



    function Dragger:_callListeners(event)
        _.each(self._touchListeners, function(l)
            if type(l) == 'function' then
                l(event)
            end
            if type(l) == 'table' then
                l:onPMDrag(event)
            end
        end)
    end


    function Dragger:onObjectTouchBegan(obj)
        --self:debug("touch began")
        if obj ~= nil then
            -- local evt = {}
            -- evt.target = obj
            -- evt.phase = "began"

            --obj._touchListener(evt)
            self:_callListeners(obj)
        end
    end

    function Dragger:onObjectTouchMove(obj)
        if obj ~= nil then
            -- local evt = {}
            -- evt.target = obj
            -- evt.phase = "moved"
            -- evt.x = x
            -- evt.y = y
            self:_callListeners(obj)
        end
    end

    function Dragger:onObjectTouchEnd( obj)
        --self:debug("touch end")
        if obj ~= nil then

            -- local evt = {}
            -- evt.target = obj
            -- evt.phase = phase
            self:_callListeners(obj)
        end
    end


    --清除所有
    function Dragger:removeSelf()
        _.each(events, function(v, k)
            events[k] = nil
        end)
        Runtime:removeEventListener("touch", self)
        while #self._dragObjects > 0 do
            self:removeObject(self._dragObjects[#self._dragObjects])
        end
        table.removeAllElements(self._touchListeners)
    end

    return Dragger
end

return MDrag

---- 实现了多点触摸状态下的 对指定拖拉效果
---- usage:
----  local mdrag = MDrag:new(1000)
----  mdrag:start()
----  mdrag:addObject(xx)
--
--
--local MDrag = {}
--
--local MTD = import("system.mtouch_dragger")
--local PhysicTranslator = import("physics.physic_object_translator")
--local PhysicMToucher = import("physics.physic_mtoucher")
----
--
--
--
--
--
--
----多点拖拉
---- @param force 拖拉的最大力度
--function MDrag:new(force)
--
--    local Dragger = {}
--
--
--    Dragger._dragObjects = {}
--    Dragger._dragingObjects = {}
--    Dragger._collisionPoints = {}
--    Dragger.offsetX = 0
--    Dragger.offsetY = 0
--    Dragger.isDebug = false
--    Dragger.force = force
--    Dragger.parent = parent
--
--
--    Dragger._touchListeners = {}
--
--    Dragger._mtd = MTD:new()
--
--
--
--
--
--    function Dragger:setDebug(bool)
--        self.isDebug = bool
--    end
--
--
--    function Dragger:debug(msg)
--        if self.isDebug == true then
--            Log:debug("pmdrager:" .. msg)
--        end
--    end
--
--    function Dragger:start()
--        --Runtime:addEventListener("touch", self)
--    end
--
--    --添加一个时间监听
--    --可以添加一个function或一个object,如果是object的话，需要提供 onPMDrag 方法才行
--    --@param funcOrObject 一个监听函数或者 object,Object必须带有   onPMDrag方法
--    function Dragger:addListener(funcOrObject)
--        table.insert(self._touchListeners, funcOrObject)
--    end
--
--    function Dragger:removeListener(func)
--        table.removeElement(self._touchListeners, func)
--    end
--
--    --添加一个可拖拉的对象
--    function Dragger:addObject(obj)
--        obj.mdrag_id = #self._dragObjects + 1 .. ""
--        table.insert(self._dragObjects, obj)
--        local this = self
--
--        function obj:touch(event)
--            local body = event.target
--            if body ~= self then
--                return
--            end
--
--            body["events"] = body["events"] or {}
--            body["events"][event.id] = body["events"][event.id] or {}
--            local phase = event.phase
--            local stage = display.getCurrentStage()
--
--
--            if "began" == phase then
--                if body["events"][event.id].tempJoint ~= nil then
--                    return
--                end
--
--                --            if total_number_of_joints_created > 0 then
--                --                -- Nothing to do.
--                --                --
--                --                -- This event happens for ALL bodies, therefore, we have to limit
--                --                -- the total number of joints we create to avoid strange behaviors.
--                --                return
--                --            end
--                local hits = physics.queryRegion(event.x + this.offsetX, event.y + this.offsetY, event.x + this.offsetX + 1, event.y + this.offsetY + 1)
--                if (hits) then
--                    for i, v in ipairs(hits) do
--                        if v == body  then
--                            local bounds = body.contentBounds
--                            local x, y = event.x + this.offsetX, event.y + this.offsetY
--                            local rayHits1 = physics.rayCast(bounds.xMin - 1 + this.offsetX, y, x, y, "unsorted")
--                            local rayHits2 = physics.rayCast(bounds.xMax + 1 + this.offsetX, y, x, y, "unsorted")
--                            local rayHits3 = physics.rayCast(x, bounds.yMin - 1 + this.offsetY, x, y, "unsorted")
--                            local rayHits4 = physics.rayCast(x, bounds.yMax + 1 + this.offsetY, x, y, "unsorted")
--                            -- if rayHits1 and rayHits2 and rayHits3 and rayHits4 then
--                            if _.any(rayHits1, function(hit) return (hit.object == body) end) and
--                                    _.any(rayHits2, function(hit) return (hit.object == body) end) and
--                                    _.any(rayHits3, function(hit) return (hit.object == body) end) and
--                                    _.any(rayHits4, function(hit) return (hit.object == body) end) then
--                                this:debug("matched:" .. tostring(event.id) .. tostring(body))
--                                --                        local point = display.newCircle(event.x + self.offsetX, event.y + self.offsetY, 10)
--                                --                        point:setFillColor( 1, 0, 0, 1 )
--                                --                        physics.addBody( point, "dynamic" )
--                                --events[event.id] = PhysicTranslator:new(obj, { maxForce = self.force, x = event.x + self.offsetX, y = event.y + self.offsetY })
--
--                                --physics.newJoint("weld", point, obj, point.x, point.y)
--
--                                stage:setFocus( body, event.id )
--                                body["events"][event.id].isFocus = true
--                                body["events"][event.id].tempJoint = PhysicTranslator:new(body, { maxForce = this.force, x = event.x + this.offsetX, y = event.y + this.offsetY })
--
--                                --display.getCurrentStage():setFocus(obj, event.id)
--                                this:onObjectTouchBegan(body)
--                                return true
--                            end
--                        end
--                    end
--                end
--
--
--                -- Create a temporary touch joint and store it in the object for later reference
--                -- if params and params.center then
--                -- drag the body from its center point
--                --  body.tempJoint = physics.newJoint( "touch", body, body.x, body.y )
--                -- else
--                -- drag the body from the point where it was touched
--
--                --end
--
--                --total_number_of_joints_created = total_number_of_joints_created + 1
--
--                --        body.tempJoint.maxForce = 0.25*body.tempJoint.maxForce
--
--                -- Apply optional joint parameters
--                --            if params then
--                --                local maxForce, frequency, dampingRatio
--                --
--                --                if params.maxForce then
--                --                    -- Internal default is (1000 * mass), so set this fairly high if setting manually
--                --                    body.tempJoint.maxForce = params.maxForce
--                --                end
--                --
--                --                if params.frequency then
--                --                    -- This is the response speed of the elastic joint: higher numbers = less lag/bounce
--                --                    body.tempJoint.frequency = params.frequency
--                --                end
--                --
--                --                if params.dampingRatio then
--                --                    -- Possible values: 0 (no damping) to 1.0 (critical damping)
--                --                    body.tempJoint.dampingRatio = params.dampingRatio
--                --                end
--                --            end
--
--            elseif body["events"][event.id].isFocus then
--                if "moved" == phase then
--
--                    -- Update the joint to track the touch
--                    --body.tempJoint:setTarget( event.x, event.y )
--                    body["events"][event.id].tempJoint:translate(event.x - body.x + this.offsetX, event.y - body.y + this.offsetY)
--
--                    this:onObjectTouchMove(body)
--
--                elseif "ended" == phase or "cancelled" == phase then
--
--
--                    body["events"][event.id].isFocus = false
--                    -- Remove the joint when the touch ends
--                    body["events"][event.id].tempJoint:removeSelf()
--                    body["events"][event.id].tempJoint = nil
--
----                    local tmp = _.select(body["events"], function(v, k) return v.tempJoint ~= nil end)
----
----                    if #tmp == 0 then --所有对该物体的touch都已经end了
----                     stage:setFocus( body, nil )
----                    end
--                    body["events"][event.id] = nil
--                    this:onObjectTouchEnd(body)
--
--                    -- total_number_of_joints_created = total_number_of_joints_created - 1
--                end
--            end
--
--            -- Stop further propagation of touch event
--            return true
--
--        end
--
--
--        obj:addEventListener("touch", obj)
--    end
--
--    function Dragger:getObjects()
--        return self._dragObjects
--    end
--
--
--
--
--    --删除一个对象
--    function Dragger:removeObject(obj)
--        table.removeElement(self._dragObjects, obj)
--        obj:removeEventListener("touch", obj)
--    end
--
--    --更新拖拉点的偏移
--    function Dragger:updateOffset(offsetX, offsetY)
--        self.offsetX = offsetX or 0
--        self.offsetY = offsetY or 0
--
--        _.each(self._dragObjects, function(obj)
--            obj.toucher:upadteOffset(offsetX, offsetY)
--        end)
--    end
--
--    function Dragger:_callListeners(event)
--        _.each(self._touchListeners, function(l)
--            if type(l) == 'function' then
--                l(event)
--            end
--            if type(l) == 'table' then
--                l:onPMDrag(event)
--            end
--        end)
--    end
--
--     eventCounter = 0
--    function Dragger:onObjectTouchBegan(obj)
--        --self:debug("touch began")
--        if obj ~= nil then
--            local evt = {}
--            evt.target = obj
--            evt.phase = "began"
--            eventCounter = eventCounter + 1
--            Log:debugOnScreen("touch count:" .. eventCounter)
--            --obj._touchListener(evt)
--            self:_callListeners(evt)
--        end
--    end
--
--    function Dragger:onObjectTouchMove(obj, x, y)
--        if obj ~= nil then
--            local evt = {}
--            evt.target = obj
--            evt.phase = "moved"
--            evt.x = x
--            evt.y = y
--            self:_callListeners(evt)
--        end
--    end
--
--    function Dragger:onObjectTouchEnd(obj)
--        --self:debug("touch end")
--        if obj ~= nil then
--            eventCounter = eventCounter -1
--            Log:debugOnScreen("touch count:" .. eventCounter)
--            local evt = {}
--            evt.target = obj
--            evt.phase = "ended"
--            self:_callListeners(evt)
--        end
--    end
--    --local total_number_of_joints_created = 0
--
--    local events = {}
--    function Dragger:touch1(event)
--        local this = self
--        if event.phase == "began" then
--            if events[event.id] ~= nil then
--                return true
--            end
--            local hits = physics.queryRegion(event.x + this.offsetX, event.y + this.offsetY, event.x + this.offsetX + 1, event.y + this.offsetY + 1)
--            if (hits) then
--                for i, v in ipairs(hits) do
--                    for m = 1, #self._dragObjects do
--                        local obj = self._dragObjects[m]
--                        if v == obj then
--                            local bounds = obj.contentBounds
--                            local x, y = event.x + this.offsetX, event.y + this.offsetY
--                            local rayHits1 = physics.rayCast(bounds.xMin - 1 + this.offsetX, y, x, y, "unsorted")
--                            local rayHits2 = physics.rayCast(bounds.xMax + 1 + this.offsetX, y, x, y, "unsorted")
--                            local rayHits3 = physics.rayCast(x, bounds.yMin - 1 + this.offsetY, x, y, "unsorted")
--                            local rayHits4 = physics.rayCast(x, bounds.yMax + 1 + this.offsetY, x, y, "unsorted")
--                            -- if rayHits1 and rayHits2 and rayHits3 and rayHits4 then
--                            if _.any(rayHits1, function(hit) return (hit.object == obj) end) and
--                                    _.any(rayHits2, function(hit) return (hit.object == obj) end) and
--                                    _.any(rayHits3, function(hit) return (hit.object == obj) end) and
--                                    _.any(rayHits4, function(hit) return (hit.object == obj) end) then
--                                this:debug("matched:" .. tostring(event.id) .. tostring(obj))
--                                --                        local point = display.newCircle(event.x + self.offsetX, event.y + self.offsetY, 10)
--                                --                        point:setFillColor( 1, 0, 0, 1 )
--                                --                        physics.addBody( point, "dynamic" )
--                                events[event.id] = PhysicTranslator:new(obj, { maxForce = self.force, x = event.x + self.offsetX, y = event.y + self.offsetY })
--
--                                --physics.newJoint("weld", point, obj, point.x, point.y)
--
--
--                                --display.getCurrentStage():setFocus(obj, event.id)
--                                this:onObjectTouchBegan(obj)
--                                return true
--                            end
--                        end
--                    end
--                end
--            end
--        elseif event.phase == "moved" then
--            local pt = events[event.id]
--            if pt ~= nil then
--                --this:debug("moving")
--                local target = pt:getObject()
--                pt:translate(event.x - target.x + self.offsetX, event.y - target.y + self.offsetY)
--                this:onObjectTouchMove(pt:getObject())
--            end
--            return true
--        elseif event.phase == "ended" or event.phase == "cancelled" then
--
--            local pt = events[event.id]
--            if pt ~= nil then
--                --display.getCurrentStage():setFocus(nil, event.id)
--                this:onObjectTouchEnd(pt:getObject())
--                pt:removeSelf()
--                events[event.id] = nil
--            end
--            return true
--        end
--         return true
--    end
--
--
--
--    --清除所有
--    function Dragger:removeSelf()
--        Runtime:removeEventListener("touch", self)
--        table.removeAllElements(self._dragObjects)
--        table.removeAllElements(self._touchListeners)
--    end
--
--    return Dragger
--end
--
--return MDrag
