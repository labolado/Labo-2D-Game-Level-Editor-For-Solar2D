-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- module(..., package.seeall)
local DragableScrollView = require("lib.ui.views.dragable_scroll_view")

local ui = {}

function ui.newScrollView(params)
	local container
	if params.direction == "vertical" then
		container = DragableScrollView.newVerticalList(params.parent, params.width, params.height, "right", 40, params.padding)
	else
		container = DragableScrollView.newHorizontalList(params.parent, params.width, params.height, "up", 40, params.padding)
	end
	container.scrollDisabled = params.scrollDisabled
	container.dragDisabled = params.dragDisabled
	function container:insertContent(contentGroup)
		local px, py = display.getWorldPosition(contentGroup)
		_.gEach(contentGroup, function(child)
		    child:translate( -px, -py )
		end)
		container:insert(contentGroup)
		container.handleGroup:removeSelf()
		container.handleGroup = contentGroup
		if self.direction == "vertical" then
			contentGroup:translate(0, (contentGroup.contentHeight - container.contentHeight) * 0.5)
		else
			contentGroup:translate((contentGroup.contentWidth - container.contentWidth) * 0.5, 0)
		end

		local array = displayGroupToArray(contentGroup)
		function container:render()
		    self.itemList = array
		    if not self.dragDisabled then
			    self:_addEvent()
			else
				self:_resetBounds()
				self:_addTableViewTouchListener( self.handleGroup, self.direction )
			end
		end
	end
	if container.scrollDisabled then
		container:setListScrollable(false)
	end

	return container
end

return ui
