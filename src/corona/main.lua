-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 0, 0, 0, 1)

require("lib.global_init")

local SceneHelper = require("app.lib.scene_helper")
local SceneInfo = require("app.ui.scene_info")
SceneHelper.gotoScene(SceneInfo.home())

-- local GodotLoader = require("godot.godot_loader")
-- GodotLoader:new("assets/levels/export/level1.json")
