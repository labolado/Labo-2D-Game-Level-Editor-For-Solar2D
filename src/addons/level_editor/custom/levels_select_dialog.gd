# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends ConfirmationDialog

const Export = preload("../utils/export.gd")
const LHLayer = preload("../lh_layer.gd")
#const TempScene = preload("../temp.tscn")

const TEMP_SCENE_FILE = "res://addons/level_editor/temp.tscn"
const LEVELS_DIR = "res://levels"

var files : Tree
var corona_dir : String
var editor_interface : EditorInterface
var warning_dialog : AcceptDialog
var paths : Array = []
var results : Array = []

func manual_init():
	corona_dir = ProjectSettings.globalize_path("res://").get_base_dir().get_base_dir()
	var vbc := VBoxContainer.new()
	add_child(vbc)

	files = Tree.new()
	files.set_columns(1)
	files.set_column_titles_visible(true)
	files.set_column_expand(0, true)
	files.set_column_title(0, "Levels")
	files.set_hide_root(true)
	
	var hbc := HBoxContainer.new()
	var label := Label.new()
	label.set_text("Levels to Export:")
	hbc.add_child(label)
	hbc.add_spacer(false)
	var select_all := Button.new()
	select_all.set_text("Reverse Select All")
	hbc.add_child(select_all)
	select_all.connect("pressed", self, "_select_all")
	
	vbc.add_child(hbc)
	
	add_margin_child(vbc, files, true)
	
	set_title("Levels Explorer")
	get_ok().set_text("export")
	get_ok().connect("pressed", self, "_export_pressed")

func add_margin_child(parent, control : Control, expand : bool):
	var mc := MarginContainer.new()
	mc.add_constant_override("margin_left", 0)
	mc.add_child(control)
	parent.add_child(mc)
	if expand:
		mc.set_v_size_flags(Control.SIZE_EXPAND_FILL)

func refresh():
	var efsd := editor_interface.get_resource_filesystem().get_filesystem_path(LEVELS_DIR)
	_fill_owners(efsd, null)
	files.clear()
	var root := files.create_item()
	_fill_owners(efsd, root)

func show():
	var scenes := editor_interface.get_open_scenes()
	var has_level_scenes_open := false
	var list := []
	for i in scenes.size():
		var sc : String = scenes[i]
		if sc.begins_with(LEVELS_DIR) or sc.begins_with("res://sprites"):
			has_level_scenes_open = true
			list.push_back(sc)

	if has_level_scenes_open:
		var text := "Please close the open scene!\n"
		for sc in list:
			text += sc + "\n"
		warning_dialog.dialog_text = text
		warning_dialog.popup_centered_ratio(0.3)
	else:
		refresh()
		popup_centered_ratio()

func _fill_owners(efsd : EditorFileSystemDirectory, parent : TreeItem) -> bool:
	if !efsd:
		return false

	var has_children := false

	for i in efsd.get_subdir_count():
		var dir_item : TreeItem
		if parent != null:
			dir_item = files.create_item(parent)
			dir_item.set_text(0, efsd.get_subdir(i).get_name())
			dir_item.set_icon(0, get_icon("folder", "FileDialog"))
		var children := _fill_owners(efsd.get_subdir(i), dir_item)

		if parent:
			if !children:
				dir_item.free()
			else:
				has_children = true

	for i in efsd.get_file_count():
		if parent != null:
			var type := efsd.get_file_type(i)
			if type == "PackedScene":
				var path := efsd.get_file_path(i)
				var ti := files.create_item(parent)
				ti.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				ti.set_text(0, efsd.get_file(i))
				ti.set_editable(0, true)
#				if efsd.get_path().ends_with("/levels/") or efsd.get_parent().get_path().ends_with("/levels/"):
#					ti.set_checked(0, true)

				ti.set_checked(0, true)
				var icon := get_icon(type, "EditorIcons")
				ti.set_icon(0, icon)
				ti.set_metadata(0, path)
				has_children = true

	return has_children

func _select_all():
	_reverse_select(files.get_root())

func _reverse_select(item : TreeItem):
	while item != null:
		if item.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK:
			item.set_checked(0, !item.is_checked(0))
	
		if item.get_children():
			_reverse_select(item.get_children())
	
		item = item.get_next()

func _find_to_export(item : TreeItem):
	while item != null:
		if item.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK && item.is_checked(0):
			paths.push_back(item.get_metadata(0))

		if item.get_children():
			_find_to_export(item.get_children())

		item = item.get_next()

func _translate_export_path(node : LHLayer) -> String:
	var path := node.export_path
	if !path.empty():
		var what := "/src/main/"
		var index := path.find(what)
		if index:
			var file := path.right(index + what.length())
			return corona_dir.plus_file("main/" + file)
	return path

func _export_pressed():
	paths.clear()
	_find_to_export(files.get_root())
	if !paths.empty():
		results.clear()
		for i in paths.size():
			export_scene(paths[i])

		print()
		print()
		print("----------------------------- Export All Output -----------------------------")
		for msg in results:
			print(msg)

func export_scene(path : String):
	editor_interface.open_scene_from_path(TEMP_SCENE_FILE)
#	var node := editor_interface.get_edited_scene_root()
#	var tree := node.get_tree()

	var scene : PackedScene = ResourceLoader.load(path, "PackedScene", true)
	var node := scene.instance(PackedScene.GEN_EDIT_STATE_INSTANCE) as LHLayer
	if node != null:
		var export_path := _translate_export_path(node)
		if export_path.empty() || !Directory.new().dir_exists(export_path.get_base_dir()):
#			print("Invalid export path: " + path)
			results.push_back("Invalid Export: " + path)
		else:
#			print("Export: " + path + " ---> " + export_path)
			results.push_back("EXPORT: " + path + " ---> " + export_path.replace(corona_dir.plus_file("/"), ""))
			var tree := editor_interface.get_edited_scene_root().get_tree()
			tree.get_root().add_child(node)
			node.propagate_call("_draw")
			Export.to_corona(export_path, node, null)
			node.get_parent().remove_child(node)
	else:
#		print("No need to export: " + path)
		results.push_back("No Need To Export: " + path)
	node.free()
