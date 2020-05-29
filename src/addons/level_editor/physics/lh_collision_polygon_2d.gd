# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends CollisionPolygon2D

const Util = preload("../utils/util.gd")
const LHFixture = preload("lh_fixture.gd")

export(Resource) var fixture_properties = LHFixture.new()

func is_valid() -> bool:
	return polygon.size() >= 3

func to_data() -> Dictionary:
	var fixture : Dictionary = fixture_properties.to_dictionary()
	var indices : PoolIntArray = Geometry.triangulate_polygon(polygon)
	var vertices := Util.vector2_array_to_array(polygon)
	if indices.size() == 0:
		if Engine.has_singleton("Earcut"):
			var Earcut := Engine.get_singleton("Earcut")
			indices = Earcut.execute(polygon, PoolIntArray())
	fixture["vertices"] = vertices
	fixture["indices"] = indices
	
	return fixture
