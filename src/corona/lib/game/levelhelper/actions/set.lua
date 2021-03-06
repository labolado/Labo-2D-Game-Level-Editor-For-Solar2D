-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("set", {})

function Action.execute(ctx, act)
	local extension = act.extension
	if extension then
		for key,value in pairs(extension) do
			ctx.variables[key] = value
		end
	end
end

return Action