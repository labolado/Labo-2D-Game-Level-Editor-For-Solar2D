# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends "corona_joint.gd"

export(float) var ratio = 1.0

# stationary anchor
export(Vector2) var rope_anchor_a : Vector2 = Vector2(-32, 0)
export(Vector2) var rope_anchor_b : Vector2 = Vector2(32, 0)

func _init():
	num_anchor = 4

func update_anchor(overlay : Control) -> bool:
	var result := .update_anchor(overlay)
	if result:
		var a := get_node_or_null(node_a)
		var b := get_node_or_null(node_b)
		var pos : Vector2 = get_viewport_transform() * get_canvas_transform() * (rope_anchor_a + a.get_global_transform().get_origin())
		overlay.draw_circle(pos, CIRCLE_RADIUS, anchor_color)
		overlay.draw_string(overlay.get_font(""), pos, "rope_anchor_a", Color.green)
		pos = get_viewport_transform() * get_canvas_transform() * (rope_anchor_b + b.get_global_transform().get_origin())
		overlay.draw_circle(pos, CIRCLE_RADIUS, anchor_color)
		overlay.draw_string(overlay.get_font(""), pos, "rope_anchor_b", Color.green)
		return true
	return false

func find_closed_anchor(event_pos : Vector2) -> bool:
	var a := get_node_or_null(node_a)
	var b := get_node_or_null(node_b)
	var pos : Vector2 = get_viewport_transform() * get_canvas_transform() * (anchor_a + a.get_global_transform().get_origin())
	var a_dist = pos.distance_to(event_pos)
	pos = get_viewport_transform() * get_canvas_transform() * (anchor_b + b.get_global_transform().get_origin())
	var b_dist = pos.distance_to(event_pos)
	pos = get_viewport_transform() * get_canvas_transform() * (rope_anchor_a + a.get_global_transform().get_origin())
	var road_a_dist = pos.distance_to(event_pos)
	pos = get_viewport_transform() * get_canvas_transform() * (rope_anchor_b + b.get_global_transform().get_origin())
	var road_b_dist = pos.distance_to(event_pos)
	
	var t := [a_dist, b_dist, road_a_dist, road_b_dist]
	
	if a_dist < GRAB_THRESHOLD or b_dist < GRAB_THRESHOLD or road_a_dist < GRAB_THRESHOLD or road_b_dist < GRAB_THRESHOLD:
		var min_dist = t.min()
		if min_dist == a_dist:
			dragged_anchor["name"] = "anchor_a"
			dragged_anchor["anchor"] = anchor_a
			drag_start["anchor"] = anchor_a
		elif min_dist == b_dist:
			dragged_anchor["name"] = "anchor_b"
			dragged_anchor["anchor"] = anchor_b
			drag_start["anchor"] = anchor_b
		elif min_dist == road_a_dist:
			dragged_anchor["name"] = "rope_anchor_a"
			dragged_anchor["anchor"] = rope_anchor_a
			drag_start["anchor"] = rope_anchor_a
		elif min_dist == road_b_dist:
			dragged_anchor["name"] = "rope_anchor_b"
			dragged_anchor["anchor"] = rope_anchor_b
			drag_start["anchor"] = rope_anchor_b
		return true
	return false

func drag_to(event_position : Vector2):
	if not dragged_anchor:
		return
	var node : Node2D
	if dragged_anchor["name"] == "anchor_a" or dragged_anchor["name"] == "rope_anchor_a":
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
	elif dragged_anchor["name"] == "anchor_b":
		anchor_b = target_position - node.get_global_transform().get_origin()
		dragged_anchor["anchor"] = anchor_b
	elif dragged_anchor["name"] == "rope_anchor_a":
		rope_anchor_a = target_position - node.get_global_transform().get_origin()
		dragged_anchor["anchor"] = rope_anchor_a
	elif dragged_anchor["name"] == "rope_anchor_b":
		rope_anchor_b = target_position - node.get_global_transform().get_origin()
		dragged_anchor["anchor"] = rope_anchor_b
		
func to_data() -> Dictionary:
	var data := .to_data()
	data["type"] = "pulley"
	data["rope_anchor_a"] = [rope_anchor_a.x, rope_anchor_a.y]
	data["rope_anchor_b"] = [rope_anchor_b.x, rope_anchor_b.y]
	data["ratio"] = ratio
	return data