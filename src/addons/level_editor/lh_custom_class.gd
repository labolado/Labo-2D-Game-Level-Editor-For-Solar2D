# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Resource

export(String, MULTILINE) var on_load : String = ""
export(String, MULTILINE) var on_role_collied : String = ""
export(String, MULTILINE) var on_collided_with : String = ""
export(String, MULTILINE) var on_player_trigger : String = ""
export(String, MULTILINE) var on_collided_with_ended : String = ""
export(String, MULTILINE) var on_repeatable_collided : String = ""
export(String, MULTILINE) var on_rpt_collided_with : String = ""
export(String, MULTILINE) var on_rpt_collided_with_ended : String = ""
export(String, MULTILINE) var on_button_press : String = ""
export(String, MULTILINE) var on_button_release : String = ""
export(String, MULTILINE) var on_car_end : String = ""
export(String, MULTILINE) var on_car_end_1 : String = ""
export(String, MULTILINE) var on_re_car_end : String = ""
export(String, MULTILINE) var on_re_car_end_1 : String = ""
export(String, MULTILINE) var on_counter : String = ""
export(String, MULTILINE) var on_rpt_counter : String = ""
export(String, MULTILINE) var on_touch : String = ""
export(String, MULTILINE) var on_camera : String = ""

func _init():
	resource_name = "Defalut"

func get_all_setting() -> Array:
	var result := []
	var list := get_property_list()
	for elem in list:
		if elem.name.begins_with("on_"):
			var value : String = get(elem.name)
			if value != null && (not value.empty()):
				result.push_back([elem.name, value])
	return result

func is_empty() -> bool:
	var list = get_all_setting()
	return list.size() == 0

func to_dictionary() -> Dictionary:
	var list := get_all_setting()
	var dict := {}
	for v in list:
		var key : String = v[0].capitalize().replace(" ", "").replace("On", "on")
		dict[key] = v[1]
	return dict

func from_dictionary(dict : Dictionary):
	for k in dict:
		if not dict[k].empty():
			var key = k.capitalize().replace(" ", "_").to_lower()
			set(key, dict[k])
