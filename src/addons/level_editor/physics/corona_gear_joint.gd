# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

const CoronaPivotJoint = preload("corona_pivot_joint.gd")
const CoronaPistonJoint = preload("corona_piston_joint.gd")

export(NodePath) var joint_a setget set_joint_a
export(NodePath) var joint_b setget set_joint_b
export(float) var ratio = 1.0

func _init():
	num_anchor =0

func set_joint_a(path : NodePath):
	var node := get_node_or_null(path)
	if node != null and (node.get_script() == CoronaPivotJoint or node.get_script() == CoronaPistonJoint) and path != joint_b:
		joint_a = path
		printt(path)
	else:
		joint_a = path
		emit_signal("set_node_error", 'Joint_a must be "PivotJoint" or "PistonJoint"!')
	
func set_joint_b(path : NodePath):
	var node := get_node_or_null(path)
	if node != null and (node.get_script() == CoronaPivotJoint or node.get_script() == CoronaPistonJoint) and path != joint_a:
		joint_b = path
		printt(path)
	else:
		joint_b = path
		emit_signal("set_node_error", 'Joint_b must be "PivotJoint" or "PistonJoint"!')

func update_anchor(overlay : Control) -> bool:
	return false

func find_closed_anchor(event_pos : Vector2) -> bool:
	return false

func drag_anchor(event: InputEvent, plugin : EditorPlugin) -> bool:
	return false

func is_valid() -> bool:
	if !node_a.is_empty() and !node_b.is_empty() and !joint_a.is_empty() and !joint_b.is_empty():
		var a := get_node_or_null(node_a)
		var b := get_node_or_null(node_b)
		var joint1 := get_node_or_null(joint_a)
		var joint2 := get_node_or_null(joint_b)
		if a != null and b != null and joint1 != null and joint2 != null:
			var check_a = a.get_script() == CoronaSprite or a.get_script() == CoronaTerrian
			var check_b = b.get_script() == CoronaSprite or b.get_script() == CoronaTerrian
			var check_c = joint1.get_script() == CoronaPivotJoint or joint1.get_script() == CoronaPistonJoint
			var check_d = joint2.get_script() == CoronaPivotJoint or joint2.get_script() == CoronaPistonJoint
			return check_a and check_b and check_c and check_d
	return false

func to_data():
	var data := .to_data()
	data["type"] = "gear"
	data["joint_a"] = get_node(joint_a).name
	data["joint_b"] = get_node(joint_b).name
	data["joint_a_path"] = joint_a
	data["joint_b_path"] = joint_b
	data["ratio"] = ratio
	return data