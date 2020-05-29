-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local SceneInfo = {}

local Info = {}
function Info:new(name, params)
    self.name = name
    self.params = params or {}
    return self
end

function SceneInfo.home(pageNo)
    local params = {pageNo = pageNo}
    return Info:new("app.ui.scene_home", params)
end

function SceneInfo.game(levelNo)
    local params = {
        levelNo = levelNo
    }
    return Info:new("app.ui.scene_game", params)
end

return SceneInfo
