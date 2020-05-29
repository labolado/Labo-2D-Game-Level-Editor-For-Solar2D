# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

extends Object

var properties = {}

func add(name, type, default_value, hint = PROPERTY_HINT_NONE, hint_string = null, usage = PROPERTY_USAGE_DEFAULT):
	properties[name] = {
		"hint": hint,
		"usage": usage,
		"name": name,
		"type": type,
		"value": default_value
	}
	if hint_string != null:
		properties[name]["hint_string"] = hint_string

func get(name):
	if properties.has(name):
		return properties[name].value

func set(name, value):
	if properties.has(name):
		properties[name].value = value

func _init(list):
	for prop in list:
		if prop.size() < 4:
			add(prop[0], prop[1], prop[2])
		elif prop.size() == 4:
			add(prop[0], prop[1], prop[2], prop[3])
		elif prop.size() == 5:
			add(prop[0], prop[1], prop[2], prop[3], prop[4])
		else:
			add(prop[0], prop[1], prop[2], prop[3], prop[4], prop[5])

#var property_list = PropertyList.new([
##	["custom_class", TYPE_OBJECT, null, PROPERTY_HINT_RESOURCE_TYPE, "LHCustomClass"],
#	["physic_properties/object_type", TYPE_STRING, "nophysic", PROPERTY_HINT_ENUM, "nophysic,static,dynamic,kinematic"],
#	["physic_properties/gravity_scale", TYPE_REAL, 1.0],
#	["physic_properties/linear_velocity", TYPE_VECTOR2, Vector2.ZERO],
#	["physic_properties/angular_velocity", TYPE_REAL, 0.0],
#	["physic_properties/linear_damping", TYPE_REAL, 0.0],
#	["physic_properties/angular_damping", TYPE_REAL, 0.0],
#	["physic_properties/can_sleep", TYPE_BOOL, true],
#	["physic_properties/is_bullet", TYPE_BOOL, false],
#	["physic_properties/is_sensor", TYPE_BOOL, false],
#	["physic_properties/fixed_roation", TYPE_BOOL, false],
#	])
#
#func _get(key):
#	return property_list.get(key)
#
#func _set(key, value):
#	property_list.set(key, value)
#	if key == "physic_properties/object_type":
#		set_physcis_type(value)
#
#func _get_property_list():
#	return property_list.properties.values()
#func set_target(value : NodePath):
#	print(value)
#	target = value
