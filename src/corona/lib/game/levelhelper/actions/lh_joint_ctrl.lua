-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 关卡内关节控制
local Action = pkgImport(..., "base"):extend("lh_joint_ctrl", {
	{name = "pattern", required = true, type = "string", limit = {max = 100, min = 0}, desc="joint名字标识"},
})

function Action.execute(ctx, obj)
	local loader = obj.target.loaderID
	local joints = loader:jointsWithPattern(obj.pattern)
	obj.actType = "lh_joint_ctrl"
	function obj:onControlUpdate(params)
		for i=1, #joints do
			-- local joint = joints[i].coronaJoint
			local joint = joints[i]:getCoronaJoint()
			for k,v in pairs(params) do
				joint[k] = v
			end
		end
	end
	if type(obj.extension) == "table" then
		obj:onControlUpdate(obj.extension)
	end
end

return Action
