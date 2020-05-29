# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends EditorPlugin

const Util = preload("utils/util.gd")
const Export = preload("utils/export.gd")
const NodeManager = preload("utils/node_manager.gd")
const NameManager = preload("utils/name_manager.gd")
const LHBezierTrack = preload("lh_bezier_track.gd")
const LHSprite = preload("lh_sprite.gd")
const LHLayer = preload("lh_layer.gd")
const LHFixture = preload("physics/lh_fixture.gd")
const CoronaJoint = preload("physics/corona_joint.gd")
const DebugDialog = preload("custom/debug_uv_dialog.gd")
const LevelsDialog = preload("custom/levels_select_dialog.gd")
const EditorPanel = preload("level_editor_pannel.tscn")

var corona_dir : String
var godot_dir : String
var scenes_export_dir : String

var file_dialog : FileDialog
var warning_dialog : AcceptDialog
var debug_uv_dialog : DebugDialog
var level_export_dialog : LevelsDialog
var dock
var edit_node

var name_manger : NameManager

func _enter_tree():
	godot_dir = ProjectSettings.globalize_path("res://")
	corona_dir = ProjectSettings.globalize_path("res://corona")
	scenes_export_dir = corona_dir.plus_file("assets/levels/export")

	# Initialization of the plugin goes here
	# Load the dock scene and instance it
	dock = EditorPanel.instance()

	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
#	file_dialog.connect("file_selected", self, "_on_save_file", ["test_bind"])

	var gui := get_editor_interface().get_base_control()
	gui.add_child(file_dialog)

	warning_dialog = AcceptDialog.new()
	gui.add_child(warning_dialog)

	debug_uv_dialog = DebugDialog.new()
	debug_uv_dialog.manual_init()
	gui.add_child(debug_uv_dialog)
	dock.debug_uv_dialog = debug_uv_dialog

	level_export_dialog = LevelsDialog.new()
	level_export_dialog.editor_interface = get_editor_interface()
	level_export_dialog.warning_dialog = warning_dialog
	level_export_dialog.manual_init()
	gui.add_child(level_export_dialog)
	dock.level_export_dialog = level_export_dialog

	# Add the loaded scene to the docks
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	dock.gui = gui
	dock.warning_dialog = warning_dialog

	# Note that LEFT_UL means the left of the editor, upper-left dock
	add_custom_type("LHLayer", "Node2D", LHLayer, null)
	add_custom_type("LHSprite", "Sprite", LHSprite, null)
	add_custom_type("LHBezierTrack", "Path2D", LHBezierTrack, null )
	add_custom_type("AA_LHFixture", "Resource", LHFixture, null )

func _ready():
	name_manger = NameManager.new()
	name_manger.node_manager = NodeManager
#	get_tree().connect("node_added", self, "_on_node_added")
#	Util.disconnect_all(get_tree(), "node_added")
	var tree := get_tree()
	if tree.is_connected("node_added", NodeManager, "node_added"):
		tree.disconnect("node_added", NodeManager, "node_added")
	if tree.is_connected("node_removed", NodeManager, "node_removed"):
		tree.disconnect("node_removed", NodeManager, "node_removed")
	tree.connect("node_added", NodeManager, "node_added", [get_tree(), name_manger])
	tree.connect("node_removed", NodeManager, "node_removed", [get_tree(), name_manger])
	dock.connect("export_scene", self, "_on_export_scene")
	dock.connect("import_scene", self, "_on_import_scene")
	dock.connect("import_from_sprite_helper", self, "_on_import_from_sprite_helper")

static func _get_lh_sprite_from_object(object):
	if object != null and object is Node2D:
		if object is LHSprite or object is LHBezierTrack:
			return object
		elif object.get_class() == "Node2D":
			return object
	return null

func handles(object):
	return _get_lh_sprite_from_object(object) != null

func edit(object):
	print("Edit ", object)
	edit_node = _get_lh_sprite_from_object(object)
	dock.set_edit_object(edit_node)

func make_visible(visible : bool):
	if not edit_node:
		return
	if not visible:
		edit_node = null
		dock.set_edit_object(null)
	update_overlays()

func forward_canvas_draw_over_viewport(overlay : Control):
	if edit_node == null || !edit_node.is_inside_tree():
		return
	if edit_node is CoronaJoint:
		edit_node.update_anchor(overlay)

func forward_canvas_gui_input(event : InputEvent) -> bool:
	if not edit_node or not edit_node.visible:
		return false
	if edit_node is CoronaJoint:
		return edit_node.drag_anchor(event, self)
	return false

func translate_export_path(node : LHLayer) -> String:
	var path := node.export_path
	if !path.empty():
		return path.replace(godot_dir, "")
	return path

func _on_export_scene():
	var root = get_editor_interface().get_edited_scene_root()
	if root != null && root.get_script() == LHLayer:
		var export_path := translate_export_path(root)
#		if export_path.empty() || !File.new().file_exists(export_path):
		if export_path.empty() || !Directory.new().dir_exists(export_path.get_base_dir()):
			file_dialog.clear_filters()
			file_dialog.add_filter("*.json ; Level data")
			file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
			Util.disconnect_all(file_dialog, "file_selected")
			file_dialog.connect("file_selected", Export, "to_corona", [root, warning_dialog])
			if export_path.get_base_dir().begins_with(scenes_export_dir):
				file_dialog.set_current_dir(export_path.get_base_dir())
			else:
				file_dialog.set_current_dir(scenes_export_dir)
#			file_dialog.set_current_file(file_dialog.get_current_dir().plus_file(root.get_filename().get_file().get_basename() + ".json"))
			file_dialog.popup_centered_ratio()
		else:
			Export.to_corona(export_path, root, warning_dialog)
	else:
		warning_dialog.dialog_text = "Scene root node is not Node2D!"
		warning_dialog.popup_centered_ratio(0.3)

func _exit_tree():
	var tree := get_tree()
	if tree.is_connected("node_added", NodeManager, "node_added"):
		tree.disconnect("node_added", NodeManager, "node_added")
	if tree.is_connected("node_removed", NodeManager, "node_removed"):
		tree.disconnect("node_removed", NodeManager, "node_removed")
	edit(null)
	get_editor_interface().get_base_control().remove_child(file_dialog)
	get_editor_interface().get_base_control().remove_child(warning_dialog)
	get_editor_interface().get_base_control().remove_child(debug_uv_dialog)
	get_editor_interface().get_base_control().remove_child(level_export_dialog)
	# Clean-up of the plugin goes here
	# Remove the dock
	remove_control_from_docks(dock)
	 # Erase the control from the memory
	file_dialog.queue_free()
	file_dialog = null

	warning_dialog.queue_free()
	warning_dialog = null

	debug_uv_dialog.queue_free()
	debug_uv_dialog = null

	level_export_dialog.editor_interface = null
	level_export_dialog.warning_dialog = null
	level_export_dialog.queue_free()
	level_export_dialog = null

	dock.gui = null
	dock.debug_uv_dialog = null
	dock.level_export_dialog = null
	dock.warning_dialog = null
	dock.queue_free()
	dock = null
	remove_custom_type("LHLayer")
	remove_custom_type("LHSprite")
	remove_custom_type("LHBezierTrack")
	remove_custom_type("AA_LHFixture")

	name_manger.clear()
	name_manger = null
