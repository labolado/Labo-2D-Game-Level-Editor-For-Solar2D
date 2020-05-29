# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Control

const LHCollisionShape2D = preload("physics/lh_collision_shape_2d.gd")
const LHCollisionPolygon2D = preload("physics/lh_collision_polygon_2d.gd")
const CoronaPivotJoint = preload("physics/corona_pivot_joint.gd")
const CoronaWeldJoint = preload("physics/corona_weld_joint.gd")
const CoronaWheelJoint = preload("physics/corona_wheel_joint.gd")
const CoronaRopeJoint = preload("physics/corona_rope_joint.gd")
const CoronaDistanceJoint = preload("physics/corona_distance_joint.gd")
const CoronaPistonJoint = preload("physics/corona_piston_joint.gd")
const CoronaFrictionJoint = preload("physics/corona_friction_joint.gd")
const CoronaPulleyJoint = preload("physics/corona_pulley_joint.gd")
const CoronaGearJoint = preload("physics/corona_gear_joint.gd")
const LHBezierTrack = preload("lh_bezier_track.gd")
const LHPath = preload("lh_path.gd")
const LHSprite = preload("lh_sprite.gd")
const LHLayer = preload("lh_layer.gd")
const Hole = preload("terrian/hole.gd")
const DebugDialog = preload("custom/debug_uv_dialog.gd")
const LevelsDialog = preload("custom/levels_select_dialog.gd")

signal export_scene
signal import_scene
signal import_from_sprite_helper
#signal create_collision_rect_shape
#signal create_collision_circle_shape
#signal create_collision_polygon_shape

var gui : Control
var debug_uv_dialog : DebugDialog
var level_export_dialog : LevelsDialog
var warning_dialog : AcceptDialog
var edit_object : LHSprite
var edit_bezier_terrian : LHBezierTrack
var edit_node : Node2D
var edit_target : Node2D

func set_edit_object(value):
	if value != null:
		edit_target = value
		if value is LHSprite:
			edit_object = value
			debug_uv_dialog.set_target_sprite(value)
		elif value is LHBezierTrack:
			edit_bezier_terrian = value
		elif value.get_class() == "Node2D":
			edit_node = value
	else:
		edit_object = null
		edit_bezier_terrian = null
		edit_node = null
		edit_target = null
		debug_uv_dialog.set_target_sprite(null)
#	var is_visible = value != null
#	get_node("VBoxContainer/Physics").set_visible(is_visible)

func _on_Export_pressed():
	print("Export to corona: ")
	emit_signal("export_scene")

func _on_Import_pressed():
	print("Import from LevelHelper: ")
	emit_signal("import_scene")

func _on_Rect_pressed():
	if edit_object != null and edit_object.is_inside_tree():
		var fixture := LHCollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.extents = edit_object.get_rect().size * 0.5
		fixture.shape = shape
		fixture.name = "fixture_rect"
		edit_object.add_child(fixture, true)
		fixture.set_meta("_edit_lock_", true)
		fixture.set_visible(edit_object.has_physic())
		fixture.set_owner(get_tree().edited_scene_root)

func _on_Circle_pressed():
	if edit_object != null and edit_object.is_inside_tree():
		var fixture := LHCollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = edit_object.get_rect().size.x * 0.5
		fixture.shape = shape
		fixture.name = "fixture_circle"
		edit_object.add_child(fixture, true)
		fixture.set_meta("_edit_lock_", true)
		fixture.set_visible(edit_object.has_physic())
		fixture.set_owner(get_tree().edited_scene_root)

func _on_Polygon_pressed():
	if edit_object != null and edit_object.is_inside_tree():
		var fixture := LHCollisionPolygon2D.new()
		fixture.name = "fixture_polygon"
		edit_object.add_child(fixture, true)
		fixture.set_meta("_edit_lock_", true)
		fixture.set_visible(edit_object.has_physic())
		fixture.set_owner(get_tree().edited_scene_root)

func _on_AutoPolygon_pressed():
	if edit_object != null and edit_object.is_inside_tree():
		debug_uv_dialog.show()

func _on_Hole_pressed():
	if edit_bezier_terrian != null and edit_bezier_terrian.is_inside_tree():
		var hole := Hole.new()
		hole.name = "hole"
		edit_bezier_terrian.add_child(hole)
		hole.set_owner(get_tree().edited_scene_root)
		hole.manual_init()

func _on_AddTerrian_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var terrian := LHBezierTrack.new()
		terrian.name = "terrian"
		edit_node.add_child(terrian, true)
		terrian.set_owner(get_tree().edited_scene_root)

func _on_AddRoad_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var terrian := LHBezierTrack.new()
		terrian.name = "terrian_road"
		terrian.fixture_type = "edge_godot"
		terrian.object_type = "static"
		edit_node.add_child(terrian, true)
		terrian.set_owner(get_tree().edited_scene_root)

func _on_Path_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var path := LHPath.new()
		path.name = "PATH_FOLLOW"
		edit_node.add_child(path, true)
		path.set_owner(get_tree().edited_scene_root)

func _on_Centering_pressed():
	if edit_node != null and edit_node.is_inside_tree() and edit_node.is_class("Node2D"):
		var children : Array = edit_node.get_children()
		if children.size() > 0:
			if children[0] is Sprite:
				var rect : Rect2 = children[0].get_rect()
				for child in children:
					if child is Sprite:
						rect = rect.merge(child.get_rect())
				edit_node.position = rect.position + rect.size * 0.5
#				for child in children:
#					child.position = child.position -rect.position - rect.size * 0.5

func _on_Clone_pressed():
	if edit_target != null and edit_target.is_inside_tree():
		var root = get_tree().edited_scene_root
		if edit_target != root and (edit_target is LHBezierTrack or edit_target is LHSprite):
			var new_target := edit_target.duplicate()
			edit_target.get_parent().add_child(new_target)
			new_target.set_owner(root)
			new_target.when_duplicate()
			if edit_target is LHBezierTrack:
				for child in new_target.get_children():
					if child.name.begins_with("hole") and child is Path2D:
						child.set_owner(root)

func _on_ImportFromSpriteHelper_pressed():
	print("Import from SpriteHelper")
	emit_signal("import_from_sprite_helper")

func _on_set_node_error(text : String):
	warning_dialog.set_text(text)
	warning_dialog.popup_centered_ratio(0.3)

func _on_pivot_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaPivotJoint.new()
		joint.name = "joint_pivot"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_weld_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaWeldJoint.new()
		joint.name = "joint_weld"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_wheel_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaWheelJoint.new()
		joint.name = "joint_wheel"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_rope_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaRopeJoint.new()
		joint.name = "joint_rope"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_distance_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaDistanceJoint.new()
		joint.name = "joint_distance"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_piston_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaPistonJoint.new()
		joint.name = "joint_piston"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_friction_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaFrictionJoint.new()
		joint.name = "joint_friction"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_pulley_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaPulleyJoint.new()
		joint.name = "joint_pulley"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func _on_gear_pressed():
	if edit_node != null and edit_node.is_inside_tree():
		var root := get_tree().edited_scene_root
		var joint := CoronaGearJoint.new()
		joint.name = "joint_gear"
		root.add_child(joint, true)
		joint.set_owner(root)
		joint.set_meta("_editor_icon", gui.get_icon("PinJoint2D", "EditorIcons"))
		joint.connect("set_node_error", self, "_on_set_node_error")

func travale_set_physic_shapes_visible(node : Node, value : bool):
	if node is LHSprite:
		node.set_physic_shapes_visible(value)
	if node is LHLayer:
		for child in node.get_children():
			travale_set_physic_shapes_visible(child, value)

func _on_ShowPhysic_toggled(button_pressed : bool):
	var root := get_tree().edited_scene_root
	if root != null and root.is_inside_tree():
		travale_set_physic_shapes_visible(root, button_pressed)

func travale_list_custom_class(node : Node, root : Node):
	if node is LHLayer or node is LHSprite or node is LHBezierTrack:
		if not node.custom_class_is_empty():
			printt(node.name, node.custom_class_to_dictionary())
	if node is LHLayer and (node.get_owner() == root or node == root):
		for child in node.get_children():
			travale_list_custom_class(child, root)

func _on_ShowCustom_pressed():
	var root := get_tree().edited_scene_root
	if root != null and root.is_inside_tree():
		travale_list_custom_class(root, root)


func _on_ExportAll_pressed():
	level_export_dialog.show()
