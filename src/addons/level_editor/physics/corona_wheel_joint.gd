# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

export(Vector2) var axis = Vector2.UP
export(float, 0, 1, 0.01) var spring_damping_ratio = 0.1
export(float) var spring_frequency = 30

export(bool) var is_motor_enabled = false
export(float) var motor_speed = 0
export(float) var max_motor_torque = 0

func _init():
	num_anchor = 1

func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "wheel"
	data["axis"] = [axis.x, axis.y]
	data["springDampingRatio"] = spring_damping_ratio
	data["springFrequency"] = spring_frequency
	data["isMotorEnabled"] = is_motor_enabled
	data["motorSpeed"] = motor_speed
	data["maxMotorTorque"] = max_motor_torque
	return data