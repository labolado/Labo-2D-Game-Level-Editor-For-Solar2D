# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool

extends Path2D

export(float) var time = 1.0
export(float) var spacing = 32 setget set_spacing
export(bool) var start_at_launch = false
export(bool) var relative_movement = true
export(bool) var start_at_end_point = false
export(bool) var cyclic_motion = false
export(bool) var restart_at_other_end = false
export(bool) var flip_x_at_end = false setget set_flip_x_at_end
export(bool) var flip_y_at_end = false setget set_flip_y_at_end
export(bool) var rotate_alone_path = true
export(bool) var cubic_interp = true
export(float) var lookahead = 4.0
export(bool) var preview_in_editor = false setget set_preview_in_editor

var version : int = 2
var orientation : int = 0

func _get_property_list():
	return [{"name" : "version", "type" : TYPE_INT, "usage" : PROPERTY_USAGE_STORAGE}]
	return [{"name" : "orientation", "type" : TYPE_INT, "usage" : PROPERTY_USAGE_STORAGE}]

var t : float = 0.0
var path_pos : Vector2
var path_first_pos := Vector2.ZERO
var path_dir : int = 1
var path_rotation : float = 0
var path_scale : Vector2 = Vector2.ONE

func set_spacing(value : float):
	spacing = value
	curve.set_bake_interval(value)

func set_flip_x_at_end(value : bool):
	flip_x_at_end = value
	path_scale = Vector2.ONE

func set_flip_y_at_end(value : bool):
	flip_y_at_end = value
	path_scale = Vector2.ONE

func _process(delta):
	if preview_in_editor and Engine.is_editor_hint() and curve.get_point_count() > 0:
		t += delta
		var ratio : float = t / time

		path_pos = interpolate_baked(ratio)
		
		if cyclic_motion:
			if ratio > 1.0:
				t = fmod(t, time)
				if restart_at_other_end:
					t = 0.0
					path_dir = -path_dir
				if flip_x_at_end:
					path_scale.x = -path_scale.x
				if flip_y_at_end:
					path_scale.y = -path_scale.y
		
		if rotate_alone_path:
			var path_length : float = curve.get_baked_length()
			var offset : float = ratio * path_length
			if cyclic_motion:
				offset = fposmod(offset, path_length)
			else:
				offset = clamp(offset, 0, path_length)
			var ahead : float = offset + lookahead
			
			if cyclic_motion and ahead >= path_length:
				if is_path_closed():
					ahead = fmod(ahead, path_length)
			
			var ahead_pos : Vector2 = interpolate_baked(ahead / path_length)
			var tagent_to_curve : Vector2
			if ahead_pos == path_pos:
				tagent_to_curve = interpolate_baked((offset - lookahead) / path_length).normalized()
			else:
				tagent_to_curve = (ahead_pos - path_pos).normalized()
			
			path_rotation = tagent_to_curve.angle()
		update()

func is_path_closed() -> bool:
	var point_count := curve.get_point_count()
	if point_count > 0:
		var start_point := curve.get_point_position(0)
		var end_point := curve.get_point_position(point_count - 1)
		return start_point == end_point
	return false

func interpolate_baked(ratio : float) -> Vector2:
	if path_dir == 1:
		return curve.interpolate_baked(ratio * curve.get_baked_length(), cubic_interp)
	else:
		return curve.interpolate_baked((1 - ratio) * curve.get_baked_length(), cubic_interp)
		
func set_preview_in_editor(value : bool):
	preview_in_editor = value
	t = 0.0
	path_scale = Vector2.ONE
	path_rotation = 0
	if start_at_end_point:
		path_dir = -1
	if curve.get_point_count() > 0:
		curve.set_bake_interval(spacing)
		path_first_pos = curve.interpolate_baked(0, true)
	set_process(value)

func _draw():
	if preview_in_editor and Engine.is_editor_hint():
		for target in get_children():
			if target is Sprite:
				var offset := Vector2.ZERO
				if relative_movement:
					offset = target.position - path_first_pos
				var current_rotation : float = target.rotation
				if rotate_alone_path:
					current_rotation += + path_rotation + deg2rad(90)

				draw_set_transform(path_pos + offset, current_rotation, target.scale * path_scale)
				if target.is_region():
					var region : Rect2 = target.get_region_rect()
					var size : Vector2 = region.size
					var rect := Rect2(-size * 0.5, size)
					draw_texture_rect_region(target.texture, rect, region)
				else:
					var size : Vector2 = target.get_rect().size
					draw_texture(target.texture, -size * 0.5)

func is_valid() -> bool:
	if curve.get_point_count() > 1 and get_child_count() > 0:
		return true
	return false

func curve_to_data() -> Array:
	var curve_data : Array = []
	var count = curve.get_point_count()
	curve_data.resize(count)
	for i in range(count):
		var p = curve.get_point_position(i)
		var p_in = curve.get_point_in(i)
		var p_out = curve.get_point_out(i)
		curve_data[i] = [p.x, p.y, p_in.x, p_in.y, p_out.x, p_out.y]
	return curve_data

func to_data() -> Dictionary:
	var dict := {
		version = version,
		time = time,
		spacing = spacing,
		startAtLaunch = start_at_launch,
		relativeMove = relative_movement,
		startAtEndPoint = start_at_end_point,
		cyclicMotion = cyclic_motion,
		restartAtOtherEnd = restart_at_other_end,
		flipX = flip_x_at_end,
		flipY = flip_y_at_end,
		cubicInterp = cubic_interp,
		rotate = rotate_alone_path,
		lookahead = lookahead,
		orientation = orientation
	}
	dict["curve"] = curve_to_data()
	return dict
