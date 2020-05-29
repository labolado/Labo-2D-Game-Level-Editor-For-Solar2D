# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Node2D

const CoronaSprite = preload("../lh_sprite.gd")
const CoronaTerrian = preload("../lh_bezier_track.gd")
const GRAB_THRESHOLD : float = 16.0
const CIRCLE_RADIUS: float = 8.0

export(NodePath) var node_a setget set_node_a
export(NodePath) var node_b setget set_node_b

export(Color) var anchor_color = Color.red

export(Vector2) var anchor_a : Vector2 = Vector2.ZERO
export(Vector2) var anchor_b : Vector2 = Vector2.ZERO

var num_anchor := 2
var dragged_anchor: Dictionary = {}
var drag_start: Dictionary = {'anchor': Vector2.ZERO}

signal set_node_error
#func _init():
#	set_process(false)
#	pass
	
func set_node_a(path : NodePath):
#	var node := get_node_or_null(path)
#	print("joint node_a ", path, ", ", node != null)
	print("joint node_a ", path)
	if path == node_a:
		return
	node_a = path
#	if node != null and (node.get_script() == CoronaSprite or node.get_script() == CoronaTerrian) and path != node_b:
#		node_a = path
##		printt(path)
#	else:
#		emit_signal("set_node_error", 'Node_a must be "Sprite" or "Terrian", and node_a can not equal to node_b!')
#		node_a = path
	
func set_node_b(path : NodePath):
#	var node := get_node_or_null(path)
#	print("joint node_b ", path, ", ", node != null)
	print("joint node_b ", path)
	if path == node_b:
		return
	node_b = path
#	if node != null and (node.get_script() == CoronaSprite or node.get_script() == CoronaTerrian) and path != node_a:
#		node_b = path
##		printt(path)
#	else:
#		node_b = path
#		emit_signal("set_node_error", 'Node_b must be "Sprite" or "Terrian", and node_a can not equal to node_b!')

func update_anchor(overlay : Control) -> bool:
	if !node_a.is_empty() and !node_b.is_empty():
		var a := get_node_or_null(node_a)
		var b := get_node_or_null(node_b)
		if a != null and b != null:
			var pos : Vector2 = get_viewport_transform() * get_canvas_transform() * (anchor_a + a.get_global_transform().get_origin())
			overlay.draw_circle(pos, CIRCLE_RADIUS, anchor_color)
			overlay.draw_string(overlay.get_font(""), pos, "anchor_a")
			if num_anchor > 1:
				pos = get_viewport_transform() * get_canvas_transform() * (anchor_b + b.get_global_transform().get_origin())
				overlay.draw_circle(pos, CIRCLE_RADIUS, anchor_color)
				overlay.draw_string(overlay.get_font(""), pos, "anchor_b")
			return true
	return false

func is_valid() -> bool:
	if !node_a.is_empty() and !node_b.is_empty():
		var a := get_node_or_null(node_a)
		var b := get_node_or_null(node_b)
#		print("joint is_valide: ", a, ", ", b, ", ", node_a, ", ", node_b)
		if a != null and b != null and node_a != node_b:
			var check_a = a.get_script() == CoronaSprite or a.get_script() == CoronaTerrian
			var check_b = b.get_script() == CoronaSprite or b.get_script() == CoronaTerrian
			return check_a and check_b
	return false

func find_closed_anchor(event_pos : Vector2) -> bool:
	var a := get_node_or_null(node_a)
	var b := get_node_or_null(node_b)
	var pos : Vector2 = get_viewport_transform() * get_canvas_transform() * (anchor_a + a.get_global_transform().get_origin())
	var a_distance = pos.distance_to(event_pos)
	if num_anchor > 1:
		pos = get_viewport_transform() * get_canvas_transform() * (anchor_b + b.get_global_transform().get_origin())
		var b_distance = pos.distance_to(event_pos)
		if a_distance < GRAB_THRESHOLD or b_distance < GRAB_THRESHOLD:
			if a_distance < b_distance:
				dragged_anchor["name"] = "anchor_a"
				dragged_anchor["anchor"] = anchor_a
				drag_start["anchor"] = anchor_a
			else:
				dragged_anchor["name"] = "anchor_b"
				dragged_anchor["anchor"] = anchor_b
				drag_start["anchor"] = anchor_b
			return true
	else:
		if a_distance < GRAB_THRESHOLD:
			dragged_anchor["name"] = "anchor_a"
			dragged_anchor["anchor"] = anchor_a
			drag_start["anchor"] = anchor_a
			return true
	return false

func drag_to(event_position : Vector2):
	if not dragged_anchor:
		return
	var node : Node2D
	if dragged_anchor["name"] == "anchor_a":
		node = get_node(node_a)
	else:
		node = get_node(node_b)
	# Calculate the position of the mouse cursor relative to the node' center
	var viewport_transform_inv := get_viewport().get_global_canvas_transform().affine_inverse()
	var viewport_position: Vector2 = viewport_transform_inv.xform(event_position)
	var transform_inv := get_global_transform().affine_inverse()
	var target_position: Vector2 = transform_inv.xform(viewport_position.round())
	if dragged_anchor["name"] == "anchor_a":
		anchor_a = target_position - node.get_global_transform().get_origin()
		dragged_anchor["anchor"] = anchor_a
	else:
		anchor_b = target_position - node.get_global_transform().get_origin()
		dragged_anchor["anchor"] = anchor_b

func drag_anchor(event: InputEvent, plugin : EditorPlugin) -> bool:
	if is_valid():
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if not dragged_anchor and event.is_pressed():
				return find_closed_anchor(event.position)
			elif dragged_anchor and not event.is_pressed():
				drag_to(event.position)
				
				var undo := plugin.get_undo_redo()
				undo.create_action("Move anchor " + dragged_anchor["name"])
				undo.add_do_property(self, dragged_anchor["name"], dragged_anchor["anchor"])
				undo.add_undo_property(self, dragged_anchor["name"], drag_start["anchor"])
				undo.add_do_method(plugin, "update_overlays")
				undo.add_undo_method(plugin, "update_overlays")
				undo.commit_action()
				property_list_changed_notify()
				
				dragged_anchor = {}
				return true
		if not dragged_anchor:
			return false
		if event is InputEventMouseMotion:
			drag_to(event.position)
			plugin.update_overlays()
			return true
		# Cancelling with ui_cancel
		if event.is_action_pressed("ui_cancel"):
			dragged_anchor = {}
			return true
	return false

#func _notification(what : int):
#	match what:
#		NOTIFICATION_READY:
#			print("joint ready")
#		NOTIFICATION_EXIT_TREE:
#			print("joint exit tree")
##			prints(node_a, node_b)

func to_data() -> Dictionary:
	var a = get_node(node_a)
	var b = get_node(node_b)
	var data := {}
	data["joint"] = true
	data["name"] = name
	data["a"] = a.name
	data["b"] = b.name
	data["node_a"] = node_a
	data["node_b"] = node_b
	data["anchor_a"] = [anchor_a.x, anchor_a.y]
	data["anchor_b"] = [anchor_b.x, anchor_b.y]
	return data
