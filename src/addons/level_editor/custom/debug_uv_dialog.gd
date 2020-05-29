# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool


extends ConfirmationDialog

const LHCollisionPolygon2D = preload("../physics/lh_collision_polygon_2d.gd")

var edit_object : Sprite
var debug_uv : Control
var simplification : SpinBox
var island_merging : SpinBox
var update_preview : Button
var outline_lines : Array
var computed_outline_lines : Array

func manual_init():
	outline_lines = Array()
	computed_outline_lines = Array()
	
	get_ok().set_text("Create CollisionPolygon2D")
	set_title("CollisionPolygon2D Preview")
	var vb := VBoxContainer.new()
	add_child(vb)
	var scroll = ScrollContainer.new()
	scroll.set_custom_minimum_size(Vector2(800, 500))
	scroll.set_enable_h_scroll(true)
	scroll.set_enable_v_scroll(true)
	add_margin_child(vb, "Preview", scroll, true)
	debug_uv = Control.new()
	debug_uv.connect("draw", self, "_debug_uv_draw")
	scroll.add_child(debug_uv)
	connect("confirmed", self, "_create_collision_shape")
	
	var hb := HBoxContainer.new()
	var label := Label.new()
	label.set_text("Simplification: ")
	hb.add_child(label)
	simplification = SpinBox.new()
	simplification.set_min(0.01)
	simplification.set_max(64.00)
	simplification.set_step(0.01)
	simplification.set_value(2)
	hb.add_child(simplification)
	hb.add_spacer(false)
	label = Label.new()
	label.set_text("Grow (Pixels): ")
	hb.add_child(label)
	island_merging = SpinBox.new()
	island_merging.set_min(0)
	island_merging.set_max(64)
	island_merging.set_step(1)
	island_merging.set_value(0)
	hb.add_child(island_merging)
	hb.add_spacer(false)
	update_preview = Button.new()
	update_preview.set_text("Update Preview")
	update_preview.connect("pressed", self, "_update_mesh_data")
	hb.add_child(update_preview)
	add_margin_child(vb, "Settings:", hb, false)

func set_target_sprite(spr : Sprite):
	edit_object = spr

func add_margin_child(parent, label : String, control, expand : bool):
	var l := Label.new()
	l.set_text(label)
	parent.add_child(l)
	var mc := MarginContainer.new()
	mc.add_constant_override("margin_left", 0)
	mc.add_child(control)
	parent.add_child(mc)
	if expand:
		mc.set_v_size_flags(Control.SIZE_EXPAND_FILL)

func _update_mesh_data():
	if edit_object != null:
		var tex := edit_object.get_texture()
		if tex == null:
			print("Sprite is empty!")
		else:
			var img := tex.get_data()
			var rect : Rect2
			if edit_object.is_region():
				rect = edit_object.get_region_rect()
			else:
				rect = Rect2(Vector2.ZERO, Vector2(img.get_width(), img.get_height()))
	
			var bm := BitMap.new()
			bm.create_from_image_alpha(img)
			
			var grow := island_merging.get_value()
			if grow > 0:
				bm.grow_mask(grow, rect)
	
			var epsilon := simplification.get_value()
			
			var lines := bm.opaque_to_polygons(rect, epsilon)
			outline_lines.clear()
			computed_outline_lines.clear()
			outline_lines.resize(lines.size())
			computed_outline_lines.resize(lines.size())
			for i in lines.size():
#				var col :PoolVector2Array = lines[i]
				var ol := PoolVector2Array()
				var poly := PoolVector2Array()
				ol.resize(lines[i].size())
				poly.resize(lines[i].size())
				for j in lines[i].size():
					var vtx :Vector2 = lines[i][j]
					vtx -= rect.position
					ol.set(j, Vector2(vtx.x, vtx.y))

					if (edit_object.is_flipped_h()):
						vtx.x = rect.size.x - vtx.x - 1.0;
					if (edit_object.is_flipped_v()):
						vtx.y = rect.size.y - vtx.y - 1.0;

					if (edit_object.is_centered()):
						vtx -= rect.size / 2.0

					poly.set(j, vtx)
				
				outline_lines[i] = ol
				computed_outline_lines[i] = poly
				
			debug_uv.update()

func _debug_uv_draw():
	if edit_object != null:
		var tex := edit_object.get_texture()
		if tex != null:
			debug_uv.set_clip_contents(true)
			debug_uv.draw_texture(tex, Vector2.ZERO)
			debug_uv.set_custom_minimum_size(tex.get_size())
		
		var color = Color(1.0, 0.8, 0.7)
		for i in outline_lines.size():
			var outline :PoolVector2Array = outline_lines[i]
			debug_uv.draw_polyline(outline, color)
			debug_uv.draw_line(outline[0], outline[outline.size() - 1], color)
		
func _create_collision_shape():
	if edit_object != null:
		for i in computed_outline_lines.size():
			var outline: PoolVector2Array = computed_outline_lines[i]
			if outline.size() < 3:
				prints("Invalid geometry, can't create collision polygon.", i, outline.size())
			else:
				var fixture := LHCollisionPolygon2D.new()
				fixture.name = "fixture_polygon"
				edit_object.add_child(fixture, true)
				fixture.set_meta("_edit_lock_", true)
				fixture.set_visible(edit_object.has_physic())
				fixture.set_owner(get_tree().edited_scene_root)
				fixture.set_polygon(outline)

func show():
	_update_mesh_data()
	popup_centered()
	debug_uv.update()