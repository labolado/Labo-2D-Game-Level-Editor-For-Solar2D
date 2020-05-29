# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Node2D

const OFFSET_Y = 1536 * 3
const Util = preload("utils/util.gd")

var version : int = 1 setget set_version
var texture : Texture = null setget set_texture
var spacing : float = 512 setget set_spacing
var tessellate_max_stages : int = 5 setget set_tessellate_max_stages
var tessellate_tolerance : float = 2 setget set_tessellate_tolerance
var is_closed : bool = false setget set_is_closed
var is_colored_polygon : bool = false setget set_is_colored_polygon

var tiling_scale : Vector2 = Vector2.ONE
var init_tiling : Vector2 = Vector2.ONE
var tiling : Vector2 = Vector2.ONE setget set_tiling
var texture_offset : Vector2 = Vector2.ZERO setget set_texture_offset
var texture_rotation : float = 0 setget set_texture_rotation

var path : Path2D
#var curve : Curve2D

var _mesh : Array = []

func _init():
	_mesh.resize(Mesh.ARRAY_MAX)

func update_curve_now():
#	print("update_curve_ground")
	update()

func set_version(value : int):
	version = value
	update()

func set_texture(tex : Texture):
	texture = tex
	update()

func set_spacing(value : float):
	spacing = value
	update()

func set_tessellate_max_stages(value : int):
	tessellate_max_stages = value
	update()

func set_tessellate_tolerance(value : float):
	tessellate_tolerance = value
	update()

func set_is_closed(value : bool):
	is_closed = value
	update()

func set_is_colored_polygon(value : bool):
	is_colored_polygon = value
	update()

func set_tiling(tiling_value : Vector2):
	tiling = tiling_value / tiling_scale
#	get_material().set_shader_param("tiling", tiling)
	update()

func set_texture_offset(offset : Vector2):
	texture_offset = offset
	update()

func set_texture_rotation(value : float):
	texture_rotation = deg2rad(value)
	update()

func get_points_bounds(points : PoolVector2Array) -> Array:
	var x_min = INF
	var y_min = INF
	var x_max = -INF
	var y_max = -INF
	for i in range(points.size()):
		var p = points[i]
		x_min = min(p.x, x_min)
		x_max = max(p.x, x_max)
		y_min = min(p.y, y_min)
		y_max = max(p.y, y_max)
	return [x_min, x_max, y_min, y_max]

func get_holes() -> Array:
	var result = []
	for child in get_parent().get_children():
		if child.name.begins_with("hole") && child is Path2D:
			result.push_back(child)
	return result

func calculate_evenly_spacedPoints(curve : Curve2D) -> PoolVector2Array:
#	var curve := path.get_curve()
	var count = curve.get_point_count()
	var evenly_space_points = PoolVector2Array()
	var prev_point = curve.get_point_position(0)
	evenly_space_points.push_back(prev_point)
	var dst_since_last_even_point = 0
	for i in range(count - 1):
		var p0 = curve.get_point_position(i)
		var p1 = p0 + curve.get_point_out(i)
		var p3 = curve.get_point_position(i + 1)
		var p2 = p3 + curve.get_point_in(i + 1)

		var control_net_length : float = p0.distance_to(p1) + p1.distance_to(p2) + p2.distance_to(p3)
		var estimated_curve_length : float = p0.distance_to(p3) + control_net_length * 0.5
		var divisions : float = ceil(estimated_curve_length)
		var t : float = 0
		var step : float = 1 / divisions
		while t < 1.0:
			t += step
			var point_on_curve : Vector2 = curve.interpolate(i, t)
			dst_since_last_even_point += prev_point.distance_to(point_on_curve)
			if t >= 1.0:
				dst_since_last_even_point = 0
				evenly_space_points.push_back(p3)
				prev_point = p3
			else:
				while dst_since_last_even_point >= spacing:
					var overshoot : float = dst_since_last_even_point - spacing
					var new_point : Vector2 = point_on_curve + (prev_point - point_on_curve).normalized() * overshoot
					evenly_space_points.push_back(new_point)
					dst_since_last_even_point = overshoot
					prev_point = new_point
			prev_point = point_on_curve
		if i == count - 2:
			if dst_since_last_even_point > 0:
				evenly_space_points.push_back(p3)
	return evenly_space_points

func create_ground_mesh():
	if (is_colored_polygon or texture != null) && path != null && path.get_curve().get_point_count() > 1:
#		set_transform(path.get_transform())
		var points : PoolVector2Array
		if version == 0:
			points = calculate_evenly_spacedPoints(path.get_curve())
		else:
			points = path.get_curve().tessellate(tessellate_max_stages, tessellate_tolerance)
#		var points = path.get_curve().get_baked_points()
		var bounds : Array = get_points_bounds(points)
		var x_min = bounds[0]
		var x_max= bounds[1]
		var y_min = bounds[2]
		var y_max = bounds[3]
		if !is_closed:
			var first_point = points[0]
			var last_point = points[points.size() - 1]
			y_max += OFFSET_Y
			points.push_back(Vector2(last_point.x, y_max))
			points.push_back(Vector2(first_point.x, y_max))
		if Engine.has_singleton("Earcut"):
			var holes : Array = get_holes()
	#		print("has holes ", holes.size())
			var holes_index : PoolIntArray = PoolIntArray();
			if holes.size() > 0:
				holes_index.resize(1 + holes.size())
				holes_index.set(0, points.size())
				for i in holes.size():
					var hole : Path2D = holes[i]
					var hole_points : PoolVector2Array
					if version == 0:
						hole_points = calculate_evenly_spacedPoints(hole.curve)
					else:
						hole_points = hole.curve.tessellate()
					var n : int = points.size()
					var size : int = n + hole_points.size()
					points.resize(size)
					for j in hole_points.size():
						points.set(n + j, hole_points[j])
					holes_index.set(i + 1, size)
	
			var width: float = x_max - x_min
			var height: float = y_max - y_min
	#		print(width, ", ", height)
			if texture != null:
				var tiling_value = Vector2(width / texture.get_width(), height / texture.get_height())
				if init_tiling != tiling_value:
					init_tiling = tiling_value
					property_list_changed_notify()
					set_tiling(tiling_value)
	
			var wh : Vector2 = Vector2(width, height)
			var uvs = PoolVector2Array()
			uvs.resize(points.size())
			for i in range(points.size()):
				var uv : Vector2 = (texture_offset + points[i] * tiling / wh)
				uvs.set(i, uv.rotated(texture_rotation))
			var Earcut := Engine.get_singleton("Earcut")
			var tris : PoolIntArray =  Earcut.execute(points, holes_index)
			_mesh[Mesh.ARRAY_VERTEX] = points
			_mesh[Mesh.ARRAY_INDEX] = tris
			_mesh[Mesh.ARRAY_TEX_UV] = uvs
	
			if texture != null:
				VisualServer.canvas_item_add_triangle_array(get_canvas_item(), tris, points, [Color.white], uvs, [], [], texture.get_rid())
			else:
				VisualServer.canvas_item_add_triangle_array(get_canvas_item(), tris, points, [Color.white], uvs, [], [], RID())
		else:
			var width: float = x_max - x_min
			var height: float = y_max - y_min
			if texture != null:
				var tiling_value = Vector2(width / texture.get_width(), height / texture.get_height())
				if init_tiling != tiling_value:
					init_tiling = tiling_value
					property_list_changed_notify()
					set_tiling(tiling_value)
			draw_without_hole(points, Vector2(width, height))

func draw_without_hole(points : PoolVector2Array, wh : Vector2):
	var uvs = PoolVector2Array()
	uvs.resize(points.size())
	var tris := Geometry.triangulate_polygon(points)
	if tris.size() > 0:
		for i in range(points.size()):
			var uv : Vector2 = (texture_offset + points[i] * tiling / wh)
			uvs.set(i, uv.rotated(texture_rotation))
		if texture != null:
			VisualServer.canvas_item_add_triangle_array(get_canvas_item(), tris, points, [Color.white], uvs, [], [], texture.get_rid())
		else:
			VisualServer.canvas_item_add_triangle_array(get_canvas_item(), tris, points, [Color.white], uvs, [], [], RID())
		_mesh[Mesh.ARRAY_VERTEX] = points
		_mesh[Mesh.ARRAY_INDEX] = tris
		_mesh[Mesh.ARRAY_TEX_UV] = uvs

func _draw():
	create_ground_mesh()

func get_mesh_data() -> Array:
	var result = []
	result.resize(3)
	result[0] = Util.vector2_array_to_array(_mesh[Mesh.ARRAY_VERTEX])
	result[1] = Util.to_corona_indices(_mesh[Mesh.ARRAY_INDEX])
	if not is_colored_polygon:
		result[2] = Util.vector2_array_to_array(_mesh[Mesh.ARRAY_TEX_UV])
	return result
