-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- 可拖动的列表，用于选择装饰品那样的场景

local DragableScrollView = {}


-- 这里写介绍和用法
-- @param parent
-- @param recordNum 记录总数
-- @param width 列表宽度
-- @param height 列表高度
-- @param direction 列表显示方向，横向 horizontal 或纵向 vertical
-- @param dragDirection ：left, right,up, down 表示可往哪个方向拖拉出一个新对象
-- @param padding : 两端需要留的空白
-- 这里把参数说明全补上

-- local ratio = IPAD_SCALE
local ratio = 1
local Cell = import("ui.views.pager_slide_view_cell")

-- 创建横向的滑动列表
function DragableScrollView.newHorizontalList( parent, width, height, dragDirection, recordNum, padding )
    return DragableScrollView:new( parent, width, height, "horizontal", dragDirection, recordNum, padding )
end

-- 创建纵向的滑动列表
function DragableScrollView.newVerticalList( parent, width, height, dragDirection, recordNum, padding )
    return DragableScrollView:new( parent, width, height, "vertical", dragDirection, recordNum, padding )
end

function DragableScrollView:new( parent, width, height, direction, dragDirection, recordNum, padding )
    -- 定时器管理类
    local timerMgr = import("system.timer_manager"):new()
    -- 动画管理类
    local transMgr = import("system.transition_manager"):new()

    -- 新建窗口
    local container = display.newContainer( parent, width, height )
    -- local container = display.newGroup()
    -- local region = display.newRect(container, 0, 0, width, height)
    -- region.isVisible = false
    -- container.frame = region
    -- parent:insert(container)

    -- 新建可操作group
    local handleGroup = display.newGroup()
    container:insert( handleGroup )
    container.handleGroup = handleGroup

    -- local rect = display.newRect( container, 0, 0, container.contentWidth, container.contentHeight )
    -- rect.fill = nil
    -- rect:setStrokeColor(0, 0.5, 1, 1)
 --    rect.strokeWidth = 10
 --    rect.isVisible = false
 --    container.frame = rect

    -- 从新引用 bounds， 使其更简洁
    -- container.xMin = container.contentBounds.xMin
    -- container.xMax = container.contentBounds.xMax
    -- container.yMin = container.contentBounds.yMin
    -- container.yMax = container.contentBounds.yMax

    container.recordNum = recordNum
    container.direction = direction
    container.padding = padding or {0, 0}
    container.dragDirection = dragDirection

    if container.direction == "horizontal" then
        if container.dragDirection ~= "up" or container.dragDirection ~= "down" then
            container.dragDirection = "up"
        end
    elseif container.direction == "vertical" then
        if container.dragDirection ~= "left" or container.dragDirection ~= "right" then
            container.dragDirection = "left"
        end
    end

    container.sep = 0
    container.isScrollable = true       -- 是否可滑动
    container.isDragable = true         -- 是否可拖拉出一个新item
    container.dragRelease = true        -- 拖拽一个新item结束后是否释放其附带事件
    container.debugMode = false

    local function debug(msg)
        if container.debugMode == true then
            -- Log:debug("drag view - " .. msg)
        end
    end

    local function onDragUp(e)
        container:createNewItem(e.target, e)
        return true
    end

    function container:_resetBounds()
        local target = self.handleGroup
        target.sliderBoundary = {
            xMin = self.contentBounds.xMax - target.contentBounds.xMax,
            xMax = self.contentBounds.xMin - target.contentBounds.xMin,
            yMin = self.contentBounds.yMax - target.contentBounds.yMax,
            yMax = self.contentBounds.yMin - target.contentBounds.yMin
        }
        if self.contentBounds.yMax > target.contentBounds.yMax then
            target.sliderBoundary.yMin = 0
        end
        if self.contentBounds.yMin < target.contentBounds.yMin then
            target.sliderBoundary.yMax = 0
        end
        target.initPosX = target.x
        target.initPosY = target.y
        target.initW = target.contentWidth - self.contentWidth
        target.initH = target.contentHeight - self.contentHeight
        -- if target.initW < 0 then target.initW = 0 end
        -- if target.initH < 0 then target.initH = 0 end
    end

    -- 设置拖拽生成新item释放后是否删除绑定事件，
    -- true为删除，false为不删除，删除后不可再拖拽移动， 默认为true
    function container:setReleaseEvent( bool )
        self.dragRelease = bool
    end

    -- 设置列表能否拖拉滑动， 默认为true
    function container:setListScrollable( bool )
        self.isScrollable = bool
        if self.direction == "horizontal" then
            local comp = Component.get("scrollable", self.handleGroup)
            if comp then
                comp:setScrollable(bool)
            end
        end
    end

    -- 设置列表下的item能放拖拽出一个新的item， 默认为true
    function container:setItemDragable( bool )
        self.isDragable = bool
    end

    -- 设置列表边框是否可见， 默认为true, color 调用hexColor 方法使用
    function container:showStroke( bool, width, color )
        self.frame.strokeWidth = width
        if (color) then
            self.frame:setStrokeColor( unpack(color) )
        end
        if (bool) then
            self.frame.isVisible = true
        else
            self.frame.isVisible = false
        end
    end

    function container:getList()
        return self.itemList or {}
    end

    -- 为列表添加一个背景， func 需要返回一个 display 对象
    function container:addListBkg( zoom, func )
        local bkg = func()
        if bkg then
            if zoom then
                bkg.width = self.contentWidth
                bkg.height = self.contentHeight
            end
            self:insert( bkg )
            bkg:toBack()
        end
    end

    function container:setPadding(padding)
        self.padding = padding
    end

    function container:getPadding()
        if self.direction == "horizontal" then
            local comp = Component.get("scrollable", self.handleGroup)
            return comp.padding
        else
            return self.padding
        end
    end

    -- 从右往左滚动列表
    -- @param delay 等待时间
    -- @param time 滚动所需要时间
    -- @param func 滚动结束后执行的函数
    function container:_rollFromRight( time, func )
        local target = self.handleGroup
        local prev1 = self.isScrollable
        local prev2 = self.isDragable
        self:setListScrollable( false )
        self:setItemDragable( false )
        local offset = self.padding
        target.x = target.initPosX - target.initW - offset
        transMgr:add( target, { time = time, x = target.initPosX + offset, transition = easing.outQuad, onComplete = function()
            self:setListScrollable( prev1 )
            self:setItemDragable( prev2 )
            if type(func) == "function" then
                func()
            end
        end} )
    end

    -- 从左往右滚动列表
    -- @param delay 等待时间
    -- @param time 滚动所需要时间
    -- @param func 滚动结束后执行的函数
    function container:_rollFromLeft( delay, time, func )
        local target = self.handleGroup
        local prev1 = self.isScrollable
        local prev2 = self.isDragable
        self:setListScrollable( false )
        self:setItemDragable( false )
        local offset = self.padding
        target.x = target.initPosX - target.initW - offset[2]
        transMgr:add( target, {
            delay = delay,
            time = time,
            x = target.initPosX + offset[1],
            transition = easing.outQuad,
            onComplete = function()
                self:setListScrollable( prev1 )
                self:setItemDragable( prev2 )
                if type(func) == "function" then
                    func()
                end
            end} )
    end

    -- 从下往上滚动列表
    -- @param delay 等待时间
    -- @param time 滚动所需要时间
    -- @param func 滚动结束后执行的函数
    function container:_rollFromBottom( time, func )
        local target = self.handleGroup
        local prev1 = self.isScrollable
        local prev2 = self.isDragable
        self:setListScrollable( false )
        self:setItemDragable( false )
        local offset = self.padding
        local pos = self.yMax - target.contentHeight + self.contentHeight/2 - self.padding
        transMgr:add( target, { time = time, y = pos, transition = easing.outQuad, onComplete = function()
            self:setListScrollable( prev1 )
            self:setItemDragable( prev2 )
            if type(func) == "function" then
                func()
            end
        end} )
    end

    -- 从上往下滚动列表
    -- @param delay 等待时间
    -- @param time 滚动所需要时间
    -- @param func 滚动结束后执行的函数
    function container:_rollFromTop( time, func )
        local target = self.handleGroup
        local prev1 = self.isScrollable
        local prev2 = self.isDragable
        self:setListScrollable( false )
        self:setItemDragable( false )
        local offset = self.padding
        target.y = target.initPosY - target.initH - offset[2]
        transMgr:add( target, {
            delay = delay,
            time = time,
            y = target.initPosY + offset[1],
            transition = easing.outQuad,
            onComplete = function()
                self:setListScrollable( prev1 )
                self:setItemDragable( prev2 )
                if type(func) == "function" then
                    func()
                end
            end} )
    end

    -- @param left      向左滚动
    -- @param right     向右滚动
    -- @param top       向上滚动
    -- @param bottom    向下滚动
    function container:roll( delay, time, dir, func )
        if dir == "left" then
            self:_rollFromRight( time, func )
        elseif dir == "right" then
            self:_rollFromLeft( delay, time, func )
        elseif dir == "top" then
            self:_rollFromBottom( time, func )
        elseif dir == "bottom" then
            self:_rollFromTop( time, func )
        end
    end

    ------------
    local firstStep = true
    local canScroll = false
    -- 制定横向的滑动处理事件
    local function horizontal(self, e )
        if (e.phase == "began") then
            self.x0 = e.x
            self.y0 = e.y
            self.time0 = e.time
            self.speed = 0
            display.currentStage:setFocus(self, e.id)
            self.isFocus = true
            if self.slideAuto then timerMgr:clearTimer( self.slideAuto ) end
            return true
        elseif (self.isFocus) then
            if (container.isScrollable) then
                if (e.phase == "moved") then
                    if firstStep then
                        local startP = {x = e.xStart, y = e.yStart }
                        local endP = e
                        local len = lengthOf( startP, endP)
                        if (len > 80 * ratio) then
                            local angle = angleOf( startP, endP)
                            firstStep = false
                            -- _D(angle)
                            local check = clamp3(angle, -150, -30)
                            if check and self.focusChild then
                                self.isFocus = false
                                display.currentStage:setFocus( self, nil)
                                display.currentStage:setFocus( self.focusChild, e.id )
                                self.focusChild = nil
                            else
                                self.x0 = e.x
                                self.focusChild = nil
                                canScroll = true
                            end
                        end
                    else
                        if canScroll then
                            local ox = e.x - self.x0
                            -- local dt =  (e.time - self.time0) / 1000
                            -- if dt < 10 then
                            --     self.speed = ox / dt
                            -- else
                            --     self.speed = ox
                            -- end
                            self.speed = ox * 0.8
                            self.speed = sign(self.speed) * clamp(math.abs(self.speed), 10, 180)
                            if (self.contentBounds.xMin > self.parent.contentBounds.xMin) or
                                (self.contentBounds.xMax < self.parent.contentBounds.xMax) then
                                ox = ox * 0.4
                            end
                            self:translate( ox, 0 )
                            self.x0 = e.x
                            self.time0 = e.time
                        end
                    end
                else
                    firstStep = true
                    canScroll = false
                    display.currentStage:setFocus(self, nil)
                    self.isFocus = false
                    -- _D(self.speed)
                    if self.speed ~= 0 then
                        local speed = self.speed
                        local speedFlag = sign(speed)
                        local ratio = 0.03
                        if math.abs(speed) < 3 * ratio then
                            ratio = 0.2
                        end
                        local delta = speed * ratio
                        self.slideAuto = timerMgr:setInterval(10, function(e)
                            local offset = container.padding  -- 边界恢复原位时的偏离位置
                            local ox = speed
                            if (self.contentBounds.xMin - offset[1] > self.parent.contentBounds.xMin) or
                                (self.contentBounds.xMax + offset[2] < self.parent.contentBounds.xMax) then
                               ox = ox * 0.05
                            end
                            -- _D("ox", ox)
                            self:translate( ox, 0 )
                            speed = speed - delta
                            local flag = sign(speed)
                            if (speed == 0) or (flag ~= speedFlag) then
                                timerMgr:clearTimer( e.source )
                                self.slideAuto = nil
                                if (self.contentBounds.xMin - offset[1] > self.parent.contentBounds.xMin) then
                                    transMgr:add( self, {time = 200, x = self.initPosX + offset[1], transition = easing.outQuad} )
                                elseif (self.contentBounds.xMax + offset[2] < self.parent.contentBounds.xMax) then
                                    transMgr:add( self, {time = 200, x = self.initPosX - self.initW - offset[2], transition = easing.outQuad} )
                                end
                            end
                        end)
                    end
                    local offset = container.padding  -- 边界恢复原位时的偏离位置
                    if (self.contentBounds.xMin - offset[1] > self.parent.contentBounds.xMin) then
                        if (self.slideAuto) then timerMgr:clearTimer(self.slideAuto) end
                        transMgr:cancelAll()
                        transMgr:add( self, {time = 200, x = self.initPosX + offset[1], transition = easing.outQuad} )
                    elseif (self.contentBounds.xMax + offset[2] < self.parent.contentBounds.xMax) then
                        if (self.slideAuto) then timerMgr:clearTimer(self.slideAuto) end
                        transMgr:cancelAll()
                        transMgr:add( self, {time = 200, x = self.initPosX - self.initW - offset[2], transition = easing.outQuad} )
                    end
                    if e.id then
                        Component.eidDictionary[e.id] = nil
                    end
                end
            else
                if (e.phase == "moved") then
                    if firstStep then
                        local startP = {x = e.xStart, y = e.yStart }
                        local endP = e
                        local len = lengthOf( startP, endP)
                        if (len > 25) then
                            firstStep = false
                            if self.focusChild then
                                self.isFocus = false
                                display.currentStage:setFocus( self, nil)
                                display.currentStage:setFocus( self.focusChild, e.id )
                                self.focusChild = nil
                            end
                        end
                    end
                else
                    firstStep = true
                    canScroll = false
                    display.currentStage:setFocus(self, nil)
                    self.isFocus = false
                    if e.id then
                        Component.eidDictionary[e.id] = nil
                    end
                end
            end
            return true
        end
    end

    -- 制定纵向的滑动处理事件
    -- local firstStep = true
    local vCanScroll = false
    local function vertical(self, e)
        if (e.phase == "began") then
            self.y0 = e.y
            self.time0 = e.time
            self.speed = 0
            display.currentStage:setFocus(self, e.id)
            self.isFocus = true
            if self.slideAuto then timerMgr:clearTimer( self.slideAuto ) end
            return true
        elseif (self.isFocus) then
            if (container.isScrollable) then
                if (e.phase == "moved") then
                    if firstStep then
                        local startP = {x = e.xStart, y = e.yStart }
                        local endP = e
                        local len = lengthOf( startP, endP)
                        if (len > 25 * ratio) then
                            local angle = angleOf( startP, endP)
                            firstStep = false
                            local check = clamp3(angle, -75, 75)
                            if check and self.focusChild then
                                self.isFocus = false
                                display.currentStage:setFocus( self, nil)
                                display.currentStage:setFocus( self.focusChild, e.id )
                                self.focusChild = nil
                            else
                                self.focusChild = nil
                                vCanScroll = true
                            end
                        end
                    else
                        if vCanScroll then
                            local oy = e.y - self.y0
                            -- local dt =  (e.time - self.time0) / 1000
                            -- if dt < 10 then
                            --     self.speed = oy / dt
                            -- else
                            --     self.speed = oy
                            -- end
                            self.speed = oy * 0.8
                            self.speed = sign(self.speed) * clamp(math.abs(self.speed), 10, 180)
                            if (self.contentBounds.yMin > self.parent.contentBounds.yMin) or
                                (self.contentBounds.yMax < self.parent.contentBounds.yMax) then
                                oy = oy * 0.4
                            end
                            self:translate(0, oy)

                            self.y0 = e.y
                            self.time0 = e.time
                        end
                    end
                else
                    firstStep = true
                    vCanScroll = false
                    display.currentStage:setFocus(self, nil)
                    self.isFocus = false
                    _D(self.speed)
                    if self.speed ~= 0 then
                        local speed = self.speed
                        local speedFlag = sign(speed)
                        local ratio = 0.03
                        if math.abs(speed) < 3 * ratio then
                            ratio = 0.2
                        end
                        local delta = speed * ratio
                        self.slideAuto = timerMgr:setInterval(10, function(e)
                            local offset = container.padding  -- 边界恢复原位时的偏离位置
                            local oy = speed
                            if (self.contentBounds.yMin - offset[1] > self.parent.contentBounds.yMin) or
                                (self.contentBounds.yMax + offset[2] < self.parent.contentBounds.yMax) then
                               oy = oy * 0.05
                            end
                            -- _D("oy", oy)
                            self:translate(0, oy)
                            speed = speed - delta
                            local flag = sign(speed)
                            if (speed == 0) or (flag ~= speedFlag) then
                                timerMgr:clearTimer( e.source )
                                self.slideAuto = nil
                                if (self.contentBounds.yMin - offset[1] > self.parent.contentBounds.yMin) then
                                    transMgr:add( self, {time = 200, y = self.initPosY + offset[1], transition = easing.outQuad} )
                                elseif (self.contentBounds.yMax + offset[2] < self.parent.contentBounds.yMax) then
                                    transMgr:add( self, {time = 200, y = self.initPosY - self.initH - offset[2], transition = easing.outQuad} )
                                end
                            end
                        end)
                    end
                    local offset = container.padding  -- 边界恢复原位时的偏离位置
                    if (self.contentBounds.yMin - offset[1] > self.parent.contentBounds.yMin) then
                        if (self.slideAuto) then timerMgr:clearTimer(self.slideAuto) end
                        transMgr:cancelAll()
                        transMgr:add( self, {time = 200, y = self.initPosY + offset[1], transition = easing.outQuad} )
                    elseif (self.contentBounds.yMax + offset[2] < self.parent.contentBounds.yMax) then
                        if (self.slideAuto) then timerMgr:clearTimer(self.slideAuto) end
                        transMgr:cancelAll()
                        transMgr:add( self, {time = 200, y = self.initPosY - self.initH - offset[2], transition = easing.outQuad} )
                    end
                    if e.id then
                        Component.eidDictionary[e.id] = nil
                    end
                end
            else
                if (e.phase == "moved") then
                    if firstStep then
                        local startP = {x = e.xStart, y = e.yStart }
                        local endP = e
                        local len = lengthOf( startP, endP)
                        if (len > 25) then
                            firstStep = false
                            if self.focusChild then
                                self.isFocus = false
                                display.currentStage:setFocus( self, nil)
                                display.currentStage:setFocus( self.focusChild, e.id )
                                self.focusChild = nil
                            end
                        end
                    end
                else
                    firstStep = true
                    vCanScroll = false
                    display.currentStage:setFocus(self, nil)
                    self.isFocus = false
                    if e.id then
                        Component.eidDictionary[e.id] = nil
                    end
                end
            end
            return true
        end
    end

    -- 每个新元素的拖拽
    local function drag(self, e)
        if e.phase == "began" then
            display.currentStage:setFocus( self, e.id )
            self.isFocus = true
            self.x0 = e.x
            self.y0 = e.y
        elseif (self.isFocus) then
            if e.phase == "moved" then
                local x, y = e.x - self.x0, e.y - self.y0
                self:translate( x, y )
                self.x0, self.y0 = e.x, e.y
            else
                display.currentStage:setFocus(self, nil )
                self.isFocus = false
                if (container.dragRelease) then
                    self:removeEventListener( "touch" )
                end
            end
        end
        return true
    end

    -- 每个元素的touch
    local function touch(self, e)
        if (not container.isDragable) then return end

        if self._onAllTouchCallback then self._onAllTouchCallback(e) end
        if (e.phase == "began") then
            container.handleGroup.focusChild = self
        elseif (e.phase == "moved") then
            if not firstStep then
                firstStep = true
                display.currentStage:setFocus( self, nil )
                local newItem
                if type(container.attachNewItem) == "function" then
                    newItem = container.attachNewItem( self )
                end
                if newItem == nil then
                    return true
                end
                container:_makeItemDragable(self, newItem, e)
                -- local event = { x = e.x, y = e.y, phase = "began", id = e.id, target = newItem}
                -- local x, y = self:localToContent( 0, 0 )
                -- local parent = newItem.parent
                -- x, y = parent:contentToLocal( x, y )
                -- newItem:translate( x, y )
                -- if type(container._onNewDragTouch) == "function" then
                --     newItem.touch = container._onNewDragTouch
                -- else
                --     newItem.touch = drag
                -- end
                -- -- newItem:addEventListener( "touch" )
                -- TouchRecordMgr:addTableListener(newItem, newItem)
                -- newItem:touch(event)
                return true
            end
        end
    end

    function container:_makeItemDragable(dragItem, newItem, e)
        local x, y = dragItem:localToContent( 0, 0 )
        local event = { x = x, y = y, phase = "began", id = e.id, target = newItem, fake = true}
        local parent = newItem.parent
        x, y = parent:contentToLocal( x, y )
        newItem:translate( x, y )

        if self._particularCaseDrag then
            self._particularCaseDrag(newItem, event)
        else
            if type(self._onNewDragTouch) == "function" then
                newItem.touch = self._onNewDragTouch
            else
                newItem.touch = drag
            end
            newItem:addEventListener("touch", newItem)
            newItem:touch(event)
        end
    end

    function container:dealWithSpecialDrag(func)
        self._particularCaseDrag = func
    end

    function container:_addTableViewTouchListener( object, typeName, callback )
        object.moveDots = {}
        local container = object.parent
        local rect
        -- local rect = display.newRect( 0, 0, container.contentWidth - 2, container.contentHeight )
        -- rect:setStrokeColor(0, 0.5, 1, 0.7)
        -- rect.strokeWidth = 2
        -- rect:setFillColor(237/255, 237/255, 237/255, 0.7)
        -- container:insert( rect )
        -- rect:toBack()
        -- rect.isVisible = false
        -- rect.isHitTestable = true
        -- rect.isHitTestMasked = false

        rect = display.newRect( 0, 0, object.contentWidth, object.contentHeight )
        local xs, ys = display.getWorldScale(object)
        local ox, oy = getOffsetFromParent(object)
        local x, y = display.getWorldPosition(object)
        rect:scale(1 / xs, 1 / ys)
        rect:translate( (x - ox) / xs, (y - oy) / ys )
        object:insert(rect)
        rect.isVisible = false
        rect.isHitTestable = true
        rect.isHitTestMasked = false
        rect.defImage = {}
        rect.overImage = {}
        rect:toBack()

        local this = self
        if (typeName == "vertical") then
            object.touch = function (self, e)
                if this._onAllTouchCallback then this._onAllTouchCallback(e) end
                -- if (e.phase == "moved") then
                --     if (callback ~= nil) then
                --         callback(e)
                --     end
                -- end
                return vertical(self, e)
            end
            -- object:addEventListener( "touch" )
            TouchRecordMgr:addTableListener(object, object)
        elseif (typeName == "horizontal") then
            -- object.touch = function (self, e)
            --     if this._onAllTouchCallback then this._onAllTouchCallback(e) end
            --     -- if (e.phase == "moved") then

            --     --     if (callback ~= nil) then
            --     --         callback(e)
            --     --     end
            --     -- end
            --     return horizontal(self, e)
            -- end
            -- -- object:addEventListener( "touch" )
            -- TouchRecordMgr:addTableListener(object, object)
            Component.add("scrollable", object, {
                padding = this.padding,
                timerMgr = timerMgr,
                transMgr = transMgr,
                isScrollable = this.isScrollable,
                touchCallBack = this._onAllTouchCallback,
                onAfter = this._touchOnAfter
            })
        elseif (typeName == "pencilView") then
            object.touch = function (self, e)
                -- if (e.phase == "ended") then
                --     if (callback ~= nil) then
                --         callback(e)
                --     end
                -- end
            end
            -- object:addEventListener( "touch" )
            TouchRecordMgr:addTableListener(object, object)
        end
    end

    function container:createNewItem(target, e)
       local newItem
       if type(self.attachNewItem) == "function" then
           newItem = self.attachNewItem(target)
       end
       if newItem == nil then
           return
       end
       self:_makeItemDragable(target, newItem, e)
       return newItem
    end

    -- @params object :当前要拖拽的对象
    -- @params func : 释放之后要进行的操作, 返回false则销毁拖拽的对象
    function container:_addCardDragListener( object, func1, func2 )
        if self.direction == "horizontal" then
            Component.add("horizontal_drag", object, {onDragUp = onDragUp})
        else
            object.touch = touch
            -- object:addEventListener("touch" )
            TouchRecordMgr:addTableListener(object, object)
        end
    end


    -- 传递每一个 item 时调用， info 为实例参数
    function container:attachCardRender( func )
        self.attachItem = func
    end

    -- 需要拖拽一个新item时调用改方法，
    -- @param target
    -- @param return 返回一个新的display object
    function container:attachNewCardRender( func )
        self.attachNewItem = func
    end

    -- 拖拽释放时进行的操作
    function container:onDragRelease( func )
        self.newItemOnRelease = func
    end

    -- 拖拽新块
    function container:onNewDragTouch( func )
        self._onNewDragTouch = func
    end

    function container:attachAllTouchCallBack(callback)
        self._onAllTouchCallback = callback
    end
    function container:attacTouchOnAfter(callback)
        self._touchOnAfter = callback
    end

    function container:scrollToProperPosition(force)
        if self.isScrollable or force then
            if self.direction == "horizontal" then
                local comp = Component.get("scrollable", self.handleGroup)
                local e = {phase = "ended", isFocused = true, id = "fake"}
                comp.isScrollable = true
                comp.speed = 0
                comp:touch(e)
                comp.isScrollable = self.isScrollable
            else
                self.handleGroup:touch({phase = "began"})
                self.handleGroup:touch({phase = "ended"})
            end
        end
    end

    -- 根据 id 获取指定一个 item
    function container:getItem( id )
        for i = 1, #self.itemList do
            if ( i == id) then
                return self.itemList[i]
            end
        end
    end

    -- 对一个 item 进行操作
    function container:handlItem( id, func )
        local item = self:getItem( id )
        if item and type(func) == "function" then
            func( item )
        end
    end

    -- 拖拽释放后销毁 drag object
    function container:destroyDragObject( target, result )
        if target and not result then
            transMgr:add( target, { x = target.originPos.x, y = target.originPos.y, time = 200, onComplete = function()
                if target then
                    target:removeSelf()
                    target = nil
                end
            end})
        end
    end


    -- 解锁某一个 item 此处的解锁意思为其添加拖拽事件
    function container:unlockItem( id )
        local item = self:getItem( id )
        if item then
            self:_addCardDragListener(
                item,
                function(item)
                    return self.attachNewItem( item )
                end,
                function( target )
                    if type(self.newItemOnRelease) == "function" then
                        local result = self.newItemOnRelease( target )
                        self:destroyDragObject( target, result )
                    end
                end
            )
        end
    end

    -- 为某个item 加锁
    function container:lockItem( id )
        local item = self:getItem( id )
        if item then
            item:removeEventListener( "touch" )
        end
    end

    -- 生成列表
    function container:_generateList( nums, direction, padding )
        local res = {}
        local cells = {}
        if (direction == "horizontal") then
            local startX = self.xMin + padding
            for i = 1, nums do
                local item = self.attachItem( i, self )
                item.x = startX + item.contentWidth/2 + self.sep*( i - 1)
                startX = startX + item.contentWidth
                res[#res + 1] = item
                self.handleGroup:insert( item )

                local cell = Cell:new(i, item.x, 0, item.contentWidth, item.contentHeight)
                table.insert(cells, cell)
            end
        elseif (direction == "vertical") then
            local startY = self.yMin + padding
            for i = 1, nums do
                local item = self.attachItem( i, self )
                item.y = startY + item.contentHeight/2 + self.sep*( i - 1)
                startY = startY + item.contentHeight
                res[#res + 1] = item
                self.handleGroup:insert( item )

                local cell = Cell:new(i, 0, item.y, item.contentWidth, item.contentHeight)
                table.insert(cells, cell)
            end
        end
        self.cells = cells
        return res
    end


    -- 设置列表 item 之间的间距
    function container:setSeparate( sep )
        self.sep = sep or 0
        if (self.itemList) then
            for i = 1, #self.itemList do
                local item = self.itemList[i]
                if self.direction == "horizontal" then
                    item.x = item.x + (i - 1) * self.sep
                elseif self.direction == "vertical" then
                    item.y = item.y + (i - 1) * self.sep
                end
            end
            self:_resetBounds()
        end
    end

    -- 添加列表的所有事件
    function container:_addEvent()
        for i = 1, #self.itemList do
            local item = self.itemList[i]
            if (item.info == nil) or (not item.info.lock) then
                self:_addCardDragListener(
                    item,
                    function(item)
                        return self.attachNewItem( item )
                    end,
                    function( target )
                        if type(self.newItemOnRelease) == "function" then
                            local result = self.newItemOnRelease( target )
                            self:destroyDragObject( target, result )
                        end
                    end
                )
            end
        end
        self:_resetBounds()
        self:_addTableViewTouchListener( self.handleGroup, self.direction )
    end

    -- 可调用生成列表方法
    function container:render()
        self.itemList = self:_generateList( self.recordNum, self.direction, self.padding[1]  )
        self:_addEvent()
    end

    -- function container:adjustCellNum( nums )
    --     self.recordNum = nums or self.recordNum
    --     for i = self.removeID, #self.itemList do
    --         local item = self.itemList[i]
    --         local pos = self.cells[i]
    --         if self.direction == "horizontal" then
    --             transMgr:add( item, { x = pos.x + item.contentWidth/2, time = 200 })
    --         elseif self.direction == "vertical" then
    --             transMgr:add( item, { y = pos.y, time = 200 })
    --         end
    --     end
    -- end

    -- 刷新列表
    -- function container:refresh()
    --     self:destroy()
    --     handleGroup.x = 0
    --     timer.performWithDelay( 3000, function()
    --         self:render()
    --     end )
    -- end

    function container:removeOneObject( id )
        local list = self.itemList
        local cell = list[id]
        cell:removeSelf()
        cell = nil
        table.remove( list, id )
    end

    -- 销毁列表
    function container:destroy()
        if (self) then
            for i = 1, #self.itemList do
                local item = self.itemList[i]
                item:removeSelf()
                item = nil
            end
            self.itemList = nil
            -- display.removeAllChildren( self )
        end
    end
    display.aliasRemoveSelf(container, function(obj)
        timerMgr:cancelAll()
        transMgr:cancelAll()
        obj:destroy()
    end)

    return container
end


return DragableScrollView
