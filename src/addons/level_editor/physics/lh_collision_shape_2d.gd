# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends CollisionShape2D

const LHFixture = preload("lh_fixture.gd")

export(Resource) var fixture_properties = LHFixture.new()

func is_valid() -> bool:
	return shape != null
	
func to_data() -> Dictionary:
	var fixture : Dictionary = fixture_properties.to_dictionary()
	if shape is CircleShape2D:
		fixture["radius"] = shape.radius
	elif shape is RectangleShape2D:
		var wh : Vector2 = shape.get_extents()
		var pos = get_transform().get_origin()
		var angle = rad2deg(get_transform().get_rotation())
		fixture["box"] = {
			x = pos.x,
			y = pos.y,
			angle = angle,
			halfWidth = wh.x,
			halfHeight = wh.y
		}
	return fixture
