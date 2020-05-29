# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Path2D

const LHBezierTrack = preload("../lh_bezier_track.gd")

func _enter_tree():
	manual_init()

func manual_init():
	var parent := get_parent()
#	print(parent)
	if parent is LHBezierTrack:
		if not curve.is_connected("changed", parent.ground, "update_curve_now"):
			curve.connect("changed", parent.ground, "update_curve_now")
		if not is_connected("tree_exited", parent.ground, "update_curve_now"):
			connect("tree_exited", parent.ground, "update_curve_now")
		if not is_connected("tree_entered", parent.ground, "update_curve_now"):
			connect("tree_entered", parent.ground, "update_curve_now")

func is_valid() -> bool:
	return curve.get_point_count() > 2
