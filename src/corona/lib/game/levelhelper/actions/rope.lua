-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local PhysicsRope = import("physics.physics_rope")
local FakeRope = import("physics.fake_rope")
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("rope", {
	{name = "start", required = true, type = "string", limit = {max = 10000, min = 0}, desc="起点坐标"},
	{name = "end", required = true, type = "string", limit = {max = 10000, min = 0}, desc="终点坐标"},
	{name = "texture", required = true, type = "string", limit = {max = 10000, min = 0}, desc="纹理图片路径"},
	{name = "density", default = 5, type = "number", limit = {max = 10000, min = 0}, desc="密度"},
	{name = "bounce", default = 0, type = "number", limit = {max = 10000, min = 0}, desc="弹性"},
	{name = "friction", default = 0.2, type = "number", limit = {max = 10000, min = 0}, desc="摩擦系数"},
	{name = "groupIndex", default = -10, type = "number", limit = {max = 100, min = -100}, desc="collision mask"},
	{name = "fake", default = false, type = "bool", limit = {max=10,min=0}, desc="是否物理绳子"}
})

function Action.execute(ctx, act)
	local target = act.target
	local startNode = Helper.findLevelObject(ctx, act.start, target.loaderID)
	local str = act["end"]
	local endNodes
	if str:match("{.*}") then
		endNodes = {}
		local list = _.split(act["end"]:gsub("[{}]", ""), ",")
		for i=1, #list do
			endNodes[i] = Helper.findLevelObject(ctx, list[i], target.loaderID)
		end
	else
		endNodes = {
			Helper.findLevelObject(ctx, str, target.loaderID)
		}
	end
	local texture = Helper.findLevelObject(ctx, act.texture, target.loaderID)

	local textureFile
	if texture then
		textureFile = texture
		texture.isVisible = false
		if not act.fake then
			texture.bodyType = "static"
			texture.isSensor = true
		end
	else
		textureFile = "assets/images/ropes/" .. act.texture .. ".png"
	end
	if act.fake then
		local rope = FakeRope:new(startNode, endNodes, textureFile)
		rope:startUpdate()
		ctx.enterFrames[#ctx.enterFrames + 1] = rope
	else
		local rope = PhysicsRope:new(startNode, endNodes, textureFile, {
			density = act.density,
			bounce = act.bounce,
			friction = act.friction,
			groupIndex = act.groupIndex
		})
		ctx.physicsJoints[#ctx.physicsJoints + 1] = rope
	end
end

return Action
