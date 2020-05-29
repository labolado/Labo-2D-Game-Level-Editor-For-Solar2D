# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

export(float) var max_force = 0
export(float) var max_torque = 0

func _init():
	num_anchor = 1

func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "friction"
	data["maxForce"] = max_force
	data["maxTorque"] = max_torque
	return data