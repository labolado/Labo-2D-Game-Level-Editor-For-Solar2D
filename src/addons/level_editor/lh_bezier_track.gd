# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Path2D

const Util = preload("utils/util.gd")

#class_name LHBezierTrack
#const LHCustomClass = preload("lh_custom_class.gd")
#const LHPhysicsProperties = preload("physics/lh_physics_properties2.gd")
#const LHFixture = preload("physics/lh_fixture.gd")

var version : int = 1 setget set_version
export(bool) var visible_in_level := true setget set_visible_in_level
export(bool) var has_track : bool = true setget set_track_visible
export(bool) var has_ground : bool = true setget set_ground_visible
export(bool) var is_ground_colored_polygon := false setget set_ground_colored_polygon
export(Texture) var track_texture : Texture = null setget set_track_texture
export(Texture) var ground_texture : Texture = null setget set_ground_texture
export(bool) var is_closed : bool = false setget set_is_closed
export(Texture) var up_track_texture : Texture = null setget set_up_track_texture
export(Texture) var down_track_texture : Texture = null setget set_down_track_texture
export(Texture) var left_track_texture : Texture = null setget set_left_track_texture
export(Texture) var right_track_texture : Texture = null setget set_right_track_texture
#export(Dictionary) var up_track_data = {
#	body = [Rect2(0, 0, 0, 0)],
#	left_cap = Rect2(0, 0, 0, 0), 
#	right_cap = Rect2(0, 0, 0, 0),
#	inner_left_cap = Rect2(0, 0, 0, 0),
#	inner_right_cap = Rect2(0, 0, 0, 0)
#}
#export(Dictionary) var down_track_data = {
#	body = [Rect2(0, 0, 0, 0)],
#	left_cap = Rect2(0, 0, 0, 0), 
#	right_cap = Rect2(0, 0, 0, 0),
#	inner_left_cap = Rect2(0, 0, 0, 0),
#	inner_right_cap = Rect2(0, 0, 0, 0)
#}
export(float) var track_offset : float = 0 setget set_track_offset
export(float) var up_offset : float = 0 setget set_track_up_offset
export(float) var down_offset : float = 0 setget set_track_down_offset
export(float) var left_offset : float = 0  setget set_track_left_offset
export(float) var right_offset : float = 0  setget set_track_right_offset
export(Color) var ground_color : Color = Color.white setget set_ground_color
export(Color) var track_color : Color = Color.white setget set_track_color
export(Vector2) var ground_tiling : Vector2 = Vector2.ONE setget set_ground_tiling
export(Vector2) var ground_tiling_offset : Vector2 = Vector2.ZERO setget set_ground_tiling_offset
export(float) var ground_tiling_rotation : float = 0 setget set_ground_tiling_rotation
export(float) var track_height : float = 128 setget set_track_height
export(float) var spacing : float = 512 setget set_spacing
export(int, 1, 10) var tessellate_max_stages : int = 5 setget set_tessellate_max_stages
export(float, 0.1, 45, 0.01) var tessellate_tolerance : float = 2 setget set_tessellate_tolerance
#export(Resource) var custom_class = LHCustomClass.new()
#export(Resource) var physic_properties = LHPhysicsProperties.new()
#export(Resource) var fixture_properties = LHFixture.new()
var fixture_type : String = "polygon"

const Track = preload("track.gd")
const Ground = preload("ground.gd")
#const TILING_SHADER_PATH = "res://core/tiling.shader" 

var track : Track
var ground : Ground
#var _material = ShaderMaterial.new()

# custom_class
var on_load := ""
var on_role_collied := ""
var on_role_collied_1 := ""
var on_collided_with := ""
var on_player_trigger := ""
var on_collided_with_ended := ""
var on_repeatable_collided := ""
var on_repeatable_collided_1 := ""
var on_rpt_collided_with := ""
var on_rpt_collided_with_ended := ""
var on_button_press := ""
var on_button_release := ""
var on_car_end := ""
var on_car_end_1 := ""
var on_re_car_end := ""
var on_re_car_end_1 := ""
var on_counter := ""
var on_rpt_counter := ""
var on_touch := ""
var on_camera := ""

# physic_properties
var object_type := "nophysic"
var handle_all := true
var is_bullet := false
var fixed_roation := false
var can_sleep := true
var gravity_scale := 1.0
var linear_velocity := Vector2.ZERO
var angular_velocity := 0.0
var linear_damping := 0.0
var angular_damping := 0.0

var is_sensor := false
var density := 0.2
var friction := 1.0
var bounce := 0.2
var group_index : int = 0
var category : int = 0
var mask : int = (1 << 16) - 1

func _get_property_list() -> Array:
#	var list : Array
#	if version == 0:
#		list = [spacing = 100
#	else:
	return [
		{"name" : "version", "type" : TYPE_INT, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_ENUM, "hint_string" : "Level_helper,Godot"},
		{"name" : "Custom Class", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_CATEGORY},
		{"name" : "default", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_GROUP},
		{"name" : "on_load", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_role_collied", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_role_collied_1", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_collided_with", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_player_trigger", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_collided_with_ended", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_repeatable_collided", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_repeatable_collided_1", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_rpt_collided_with", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_rpt_collided_with_ended", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_button_press", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_button_release", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_car_end", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_car_end_1", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_re_car_end", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_re_car_end_1", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_counter", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_rpt_counter", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_touch", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		{"name" : "on_camera", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT},
		
		{"name" : "Physic Properties", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_CATEGORY},
		{
			"name" : "object_type",
			"type" : TYPE_STRING,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : "nophysic,static,dynamic,kinematic"
		},
		{
			"name" : "fixture_type",
			"type" : TYPE_STRING,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : "polygon,edge_godot,edge,box,circle"
		},
		{"name" : "properties", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_GROUP},
		{"name" : "handle_all", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "is_bullet", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "fixed_roation", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "can_sleep", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "gravity_scale", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "linear_velocity", "type" : TYPE_VECTOR2, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "angular_velocity", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "linear_damping", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "angular_damping", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "is_sensor", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "density","type" : TYPE_REAL,"usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "friction", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "bounce","type" : TYPE_REAL,"usage" : PROPERTY_USAGE_DEFAULT},
		{"name" : "group_index","type" : TYPE_INT,"usage" : PROPERTY_USAGE_DEFAULT},
		{
			"name" : "category",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : "CATEGORY_0,CATEGORY_1,CATEGORY_2,CATEGORY_3,CATEGORY_4,CATEGORY_5,CATEGORY_6,CATEGORY_7,CATEGORY_8,CATEGORY_9,CATEGORY_10,CATEGORY_11,CATEGORY_12,CATEGORY_13,CATEGORY_14,CATEGORY_15"
		},
		{
			"name" : "mask",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_FLAGS,
			"hint_string" : "CATEGORY_0,CATEGORY_1,CATEGORY_2,CATEGORY_3,CATEGORY_4,CATEGORY_5,CATEGORY_6,CATEGORY_7,CATEGORY_8,CATEGORY_9,CATEGORY_10,CATEGORY_11,CATEGORY_12,CATEGORY_13,CATEGORY_14,CATEGORY_15"
		}
	]

func _init():
	if ground == null:
		ground = Ground.new()
		ground.name = "ground"
		add_child(ground)
#		ground.curve = curve
		ground.path = self
		ground.texture = ground_texture
		curve.connect("changed", ground, "update_curve_now")
	if track == null:
		track = Track.new()
		track.name = "track"
#		track.curve = curve
		track.path = self
		add_child(track)
		curve.connect("changed", track, "update_curve_now")

func set_version(value : int):
	version = value
	track.set_version(value)
	ground.set_version(value)

func set_visible_in_level(value : bool):
	visible_in_level = value
	if value:
		modulate.a = 1
	else:
		modulate.a = 0.25

func set_ground_colored_polygon(value : bool):
	is_ground_colored_polygon = value
	ground.set_is_colored_polygon(value)

func set_ground_texture(value : Texture):
	ground_texture = value
	ground.set_texture(value)

func set_track_texture(value : Texture):
	track_texture = value
	track.set_texture(value)
	if value != null:
		set_track_height(value.get_height())
		property_list_changed_notify()

func set_up_track_texture(value : Texture):
	up_track_texture = value
	track.set_up_texture(value)

func set_down_track_texture(value : Texture):
	down_track_texture = value
	track.set_down_texture(value)

func set_left_track_texture(value : Texture):
	left_track_texture = value
	track.set_left_texture(value)

func set_right_track_texture(value : Texture):
	right_track_texture = value
	track.set_right_texture(value)

func set_track_offset(value : float):
	track_offset = value
	track.set_track_offset(Vector2(0, value))

func set_track_up_offset(value : float):
	up_offset = value
	track.set_up_offset(value)
	
func set_track_down_offset(value : float):
	down_offset = value
	track.set_down_offset(value)
	
func set_track_left_offset(value : float):
	left_offset = value
	track.set_left_offset(value)
	
func set_track_right_offset(value : float):
	right_offset = value
	track.set_right_offset(value)

func set_ground_color(value : Color):
	ground_color = value
	ground.set_modulate(value)

func set_track_color(value : Color):
	track_color = value
	track.set_modulate(value)

func set_ground_tiling(value : Vector2):
	ground_tiling = value
	ground.tiling_scale = value
	ground.set_tiling(ground.init_tiling)

func set_ground_tiling_offset(value : Vector2):
	ground_tiling_offset = value
	ground.set_texture_offset(value)

func set_ground_tiling_rotation(value : float):
	ground_tiling_rotation = value
	ground.set_texture_rotation(value)

func set_is_closed(value : bool):
	is_closed = value
	track.set_is_closed(value)
	ground.set_is_closed(value)

func set_track_height(value : float):
	track_height = value
	track.set_road_height(value)

func set_spacing(value : float):
	spacing = value
	track.set_bake_interval(value)
	ground.set_spacing(value)

func set_tessellate_max_stages(value : int):
	tessellate_max_stages = value
	track.set_tessellate_max_stages(value)
	ground.set_tessellate_max_stages(value)

func set_tessellate_tolerance(value : float):
	tessellate_tolerance = value
	track.set_tessellate_tolerance(value)
	ground.set_tessellate_tolerance(value)

func set_track_visible(value : bool):
	has_track = value
	if has_track:
		track.set_visible(true)
	else:
		if track != null:
			track.set_visible(false)
	update()
#	property_list_changed_notify()

func set_ground_visible(value: bool):
	has_ground = value
	if has_ground:
		ground.set_visible(true)
	else:
		if ground != null:
			ground.set_visible(false)
	update()

func get_bezier_curve_data() -> Array:
	var curve_data : Array = []
	var count = curve.get_point_count()
	curve_data.resize(count)
	for i in range(count):
		var p = curve.get_point_position(i)
		var p_in = curve.get_point_in(i)
		var p_out = curve.get_point_out(i)
		curve_data[i] = [p.x, p.y, p_in.x, p_in.y, p_out.x, p_out.y]
	return curve_data

func get_edge_data() -> PoolRealArray:
	var points : PoolVector2Array
	if fixture_type == "edge":
		points = track.calculate_evenly_spacedPoints()
	else:
		points = curve.tessellate(tessellate_max_stages, tessellate_tolerance)
	return Util.vector2_array_to_array(points)

func get_physic_properties() -> Dictionary:
	var dict := {
		object_type = object_type,
		gravity_scale = gravity_scale,
		linear_velocity = [linear_velocity.x, linear_velocity.y],
		angular_velocity = angular_velocity,
		linear_damping = linear_damping,
		angular_damping = angular_damping,
		can_sleep = can_sleep,
		is_bullet = is_bullet,
		fixed_roation = fixed_roation
	}
	var fixture := {
		density = density,
		friction = friction,
		bounce = bounce,
		is_sensor = is_sensor,
		group_index = group_index,
		category = 1 << category,
		mask = mask
	}
	var fixtures := [fixture]
	dict["fixture_type"] = fixture_type
	dict["fixtures"] = fixtures
	return dict

func when_duplicate():
	var signal_name = "changed"
	var list := curve.get_signal_connection_list(signal_name)
	for v in list:
		var target = v["target"]
		if target == ground or target == track:
			curve.disconnect(signal_name, v["target"], v["method"])
#	print(curve.get_signal_connection_list(signal_name))
	curve = curve.duplicate()
	curve.connect("changed", ground, "update_curve_now")
	curve.connect("changed", track, "update_curve_now")
	ground.path = self
	track.path = self
	
	for child in get_children():
		if child.name.begins_with("hole") and child is Path2D:
			child.curve.disconnect(signal_name, ground, "update_curve_now")
			child.disconnect("tree_exited", ground, "update_curve_now")
			child.curve = child.curve.duplicate()
			child.curve.connect("changed", ground, "update_curve_now")
			child.connect("tree_exited", ground, "update_curve_now")

func get_custom_class() -> Array:
	var result := []
	var list := get_property_list()
	for elem in list:
		if elem.name.begins_with("on_"):
			var value : String = get(elem.name)
			if value != null && (not value.empty()):
				result.push_back([elem.name, value])
	return result

func custom_class_is_empty() -> bool:
	var list = get_custom_class()
	return list.size() == 0

func custom_class_to_dictionary() -> Dictionary:
	var list := get_custom_class()
	var dict := {}
	for v in list:
		var key : String = v[0].capitalize().replace(" ", "").replace("On", "on")
		dict[key] = v[1]
	return dict

func custom_class_from_dictionary(dict : Dictionary):
	for k in dict:
		if not dict[k].empty():
			var key = k.capitalize().replace(" ", "_").to_lower()
			set(key, dict[k])
