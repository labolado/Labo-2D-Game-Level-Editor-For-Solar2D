-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
-- 设置子关卡参数
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("set_level_props", {
    {name = "script", default = "base", type = "string", limit = {max = 10000, min = 0}, desc="游戏脚本"},
    {name = "ui", default = "", type = "string", limit = {max = 10000, min = 0}, desc="ui关卡名"},
    {name = "ui_type", default = "", type = "string", limit = {max = 10000, min = 0}, desc="ui类型"}
    -- 可扩展属性
})

function Action.execute(ctx, act)
	local target = act.target
	local loader = target.loaderID
	local extension = act.extension or {}
	extension.script = act.script
	if act.ui_type ~= "" then
		-- extension.ext_typename = act.ui_type
		extension.ui_type = act.ui_type
	end
	if act.ui ~= "" then
		extension.ui = act.ui
		-- extension.ext_ui = act.ui
	end
	loader.extension = extension
	_D("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	_D(extension.script, tostring(extension.ui), tostring(extension.ui_type))
	_D("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
end

return Action
