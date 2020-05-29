local removeAllChildren = function( objectOrGroup )
    if objectOrGroup then
        if objectOrGroup.numChildren then
            -- we have a group, so first clean that out
            while objectOrGroup.numChildren > 0 do
                -- clean out the last member of the group (work from the top down!)
                display.cleanGroup( objectOrGroup[objectOrGroup.numChildren] )
            end
        end

        -- objectOrGroup:scale( 0.1, 0.1 )

        if objectOrGroup.touch then
            objectOrGroup:removeEventListener( "touch", objectOrGroup )
            objectOrGroup.touch = nil
        end

        if objectOrGroup.tap then
            objectOrGroup:removeEventListener( "tap", objectOrGroup )
            objectOrGroup.tap = nil
        end

        if objectOrGroup.collision then
            objectOrGroup:removeEventListener("collision", objectOrGroup)
            objectOrGroup.collision = nil
        end


        return
    end
end

display.removeAllChildren = removeAllChildren

local cleanGroup = function( objectOrGroup )
	if objectOrGroup then
	    display.removeAllChildren(objectOrGroup)

		objectOrGroup:removeSelf()
        objectOrGroup = nil
		-- print( "clear" )
		return
	end
end
display.cleanGroup = cleanGroup

local removeAllEvent = function(objectOrGroup)
    if objectOrGroup.numChildren then
        for i=1, objectOrGroup.numChildren do
            display.removeAllEvent(objectOrGroup[i])
        end
    end
    if objectOrGroup._tableListeners then
        for eventName, listeners in pairs(objectOrGroup._tableListeners) do
            if eventName ~= "finalize" then
                local i = #listeners
                while i > 0 do
                    local elem = listeners[i]
                    -- print("remove: " .. eventName .. "," .. tostring(elem), i)
                    objectOrGroup:removeEventListener(eventName, elem)
                    i = i - 1
                end
            end
        end
    end
    if objectOrGroup._functionListeners then
        for eventName, listeners in pairs(objectOrGroup._functionListeners) do
            if eventName ~= "finalize" then
                local i = #listeners
                while i > 0 do
                    local elem = listeners[i]
                    -- print("remove: " .. eventName .. "," .. tostring(elem), i)
                    objectOrGroup:removeEventListener(eventName, elem)
                    i = i - 1
                end
            end
        end
    end
end
display.removeAllEvent = removeAllEvent


display.getZIndex = function(displayObject)
    local parent = displayObject.parent
    assert(parent ~= nil)
    for i = 1, parent.numChildren do
        if parent[i] == displayObject then
            return i
        end
    end
    assert(false)
end

display.centerOnSceen = function(displayObject)
    displayObject:translate(_CX, _CY)
end


display.addFullScreenBackground = function(parent, imageFile)
    local bkg = display.newImageRect( parent, imageFile, _AW, _AH )
    display.centerOnSceen(bkg)
    return bkg
end

display.addFullScreenColorBackground = function(parent, color)
    local bkg = display.newRect(parent, _CX, _CY, _AW, _AH )
    bkg:setFillColor( unpack(color))
   -- display.centerOnSceen(bkg)
    return bkg
end

local event = {
    name = "touch",
    phase = "cancelled",
    time = 0,
    id = 0,
    x = 0,
    y = 0,
    xStart = 0,
    yStart = 0 }
local cancelAllTouchEvent = function( objectOrGroup )
    if objectOrGroup then
        if objectOrGroup.numChildren then
            for i=1, objectOrGroup.numChildren do
                display.cancelAllTouchEvent( objectOrGroup[i] )
            end
        end

        if objectOrGroup._tableListeners or objectOrGroup._functionListeners then
            local event = event
            event.target = objectOrGroup
            objectOrGroup:dispatchEvent( event )
        end
    end
end
display.cancelAllTouchEvent = cancelAllTouchEvent


function display.aliasRemoveSelf(obj, newRemoveSelfFunc)
    local oldRemoveSelf = obj.removeSelf
    assert(obj ~= nil)
    assert(oldRemoveSelf ~= nil)
    function obj:removeSelf()
        newRemoveSelfFunc(self)
        oldRemoveSelf(self)
    end
end


display.getOffsetFromParent = function ( object )
    local x, y = object.x, object.y
    local target = object.parent
    while (target ~= display.currentStage) do
        x = x + target.x
        y = y + target.y
        target = target.parent
    end

    return x, y
end

function display.newSubGroup(parent)
    local group = display.newGroup()
    --if parent ~= nil then
        parent:insert(group)
    --end
    return group
end

function display.getWorldPosition(object)
    local bounds = object.contentBounds
    local x = (bounds.xMin + bounds.xMax) * 0.5
    local y = (bounds.yMin + bounds.yMax) * 0.5
    return x, y
end

function display.getWorldRotation(obj)
    local rotation = display.currentStage.rotation
    local target = obj
    while (target ~= display.currentStage) do
        rotation = rotation + target.rotation
        target = target.parent
    end
    return rotation
end
function display.worldRotationToLocalRotation(parent, worldRotation)
    local parentRotation = display.getWorldRotation(parent)
    return worldRotation - parentRotation
end
function display.getLocalRotation(parent, obj)
    local worldRotation = display.getWorldRotation(obj)
    return display.worldRotationToLocalRotation(parent, worldRotation)
end
function display.getLocalRotationDelta(parent, obj)
    local worldRotation = display.getWorldRotation(obj.parent)
    return display.worldRotationToLocalRotation(parent, worldRotation)
end

function display.getWorldScale(obj)
    local xScale = display.currentStage.xScale
    local yScale = display.currentStage.yScale
    local target = obj
    while (target ~= display.currentStage) do
        xScale = xScale * target.xScale
        yScale = yScale * target.yScale
        target = target.parent
    end
    return xScale, yScale
end
function display.worldScaleToLocalScale(parent, worldScaleX, worldScaleY)
    local parentScaleX, parentScaleY = display.getWorldScale(parent)
    return worldScaleX / parentScaleX, worldScaleY / parentScaleY
end
function display.getLocalScale(parent, obj)
    local worldScaleX, worldScaleY = display.getWorldScale(obj)
    return display.worldScaleToLocalScale(parent, worldScaleX, worldScaleY)
end
function display.getLocalScaleDelta(parent, obj)
    local worldScaleX, worldScaleY = display.getWorldScale(obj.parent)
    return display.worldScaleToLocalScale(parent, worldScaleX, worldScaleY)
end

function display.groupIndexOf(displayGroup, displayObject, start)
    if not displayGroup then return 0 end
    start = start or 1
    for index = start, displayGroup.numChildren, 1 do
      if displayObject == displayGroup[index] then
        return index
      end
    end
    return 0
end

function display.centeringDisplayGroup(group)
    local ox, oy = display.getWorldPosition(group)
    local wx, wy = group:localToContent(0, 0)
    local dx, dy = wx - ox, wy - oy
    for i=1, group.numChildren do
        local child = group[i]
        local isGroup = child.numChildren ~= nil
        local pass = isGroup and child.numChildren == 0
        if not pass then
            local x, y = child:localToContent(0, 0)
            x, y = group:contentToLocal(x + dx, y + dy)
            child:translate(x - child.x, y - child.y)
        end
    end
end

function display.resetGroupCenter(group)
    local ox, oy = display.getWorldPosition(group)
    local wx, wy = group:localToContent(0, 0)
    local dx, dy = wx - ox, wy - oy
    for i=1, group.numChildren do
        local child = group[i]
        local isGroup = child.numChildren ~= nil
        local pass = isGroup and child.numChildren == 0
        if not pass then
            -- if isGroup then
            --     display.resetGroupCenter(child)
            -- end
            local x, y = child:localToContent(0, 0)
            x, y = group:contentToLocal(x + dx, y + dy)
            child:translate(x - child.x, y - child.y)
        end
    end
    local lx, ly = group.parent:contentToLocal(ox, oy)
    group:translate(lx - group.x, ly - group.y)
end

function display.centeringTranslateBy(group, x, y)
    display.resetGroupCenter(group)
    group:translate(x, y)
end

function display.centeringTranslateTo(group, x, y)
    display.resetGroupCenter(group)
    group:translate(x - group.x, y - group.y)
end

function display.changeParent(object, newParent)
    local x, y = object:localToContent( 0, 0 )
    local xScale, yScale = display.getWorldScale(object)
    local rotation = display.getWorldRotation(object)
    newParent:insert(object)
    local lx, ly = newParent:contentToLocal(x, y)
    object:translate( lx - object.x, ly - object.y )
    local sx, sy = display.getWorldScale(object)
    object:scale(xScale/sx, yScale/sy)
    local sr = display.getWorldRotation(object)
    object:rotate(rotation - sr)
end
