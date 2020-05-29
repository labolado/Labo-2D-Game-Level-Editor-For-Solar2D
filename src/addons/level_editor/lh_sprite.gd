# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Sprite

#const PropertyList = preload("property_list.gd")
#const LHCustomClass = preload("lh_custom_class.gd")
#const LHPhysicsProperties = preload("physics/lh_physics_properties.gd")

export(int, "DEFAULT, START, END, TEST") var tag = 0
export(bool) var visible_in_level := true setget set_visible_in_level
export(Vector2) var size setget set_size

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
var object_type := "nophysic" setget set_object_type
var handle_all := false setget set_handle_all
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
var friction := 0.2
var bounce := 0.2
var group_index : int = 0
var category : int = 0
var mask : int = (1 << 16) - 1

func _get_property_list() -> Array:
	if handle_all:
		return [
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
#			{"name" : "properties", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_GROUP},
			{
				"name" : "object_type",
				"type" : TYPE_STRING,
				"usage" : PROPERTY_USAGE_DEFAULT,
				"hint" : PROPERTY_HINT_ENUM,
				"hint_string" : "nophysic,static,dynamic,kinematic"
			},
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
	else:
		return [
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
#			{"name" : "properties", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_GROUP},
			{
				"name" : "object_type",
				"type" : TYPE_STRING,
				"usage" : PROPERTY_USAGE_DEFAULT,
				"hint" : PROPERTY_HINT_ENUM,
				"hint_string" : "nophysic,static,dynamic,kinematic"
			},
			{"name" : "handle_all", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "is_bullet", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "fixed_roation", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "can_sleep", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "gravity_scale", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "linear_velocity", "type" : TYPE_VECTOR2, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "angular_velocity", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "linear_damping", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "angular_damping", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_DEFAULT},
			{"name" : "is_sensor", "type" : TYPE_BOOL, "usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "density","type" : TYPE_REAL,"usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "friction", "type" : TYPE_REAL, "usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "bounce","type" : TYPE_REAL,"usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "group_index","type" : TYPE_INT,"usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "category", "type" : TYPE_INT, "usage" : PROPERTY_USAGE_STORAGE},
			{"name" : "mask", "type" : TYPE_INT, "usage" : PROPERTY_USAGE_STORAGE}
		]

func set_handle_all(value : bool):
	handle_all = value
	property_list_changed_notify()

func set_object_type(value : String):
	if object_type != value:
		_change_physic_type(value)
	object_type = value

func _enter_tree():
	manual_init()

func manual_init():
	if !is_connected("item_rect_changed", self, "_update_size"):
		connect("item_rect_changed", self, "_update_size")
#	if !physic_properties.is_connected("physic_type_changed", self, "_change_physic_type"):
#		physic_properties.connect("physic_type_changed", self, "_change_physic_type")

func _set(key, value):
#	print(key, ": ", value)
	if key == "scale":
		if is_region():
			size = get_region_rect().size * value
		else:
			size = get_rect().size * value
		property_list_changed_notify()
#	elif key == "flip_h":
#		print(key)
#	elif key == "flip_v":
#		print(key)

func set_size(value : Vector2):
	size = value
	if is_region():
		set_scale(value / get_region_rect().size)
	else:
		set_scale(value / get_rect().size)

func _update_size():
	size = get_rect().size * transform.get_scale()
	property_list_changed_notify()

func _change_physic_type(type_name : String):
#	print(type_name)
	var fixtures := get_fixtures()
	var is_visible = type_name != "nophysic"
#	print(fixtures, " ", is_visible)
	for child in fixtures:
		child.set_visible(is_visible)

func set_physic_shapes_visible(value : bool):
	if object_type != "nophysic":
		var fixtures := get_fixtures()
		for child in fixtures:
			child.set_visible(value)

func set_visible_in_level(value : bool):
	visible_in_level = value
	if value:
		modulate.a = 1
	else:
		modulate.a = 0.25

func get_fixtures() -> Array:
	var result = []
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			result.push_back(child)
	return result
	
func get_physic_type() -> String:
	return object_type
	
func has_physic() -> bool:
	var ok := false
	if object_type != "nophysic":
		var fixtures := get_fixtures()
		for fixture in fixtures:
			if fixture.is_valid():
				ok = true
				break
	return ok

func to_fixture_data() -> Dictionary:
	var dict : Dictionary = {
		density = density,
		friction = friction,
		bounce = bounce,
		is_sensor = is_sensor,
		group_index = group_index,
		category = 1 << category,
		mask = mask
	}
	return dict

func get_physic_properties() -> Dictionary:
	var dict : Dictionary = {
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
	var export_fixtures = []
	var fixtures := get_fixtures()
	for i in fixtures.size():
		var fixture = fixtures[i]
		if fixture.is_valid():
			var fix_data = fixture.to_data()
			if handle_all:
				fix_data["is_sensor"] = is_sensor
				fix_data["density"] = density
				fix_data["friction"] = friction
				fix_data["bounce"] = bounce
				fix_data["group_index"] = group_index
				fix_data["mask"] = mask
				fix_data["category"] = 1 << category
			export_fixtures.push_back(fix_data)
	dict["fixtures"] = export_fixtures
	return dict

func is_valid():
	return texture != null

func when_duplicate():
#	custom_class = custom_class.duplicate()
#	var signal_name = "physic_type_changed"
#	var list : Array = physic_properties.get_signal_connection_list(signal_name)
#	for v in list:
#		var target = v["target"]
#		if target == self:
#			physic_properties.disconnect(signal_name, v["target"], v["method"])
#	physic_properties = physic_properties.duplicate()
#	physic_properties.connect("physic_type_changed", self, "_change_physic_type")
	pass

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
