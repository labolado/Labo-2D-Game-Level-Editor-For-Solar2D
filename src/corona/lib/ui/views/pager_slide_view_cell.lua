-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- 分页scrollview的一个单元格，一个单元格本身只包含位置信息
local PagerSlideViewCell = class("PagerSlideViewCell")
--新建一个 card
-- @param id 索引或者标识
-- @param rect 卡片长宽坐标
function PagerSlideViewCell:initialize(id, x, y, w, h)
    self.id = id
    self.x = x
    self.y = y
    self.height = h
    self.width = w
    self.dislayObject = {}
end

--获取单元格的标识
function PagerSlideViewCell:getId()
    return self.id
end

--为单元格设置一个 displayObject
function PagerSlideViewCell:setDisplayObject(object)
    self.displayObject = object
end

--获取当前单元格的 displayObject
function PagerSlideViewCell:getDisplayObject()
    return self.displayObject
end

--清除当前单元的显示对象
function PagerSlideViewCell:clearDisplayObject()
    if self.displayObject ~= nil then
        display.removeAllChildren(self.displayObject)
        self.displayObject:removeSelf()
        self.displayObject = nil
    end
end

-- 清除单元格
function PagerSlideViewCell:removeSelf()
    if self.displayObject ~= nil then
        display.cleanGroup(self.displayObject)
    end
end

return PagerSlideViewCell
