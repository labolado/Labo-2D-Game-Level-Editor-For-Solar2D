# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Node2D

#export(String, FILE) var export_path
var export_path : String

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

func _get_property_list() -> Array:
	return [
		{"name" : "export_path", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_GLOBAL_FILE},
		
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
		{"name" : "on_camera", "type" : TYPE_STRING, "usage" : PROPERTY_USAGE_DEFAULT, "hint" : PROPERTY_HINT_MULTILINE_TEXT}
	]

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

func when_duplicate():
#	custom_class = custom_class.duplicate()
	pass
