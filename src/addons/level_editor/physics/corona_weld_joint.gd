# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

export(float, 0, 1, 0.01) var damping_ratio = 1
export(float) var frequency = 60

func _init():
	num_anchor = 1

func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "weld"
	data["dampingRatio"] = damping_ratio
	data["frequency"] = frequency
	return data