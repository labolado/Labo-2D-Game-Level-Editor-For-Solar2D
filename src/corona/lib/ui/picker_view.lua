-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- Interface declaration
local ui = import("ui.ui")
local PickerView = class("PickerView", Node)

function PickerView:initialize(list, params)
    local view = display.newGroup()
	self.view = view
    for i=1, #list do
        local cell = self:onCellRender(list[i], i)
        view:insert(cell)
    end

    self.params = params
	self.picker = self:render()
end

function PickerView:render()
    local params = {}
    _.extend(params, self.params)
    params.parent = self
    params.width = params.width or self.view.contentWidth
    params.height = params.height or self.view.contentHeight
    local picker = ui.newScrollView(params)

    picker:insertContent(self.view)
    if params.draggable then
        local drag = function(target, e)
            return self:drag(target, e)
        end
        local newItem = function(target)
            return self:newItem(target)
        end
        self.draggable = true
        self.dragAgent = drag
        self.newItemAgent = newItem
        picker:onNewDragTouch(drag)
        picker:attachNewCardRender(newItem)
        picker:setReleaseEvent(false)
    end
    self:onRender()
    picker:render()
    return picker
end

function PickerView:drag(target, e)
    if e.phase == "began" then
        display.currentStage:setFocus( target, e.id )
        target.isFocused = true
        target.x0 = e.x
        target.y0 = e.y
        self:onDragBegan(target, e)
    elseif target.isFocused then
        if e.phase == "moved" then
            -- if not target.playOnce then
            --     target.playOnce = true
            -- end
            local x1, y1 = target.parent:contentToLocal( e.x, e.y )
            local x2, y2 = target.parent:contentToLocal( target.x0, target.y0 )
            local ox, oy =  x1 - x2, y1 - y2
            target:translate(ox, oy)
            target.x0, target.y0 = e.x, e.y
            self:onDragMoved(target, e)
        else
            -- target.playOnce = false
            display.currentStage:setFocus(target, nil )
            display.currentStage:setFocus(nil)
            target.isFocused = false
            self:onDragEnded(target, e)
        end
    end
    return true
end

function PickerView:makeDraggable(target)
    -- if self.dragAgent then
        target.touch = self.dragAgent
        target:removeEventListener("touch", target)
        target:addEventListener("touch", target)
    -- end
end

function PickerView:makeCellDraggable(target, bool)
    if bool then
        Component.enable("horizontal_drag", target)
    else
        Component.disable("horizontal_drag", target)
    end
end

function PickerView:newItem(target)
    return self:onNewItem(target)
end

function PickerView:onNewItem(target)
end

function PickerView:onRender()
end

function PickerView:onCellRender(info, i)
end

function PickerView:onDragBegan(target, e)
end

function PickerView:onDragMoved(target, e)
end

function PickerView:onDragEnded(target, e)
end

-- function PickerView:onPick(item)
-- end

return PickerView
