# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool

const Util = preload("util.gd")
const LHBezierTrack = preload("../lh_bezier_track.gd")
const LHSprite = preload("../lh_sprite.gd")
const LHAnimatedSprite = preload("../lh_animated_sprite.gd")
const LHLayer = preload("../lh_layer.gd")
const LHPath = preload("../lh_path.gd")
const CoronaJoint = preload("../physics/corona_joint.gd")

static func to_corona(filepath : String, root : Node, warning_dialog : AcceptDialog):
	if warning_dialog != null:
		print(filepath, ", root = ", root.name)
	if root.get_class() == "Node2D":
		root.export_path = filepath.replace(ProjectSettings.globalize_path("res://"), "")
		root.property_list_changed_notify()
#		var viewport_size = root.get_viewport().get_visible_rect().size
		var w : int = ProjectSettings.get("display/window/size/width")
		var h : int = ProjectSettings.get("display/window/size/height")
		var data : Dictionary = group_to_data(root, root)
		var level : Dictionary = {
			"version" : "1.0",
			"contentWidth" : w,
			"contentHeight" : h,
			"layout" : [data]
		}
#		Util.save_data(filepath, JSON.print(level, "\t", true))
		Util.save_data(filepath, JSON.print(level))
	else:
		if warning_dialog != null:
			warning_dialog.dialog_text = "Scene root node is not Node2D!"
			warning_dialog.popup_centered_ratio(0.3)

static func group_to_data(node: LHLayer, root : Node) -> Dictionary:
	var pos : Vector2 = node.get_global_transform().get_origin()
	var scale : Vector2 = node.get_global_transform().get_scale()
	var data := {
		type = "group",
		name = node.name,
		node_path = root.get_path_to(node),
#		tag = node.lhTag,
#		custom = getCustomInfo(node),
		x = pos.x,
		y = pos.y,
		xScale = scale.x,
		yScale = scale.y,
		children = []
	}
	if not node.custom_class_is_empty():
		data["custom_info"] = node.custom_class_to_dictionary()
	var children : Array = data.children
	for i in node.get_child_count():
		var child = node.get_child(i)
#		print(child.name, ", class = ", child.get_class())
		if child is LHSprite:
			if child.is_valid():
				children.push_back(sprite_to_data(child, root))
		elif child is LHAnimatedSprite:
			if child.is_valid():
				children.push_back(animated_sprite_to_data(child, root))
		elif child is LHBezierTrack:
			children.push_back(terrian_to_data(child, root))
		elif child is CoronaJoint:
			if child.is_visible() and child.is_valid():
				children.push_back(joint_to_data(child, root))
			else:
				print("joint ", child.name, " is not valid!")
		elif child is LHPath:
			if child.is_visible() and child.is_valid():
				children.push_back(path_to_data(child, root))
		else:
			children.push_back(group_to_data(child, root))
	return data

static func path_to_data(node : LHPath, root : Node) -> Dictionary:
	var pos : Vector2 = node.get_global_transform().get_origin()
	var scale : Vector2 = node.get_global_transform().get_scale()
	var data := node.to_data()
	data["type"] = "path"
	data["name"] = node.name
	data["node_path"] = root.get_path_to(node)
	data["x"] = pos.x
	data["y"] = pos.y
	data["xScale"] = scale.x
	data["yScale"] = scale.y
	var children := []
	for i in node.get_child_count():
		var child := node.get_child(i)
		if child is LHSprite:
			if child.is_valid():
				children.push_back(sprite_to_data(child, root))
		elif child is LHAnimatedSprite:
			if child.is_valid():
				children.push_back(animated_sprite_to_data(child, root))
	data["children"] = children
	return data

#static func group_to_data2(root : Node, node: Node):
#	var data : Array = []
#	for i in node.get_child_count():
##		order += 1
#		var child = node.get_child(i)
#		print(child.name, ", class = ", child.get_class())
#		var dict : Dictionary = {}
#		dict["name"] = child.name
#		dict["node_path"] = root.get_path_to(child)
##		dict["order"] = order
#		if child is LHSprite:
#			sprite_to_data(child, dict)
#		elif child is LHBezierTrack:
#			terrian_to_data(child, dict)
#		else:
#			var children : Array = group_to_data2(root, child)
##			if children.size() > 0:
#			dict["children"] =  children
#		data.push_back(dict)
#	return data

static func is_a_group(node : Node):
	var class_type := node.get_class()
	return class_type == "Node2D"

static func is_a_sprite(node : Node):
	return node is LHSprite

static func is_a_terrian(node : Node):
#	var class_type := node.get_class()
	return node is LHBezierTrack

static func sprite_to_data(child : LHSprite, root : Node) -> Dictionary:
	var data := {"type" : "sprite"}
	var pos : Vector2 = child.get_global_transform().get_origin()
	var scale : Vector2 = child.get_global_transform().get_scale()
	var size : Vector2
	if child.is_region():
		var region : Rect2 = child.get_region_rect()
		size = region.size
		data["region"] = {"x" : region.position.x, "y" : region.position.y, "cw" : child.texture.get_width(), "ch" : child.texture.get_height()}
	else:
		size = child.get_rect().size
	data["name"] = child.name
	data["node_path"] = root.get_path_to(child)
	data["x"] = pos.x
	data["y"] = pos.y
	data["rotation"] = rad2deg(child.get_global_transform().get_rotation())
	data["xScale"] = scale.x
	data["yScale"] = scale.y
	data["width"] = size.x
	data["height"] = size.y
	data["flip_h"] = child.flip_h
	data["flip_v"] = child.flip_v
	data["visible"] = child.visible_in_level
	data["color"] = Util.to_corona_color(child.self_modulate)
	data["tag"] = child.tag
#	if child.flip_h:
#		data["name"] = data["name"] + ";flipX=1"
	if child.texture != null:
		data["res_path"] = child.texture.resource_path
#		data["name"] = data["name"] + ";ext=" + data["res_path"].get_extension()
	if not child.custom_class_is_empty():
		data["custom_info"] = child.custom_class_to_dictionary()
	if child.has_physic():
#		print(child.name)
		data["physic_properties"] = child.get_physic_properties()
	return data

static func animated_sprite_to_data(node : LHAnimatedSprite, root : Node) -> Dictionary:
	var data := node.to_data()
	var pos : Vector2 = node.get_global_transform().get_origin()
	var scale : Vector2 = node.get_global_transform().get_scale()
	data["type"] = "animated_sprite"
	data["node_path"] = root.get_path_to(node)
	data["x"] = pos.x
	data["y"] = pos.y
	data["xScale"] = scale.x
	data["yScale"] = scale.y
	data["rotation"] = rad2deg(node.get_global_transform().get_rotation())
	data["visible"] = node.visible_in_level
	data["color"] = Util.to_corona_color(node.self_modulate)
	data["tag"] = node.tag
	if not node.custom_class_is_empty():
		data["custom_info"] = node.custom_class_to_dictionary()
	if node.has_physic():
		data["physic_properties"] = node.get_physic_properties()
	return data

static func terrian_to_data(node : LHBezierTrack, root : Node) -> Dictionary:
	var data := {"type" : "terrian"}
	data["name"] = node.name
	data["node_path"] = root.get_path_to(node)
	data["is_closed"] = node.is_closed
	data["spacing"] = node.spacing
	data["tms"] = node.tessellate_max_stages
	data["tol"] = node.tessellate_tolerance
	data["visible"] = node.visible_in_level
	if node.has_track:
		var track_data : Dictionary = {}
#		track_data["res_path"] = node.track_texture.resource_path
		track_data["track_height"] = node.track_height
		track_data["color"] = Util.to_corona_color(node.track_color)
		track_data["mesh"] = node.track.get_mesh_data()
		data["track"] = track_data

	var texture := node.ground_texture
	if node.has_ground && (texture != null || node.is_ground_colored_polygon):
		var ground_data : Dictionary = {}
		ground_data["color"] = Util.to_corona_color(node.ground_color)
		ground_data["tiling"] = Util.vector2_to_array(node.ground.tiling)
		ground_data["mesh"] = node.ground.get_mesh_data()
		if texture != null:
			ground_data["res_path"] = texture.resource_path
			ground_data["wh"] = [texture.get_width(), texture.get_height()]
		data["ground"] = ground_data
#	data["tesslate_points"] = Util.vector2_array_to_array(node.get_curve().tessellate())
	data["curve"] = node.get_bezier_curve_data()
	if node.fixture_type == "edge_godot" or node.fixture_type == "edge":
		data["edge_points"] = node.get_edge_data()
	var pos : Vector2 = node.get_global_transform().get_origin()
	var scale : Vector2 = node.get_global_transform().get_scale()
	data["x"] = pos.x
	data["y"] = pos.y
	data["rotation"] = node.get_global_transform().get_rotation()
	data["xScale"] = scale.x
	data["yScale"] = scale.y

	data["physic_properties"] = node.get_physic_properties()
	if not node.custom_class_is_empty():
		data["custom_info"] = node.custom_class_to_dictionary()

	return data

static func joint_to_data(node : CoronaJoint, root : Node) -> Dictionary:
	var data := node.to_data()
	data["node_path"] = root.get_path_to(node)
	return data
