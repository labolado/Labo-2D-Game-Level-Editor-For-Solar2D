# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Resource

#const CATEGORY_0 = 1
#const CATEGORY_1 = 1 << 1
#const CATEGORY_2 = 1 << 2
#const CATEGORY_3 = 1 << 3
#const CATEGORY_4 = 1 << 4
#const CATEGORY_5 = 1 << 5
#const CATEGORY_6 = 1 << 6
#const CATEGORY_7 = 1 << 7
#const CATEGORY_8 = 1 << 8
#const CATEGORY_9 = 1 << 9
#const CATEGORY_10 = 1 << 10
#const CATEGORY_11 = 1 << 11
#const CATEGORY_12 = 1 << 12
#const CATEGORY_13 = 1 << 13
#const CATEGORY_14 = 1 << 14
#const CATEGORY_15 = 1 << 15

# warning-ignore:unused_class_variable
export(float) var density = 0.2
# warning-ignore:unused_class_variable
export(float) var friction = 0.2
# warning-ignore:unused_class_variable
export(float) var bounce = 0.2
# warning-ignore:unused_class_variable
export(bool) var is_sensor = false
# warning-ignore:unused_class_variable
export(int) var group_index = 0
# warning-ignore:unused_class_variable
export(int, "CATEGORY_0,CATEGORY_1,CATEGORY_2,CATEGORY_3,CATEGORY_4,CATEGORY_5,CATEGORY_6,CATEGORY_7,CATEGORY_8,CATEGORY_9,CATEGORY_10,CATEGORY_11,CATEGORY_12,CATEGORY_13,CATEGORY_14,CATEGORY_15") var category = 0
# warning-ignore:unused_class_variable
export(int, FLAGS, "CATEGORY_0,CATEGORY_1,CATEGORY_2,CATEGORY_3,CATEGORY_4,CATEGORY_5,CATEGORY_6,CATEGORY_7,CATEGORY_8,CATEGORY_9,CATEGORY_10,CATEGORY_11,CATEGORY_12,CATEGORY_13,CATEGORY_14,CATEGORY_15") var mask = (1 << 16) - 1 

func _init():
	resource_name = "Box2DFixture"
	
func to_dictionary() -> Dictionary:
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
