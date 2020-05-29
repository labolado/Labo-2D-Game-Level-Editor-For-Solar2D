-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 加入某个camera layer
local Action = pkgImport(..., "base"):extend("add_to_layer", {
    {name = "name", default = "", type = "string", limit = {max=10000,min=0}, desc="要加入的 layer 名称"}
})

function Action.execute(ctx, obj)
    if ctx.camera then
    	local layer = ctx.camera:getLayer(obj.name)
    	if layer then
    		layer:insert(obj.target.parent)
    	end
    end
end

return Action
