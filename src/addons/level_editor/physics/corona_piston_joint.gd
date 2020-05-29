# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.
s
tool
extends "corona_joint.gd"

export(Vector2) var axis = Vector2.UP
export(bool) var is_motor_enabled = false
export(float) var motor_speed = 0
export(float) var max_motor_force = 0

export(bool) var is_limit_enabled = false
export(Vector2) var limit = Vector2.ZERO

func _init():
	num_anchor = 1

func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "piston"
	data["axis"] = [axis.x, axis.y]
	data["isMotorEnabled"] = is_motor_enabled
	data["motorSpeed"] = motor_speed
	data["maxMotorForce"] = max_motor_force
	data["isLimitEnabled"] = is_limit_enabled
	data["limit"] = [limit.x, limit.y]
	return data