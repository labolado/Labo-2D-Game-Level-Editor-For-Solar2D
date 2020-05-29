# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

export(float) var max_length = 0

func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "rope"
	data["maxLength"] = max_length
	return data