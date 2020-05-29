# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool
extends Node2D

const Util = preload("utils/util.gd")

var version : int = 1 setget set_version
var texture : Texture = null setget set_texture
var up_texture : Texture = null setget set_up_texture
var down_texture : Texture = null setget set_down_texture
var left_texture : Texture = null setget set_left_texture
var right_texture : Texture = null setget set_right_texture

#var up_uv_data := {
#	body = Rect2(0, 0, 0, 0),
#	left_cap = Rect2(0, 0, 0, 0), 
#	right_cap = Rect2(0, 0, 0, 0),
#	inner_left_cap = Rect2(0, 0, 0, 0),
#	inner_right_cap = Rect2(0, 0, 0, 0)
#}
#var down_uv_data := {
#	body = Rect2(0, 0, 0, 0),
#	left_cap = Rect2(0, 0, 0, 0), 
#	right_cap = Rect2(0, 0, 0, 0),
#	inner_left_cap = Rect2(0, 0, 0, 0),
#	inner_right_cap = Rect2(0, 0, 0, 0)
#}

var track_offset := Vector2.ZERO setget set_track_offset

var up_offset : float = 0 setget set_up_offset
var down_offset : float = 0 setget set_down_offset
var left_offset : float = 0 setget set_left_offset
var right_offset : float = 0 setget set_right_offset

#export(bool) var debug = false setget set_debug
var is_closed := false setget set_is_closed
var road_height : float = 128 setget set_road_height
var spacing : float = 512 setget set_bake_interval
var tessellate_max_stages : int = 5 setget set_tessellate_max_stages
var tessellate_tolerance : float = 2 setget set_tessellate_tolerance
var tiling := Vector2(1.0, 1.0) setget set_tiling

class TrackManager:
	var edges : Dictionary = {}
	var up_offset : Vector2 = Vector2.ZERO
	var down_offset : Vector2 = Vector2.ZERO
	var left_offset : Vector2 = Vector2.ZERO
	var right_offset : Vector2 = Vector2.ZERO
	var down_vertices = PoolVector2Array()
	var down_indices = PoolIntArray()
	var down_uvs = PoolVector2Array()
	var up_vertices = PoolVector2Array()
	var up_indices = PoolIntArray()
	var up_uvs = PoolVector2Array()
	var left_vertices = PoolVector2Array()
	var left_indices = PoolIntArray()
	var left_uvs = PoolVector2Array()
	var right_vertices = PoolVector2Array()
	var right_indices = PoolIntArray()
	var right_uvs = PoolVector2Array()
	var last_type = ""
	var default_wh : Vector2
	var default_offset : float

	func _init(p_up : Texture, p_down : Texture, p_left : Texture, p_right : Texture, p_up_offset : float, p_down_offset : float, p_left_offset : float, p_right_offset : float):
		edges["up"] = p_up
		edges["down"] = p_down
		edges["left"] = p_left
		edges["right"] = p_right
		up_offset.y = p_up_offset
		down_offset.y = p_down_offset
		left_offset.x = p_left_offset
		right_offset.x = p_right_offset
		var edge = p_up if p_up != null else p_down if p_down != null else p_left if p_left != null else p_right if p_right != null else null
		default_wh = Vector2(edge.get_width(), edge.get_height())
		default_offset = up_offset.y if p_up != null else down_offset.y if p_down != null else left_offset.x if p_left != null else right_offset.x if p_right != null else 0

	func check(type_name : String) -> bool:
		return type_name == last_type

	func append(type_name, p1, uv1, p2, uv2):
		if edges.get(type_name) == null:
			return
		match type_name:
			"up":
				up_vertices.push_back(p1)
				up_vertices.push_back(p2)
				up_uvs.push_back(uv1)
				up_uvs.push_back(uv2)
#				up_uvs.push_back(uv1 * Vector2(0.75, 1) + Vector2(0.125, 0))
#				up_uvs.push_back(uv2 * Vector2(0.75, 1) + Vector2(0.125, 0))
				var n = up_vertices.size() - 4
				var i = up_indices.size()
				up_indices.resize(i + 6)
				up_indices.set(i, n)
				up_indices.set(i + 1, n + 2)
				up_indices.set(i + 2, n + 1)
				up_indices.set(i + 3, n + 1)
				up_indices.set(i + 4, n + 2)
				up_indices.set(i + 5, n + 3)
			"down":
				down_vertices.push_back(p1)
				down_vertices.push_back(p2)
				down_uvs.push_back(uv1)
				down_uvs.push_back(uv2)
				var n = down_vertices.size() - 4
				var i = down_indices.size()
				down_indices.resize(i + 6)
				down_indices.set(i, n)
				down_indices.set(i + 1, n + 2)
				down_indices.set(i + 2, n + 1)
				down_indices.set(i + 3, n + 1)
				down_indices.set(i + 4, n + 2)
				down_indices.set(i + 5, n + 3)
			"left":
				left_vertices.push_back(p1)
				left_vertices.push_back(p2)
				left_uvs.push_back(uv1)
				left_uvs.push_back(uv2)
				var n = left_vertices.size() - 4
				var i = left_indices.size()
				left_indices.resize(i + 6)
				left_indices.set(i, n)
				left_indices.set(i + 1, n + 2)
				left_indices.set(i + 2, n + 1)
				left_indices.set(i + 3, n + 1)
				left_indices.set(i + 4, n + 2)
				left_indices.set(i + 5, n + 3)
			"right":
				right_vertices.push_back(p1)
				right_vertices.push_back(p2)
				right_uvs.push_back(uv1)
				right_uvs.push_back(uv2)
				var n = right_vertices.size() - 4
				var i = right_indices.size()
				right_indices.resize(i + 6)
				right_indices.set(i, n)
				right_indices.set(i + 1, n + 2)
				right_indices.set(i + 2, n + 1)
				right_indices.set(i + 3, n + 1)
				right_indices.set(i + 4, n + 2)
				right_indices.set(i + 5, n + 3)

	func add(type_name, p1, uv1, p2, uv2, p3, uv3, p4, uv4):
		last_type = type_name
		if edges.get(type_name) == null:
			return
		match type_name:
			"up":
				up_vertices.push_back(p1)
				up_vertices.push_back(p2)
				up_uvs.push_back(uv1)
				up_uvs.push_back(uv2)
#				up_uvs.push_back(uv1 * Vector2(0.75, 1) + Vector2(0.125, 0))
#				up_uvs.push_back(uv2 * Vector2(0.75, 1) + Vector2(0.125, 0))
			"down":
				down_vertices.push_back(p1)
				down_vertices.push_back(p2)
				down_uvs.push_back(uv1)
				down_uvs.push_back(uv2)
			"left":
				left_vertices.push_back(p1)
				left_vertices.push_back(p2)
				left_uvs.push_back(uv1)
				left_uvs.push_back(uv2)
			"right":
				right_vertices.push_back(p1)
				right_vertices.push_back(p2)
				right_uvs.push_back(uv1)
				right_uvs.push_back(uv2)
		append(type_name, p3, uv3, p4, uv4)

	func get_edge_wh(type_name : String) -> Vector2:
		var edge : Texture = edges.get(type_name)
		if edge != null:
			return Vector2(edge.get_width(), edge.get_height())
		else:
			return default_wh
	
	func get_edge_offset(type_name : String) -> float:
		var value : float = 0.0
		match type_name:
			"up":
				value = up_offset.y
			"down":
				value = down_offset.y
			"left":
				value = left_offset.x
			"right":
				value = right_offset.x
		return value

	func draw_edge(node : Node2D):
		var up : Texture = edges.get("up")
		var down : Texture = edges.get("down")
		var left : Texture = edges.get("left")
		var right : Texture = edges.get("right")
		if left != null and left_vertices.size() > 0:
			VisualServer.canvas_item_add_triangle_array(node.get_canvas_item(), left_indices, left_vertices, [Color.white], left_uvs, [], [], left.get_rid())
		if right != null and right_vertices.size() > 0:
			VisualServer.canvas_item_add_triangle_array(node.get_canvas_item(), right_indices, right_vertices, [Color.white], right_uvs, [], [], right.get_rid())
		if down != null and down_vertices.size() > 0:
			VisualServer.canvas_item_add_triangle_array(node.get_canvas_item(), down_indices, down_vertices, [Color.white], down_uvs, [], [], down.get_rid())
		if up != null and up_vertices.size() > 0:
			VisualServer.canvas_item_add_triangle_array(node.get_canvas_item(), up_indices, up_vertices, [Color.white], up_uvs, [], [], up.get_rid())

	func to_data(data : Array):
		var up : Texture = edges.get("up")
		var down : Texture = edges.get("down")
		var left : Texture = edges.get("left")
		var right : Texture = edges.get("right")
		if left != null && left_vertices.size() > 0:
			data.push_back({
				texture = left.resource_path,
				wh = [left.get_width(), left.get_height()],
				mesh = [
					Util.vector2_array_to_array(left_vertices),
					Util.to_corona_indices(left_indices),
					Util.vector2_array_to_array(left_uvs)
				]
			})
		if right != null && right_vertices.size() > 0:
			data.push_back({
				texture = right.resource_path,
				wh = [right.get_width(), right.get_height()],
				mesh = [
					Util.vector2_array_to_array(right_vertices),
					Util.to_corona_indices(right_indices),
					Util.vector2_array_to_array(right_uvs)
				]
			})
		if down != null && down_vertices.size() > 0:
			data.push_back({
				texture = down.resource_path,
				wh = [down.get_width(), down.get_height()],
				mesh = [
					Util.vector2_array_to_array(down_vertices),
					Util.to_corona_indices(down_indices),
					Util.vector2_array_to_array(down_uvs)
				]
			})
		if up != null && up_vertices.size() > 0:
			data.push_back({
				texture = up.resource_path,
				wh = [up.get_width(), up.get_height()],
				mesh = [
					Util.vector2_array_to_array(up_vertices),
					Util.to_corona_indices(up_indices),
					Util.vector2_array_to_array(up_uvs)
				]
			})

var path : Path2D
#var curve : Curve2D

var _mesh : Array = []
var _track_mgr : TrackManager

func _init():
	_mesh.resize(Mesh.ARRAY_MAX)
#func _ready():
#	path = get_parent()
#	curve = path.get_curve()
#	curve.connect("changed", self, "update_curve_now")

func update_curve_now():
#	print("update_curve_now: ", curve.get_point_count())
	update()

#func set_debug(val):
#	debug = val
#	update()

func set_version(value : int):
	version = value
	update()

func update_shader_tiling():
	if get_parent() != null:
		if get_material() == null:
			get_parent().get_material().set_shader_param("tiling", tiling)
		else:
			get_material().set_shader_param("tiling", tiling)

func set_tiling(tiling_value):
	tiling = tiling_value
#	update_shader_tiling()

func set_texture(val : Texture):
	texture = val
	if val != null:
		road_height = texture.get_height()
	#	var ratio = texture.get_height() / road_height
	#	var tilingX = (num_points * spacing * ratio * 0.5 / texture.get_width())
		var tilingX = 1.0
#		property_list_changed_notify()
		set_tiling(Vector2(tilingX, 1.0))
	update()

func set_up_texture(val : Texture):
	up_texture = val
	update()

func set_down_texture(val : Texture):
	down_texture = val
	update()

func set_left_texture(val : Texture):
	left_texture = val
	update()

func set_right_texture(val : Texture):
	right_texture = val
	update()

func set_track_offset(value : Vector2):
	track_offset = value
	update()
func set_up_offset(value : float):
	up_offset = value
	update()
func set_down_offset(value : float):
	down_offset = value
	update()
func set_left_offset(value : float):
	left_offset = value
	update()
func set_right_offset(value : float):
	right_offset = value
	update()

func set_bake_interval(val):
	spacing = val
#	path.get_curve().set_bake_interval(val)
	update()

func set_tessellate_max_stages(value : int):
	tessellate_max_stages = value
	update()

func set_tessellate_tolerance(value : float):
	tessellate_tolerance = value
	update()

func set_road_height(val):
	road_height = val
	update()

func set_is_closed(val):
	is_closed = val
	update()

func calculate_evenly_spacedPoints() -> PoolVector2Array:
	var curve := path.get_curve()
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

func calculate_evenly_spacedPoints2() -> PoolVector2Array:
	var points = path.get_curve().tessellate()
	var count = points.size()
	var evenly_space_points = PoolVector2Array()
	var prev_point = points[0]
	evenly_space_points.push_back(prev_point)
	var dst_since_last_even_point = 0
	for i in range(count - 1):
		var p0 : Vector2 = points[i]
		var p1 : Vector2 = points[i + 1]

		var line_length : float = p0.distance_to(p1)
		var divisions : float = ceil(line_length)
		var t : float = 0
		var step : float = 1 / divisions
		while t < 1.0:
			t += step
			var point_on_curve : Vector2 = p0.linear_interpolate(p1, t)
			dst_since_last_even_point += prev_point.distance_to(point_on_curve)
			if t >= 1.0:
				dst_since_last_even_point = 0
				evenly_space_points.push_back(p1)
				prev_point = p1
			else:
				while dst_since_last_even_point >= spacing:
					var overshoot : float = dst_since_last_even_point - spacing
					var new_point : Vector2 = point_on_curve + (prev_point - point_on_curve).normalized() * overshoot
					evenly_space_points.push_back(new_point)
					dst_since_last_even_point = overshoot
					prev_point = new_point
			prev_point = point_on_curve
		if i == count - 1:
			if dst_since_last_even_point > 0:
				evenly_space_points.push_back(p1)
	return evenly_space_points

func linear_interpolate(prev_up, prev_down, up, down) -> PoolVector2Array:
	var evenly_space_points = PoolVector2Array()
	return evenly_space_points
	
func get_edge_type(normal : Vector2) -> String:
	var angle : float = rad2deg(normal.tangent().angle())
	var type_name = "up"
	if angle >= -90 - 45 and angle <= -90 + 45:
		type_name = "up"
	elif angle > -90 + 45 and angle < 45:
		type_name = "right"
	elif angle >= 45 and angle <= 180 - 45:
		type_name = "down"
	else:
		type_name = "left"
	return type_name

func create_track_mesh():
	if not path:
		return
	if path.get_curve().get_point_count() > 1 && texture != null:
#		set_transform(path.get_transform())
		var road_width = texture.get_width() * road_height / texture.get_height()
		var points : PoolVector2Array
		if version == 0:
			points = calculate_evenly_spacedPoints()
		else:
			points = path.get_curve().tessellate(tessellate_max_stages, tessellate_tolerance)
#		var points : PoolVector2Array = calculate_evenly_spacedPoints2()
#		var points : PoolVector2Array = curve.get_baked_points()
		
			
#		print("track points size = ", points.size())
		var verts = PoolVector2Array()
		var uvs = PoolVector2Array()
		var tris =  PoolIntArray()
		var length = points.size()
		var verts_size = length * 2;
		verts.resize(verts_size)
		uvs.resize(verts_size)
		var num_tris = 2 * (length - 1) + (2 if is_closed else 0)
#		var num_tris = 2 * (length - 1)
		tris.resize(num_tris * 3)
		
#		if track_offset.length() > 0:
#			for i in length:
#				points[i] += track_offset
			
		var vert_index = 0
		var tri_index = 0
		var spacing_add : float = 0
		var prev_point : Vector2 = points[0]
		for i in range(length):
			var forward = Vector2.ZERO
#			if i < length - 1:
			if i < length - 1 || is_closed:
				forward += (points[(i + 1) % length] - points[i]).normalized()

			var normal_a : Vector2
#			if i > 0:
			if i > 0 || is_closed:
				normal_a = (points[i] - points[(i - 1 + length) % length]).normalized()
				forward += normal_a

			var f = forward.normalized()
#			var left = Vector2(-f.y, f.x)
			var left = -forward.normalized().tangent()

#			var completion_percent = i / float(length - 1)
#			var v = 1 - abs(2 * completion_percent - 1)
			spacing_add += points[i].distance_to(prev_point)
			var v = spacing_add / road_width
			if i > 0:
#				print(rad2deg(normal_a.tangent().angle()))
				verts.set(vert_index,Geometry.line_intersects_line_2d(verts[vert_index - 2], normal_a, points[i], left))
				verts.set(vert_index + 1, Geometry.line_intersects_line_2d(verts[vert_index - 1], normal_a, points[i], -left))
			else:
				verts.set(vert_index, points[i] + left * (road_height * 0.5 + track_offset.y))
				verts.set(vert_index + 1, points[i] - left * (road_height * 0.5 - track_offset.y))
			uvs.set(vert_index, Vector2(v, 1))
			uvs.set(vert_index + 1, Vector2(v, 0))

			prev_point = points[i]

#			if i < length - 1 || is_closed:
			if i < length - 1:
				tris.set(tri_index, vert_index)
				tris.set(tri_index + 1, (vert_index + 2) % verts_size)
				tris.set(tri_index + 2, vert_index + 1)
				tris.set(tri_index + 3, vert_index + 1)
				tris.set(tri_index + 4, (vert_index + 2) % verts_size)
				tris.set(tri_index + 5, (vert_index + 3) % verts_size)

			if is_closed && i == length - 1:
				verts.push_back(verts[0])
				verts.push_back(verts[1])
				v = (spacing_add + points[i].distance_to(points[0])) / road_width
				uvs.push_back(Vector2(v, 1))
				uvs.push_back(Vector2(v, 0))
				tris.set(tri_index, vert_index)
				tris.set(tri_index + 1, vert_index + 2)
				tris.set(tri_index + 2, vert_index + 1)
				tris.set(tri_index + 3, vert_index + 1)
				tris.set(tri_index + 4, vert_index + 2)
				tris.set(tri_index + 5, vert_index + 3)

			vert_index += 2
			tri_index += 6

		# print(verts)
		_mesh[Mesh.ARRAY_VERTEX] = verts
		_mesh[Mesh.ARRAY_INDEX] = tris
		_mesh[Mesh.ARRAY_TEX_UV] = uvs
		VisualServer.canvas_item_add_triangle_array(get_canvas_item(), tris, verts, [Color.white], uvs, [], [], texture.get_rid())

func create_four_side_track_mesh():
	if path.get_curve().get_point_count() > 1:
#		var points : PoolVector2Array = calculate_evenly_spacedPoints()
#		var points : PoolVector2Array = calculate_evenly_spacedPoints2()
#		var points : PoolVector2Array = curve.get_baked_points()
		var points : PoolVector2Array
		if version == 0:
			points = calculate_evenly_spacedPoints()
		else:
			points = path.get_curve().tessellate(tessellate_max_stages, tessellate_tolerance)
		
		var length := points.size()
		_track_mgr = TrackManager.new(up_texture, down_texture, left_texture, right_texture, up_offset, down_offset, left_offset, right_offset)
		var road_width := _track_mgr.default_wh.x
		var spacing_add : float = 0
		var prev_point : Vector2 = points[0]
		var prev_up : Vector2
		var prev_down : Vector2
		var prev_up_uv : Vector2
		var prev_down_uv : Vector2
		var first_up : Vector2
		var first_down : Vector2
		var first_point : Vector2 = prev_point
		var first_point_type_changed = false
		for i in range(length):
			var forward := Vector2.ZERO
			var normal_b := Vector2.ZERO
#			if i < length - 1:
			if i < length - 1 || is_closed:
				normal_b = (points[(i + 1) % length] - points[i]).normalized()
				forward += normal_b

			var normal_a := Vector2.ZERO
#			if i > 0:
			if i > 0 || is_closed:
				normal_a = (points[i] - points[(i - 1 + length) % length]).normalized()
				forward += normal_a

			var left := -forward.normalized().tangent()
			var distance_prev_point := points[i].distance_to(prev_point)
			if i > 0:
				var type_name := get_edge_type(normal_a)
				if i < length - 1 or is_closed:
					var next_type_name := get_edge_type(normal_b)
					if type_name != next_type_name:
						left = -normal_a.tangent()

				var type_not_changed := _track_mgr.check(type_name)
				var down : Vector2
				var down_uv : Vector2
				var up : Vector2
				var up_uv : Vector2
				if type_not_changed:
					down = Geometry.line_intersects_line_2d(prev_down, normal_a, points[i], left)
					up = Geometry.line_intersects_line_2d(prev_up, normal_a, points[i], -left)
					spacing_add += distance_prev_point
					var v : float = spacing_add / road_width
					down_uv = Vector2(v, 1)
					up_uv = Vector2(v, 0)
					_track_mgr.append(type_name, down, down_uv, up, up_uv)
				else:
					var wh := _track_mgr.get_edge_wh(type_name)
					var half_h := wh.y * 0.5
					var perp : Vector2 = normal_a.tangent()
					var offset := _track_mgr.get_edge_offset(type_name)
					prev_down = prev_point - perp * (half_h + offset)
					down = Geometry.line_intersects_line_2d(prev_down, normal_a, points[i], left)
					prev_up = prev_point + perp * (half_h - offset)
					up = Geometry.line_intersects_line_2d(prev_up, normal_a, points[i], -left)
					spacing_add = distance_prev_point
					road_width = wh.x
					var v : float = spacing_add / road_width
					down_uv = Vector2(v, 1)
					up_uv = Vector2(v, 0)
					_track_mgr.add(type_name, prev_down, Vector2.DOWN, prev_up, Vector2.ZERO, down, down_uv, up, up_uv)
				prev_point = points[i]
				prev_down = down
				prev_up = up
				prev_down_uv = down_uv
				prev_up_uv = up_uv
			else:
				if is_closed:
					var type_name := get_edge_type(normal_a)
					var next_type_name := get_edge_type(normal_b)
					if type_name != next_type_name:
						first_point_type_changed = true
						left = -normal_b.tangent()
				var h := _track_mgr.default_wh.y
				var offset := _track_mgr.default_offset
				prev_down = points[i] + left * (h * 0.5 - offset)
				prev_down_uv = Vector2.DOWN
				prev_up = points[i] - left * (h * 0.5 + offset)
				prev_up_uv = Vector2.ZERO
				first_down = prev_down
				first_up = prev_up

			if is_closed && (i == length - 1):
				var type_name := get_edge_type(normal_b)
				var type_not_changed := _track_mgr.check(type_name)
				var wh := _track_mgr.get_edge_wh(type_name)
				var half_h = wh.y * 0.5
				road_width = wh.x
				distance_prev_point = points[0].distance_to(points[i])
				if first_point_type_changed:
					left = -normal_b.tangent()
					first_down = first_point + left * half_h
					first_up = first_point - left * half_h
				if type_not_changed:
					spacing_add += distance_prev_point
					var v : float = spacing_add / road_width
					_track_mgr.append(type_name, first_down, Vector2(v, 1), first_up, Vector2(v, 0))
				else:
					var perp = normal_b.tangent()
					prev_down = points[i] - perp * half_h
					prev_up = points[i] + perp * half_h
					spacing_add = distance_prev_point
					var v : float = spacing_add / road_width
					_track_mgr.add(type_name, prev_down, Vector2.DOWN, prev_up, Vector2.ZERO, first_down, Vector2(v, 1), first_up, Vector2(v, 0))
		_track_mgr.draw_edge(self)

func _draw():
	if up_texture != null || down_texture != null || left_texture != null || right_texture != null:
		create_four_side_track_mesh()
	else:
		create_track_mesh()

func get_mesh_data() -> Array:
	var result = []
	if path.get_curve().get_point_count() > 1:
		if up_texture != null || down_texture != null || left_texture != null || right_texture != null:
			if _track_mgr != null:
				_track_mgr.to_data(result)
		else:
			if texture != null:
				result.push_back({
					texture = texture.resource_path,
					wh = [texture.get_width(), texture.get_height()],
					mesh = [
						Util.vector2_array_to_array(_mesh[Mesh.ARRAY_VERTEX]),
						Util.to_corona_indices(_mesh[Mesh.ARRAY_INDEX]),
						Util.vector2_array_to_array(_mesh[Mesh.ARRAY_TEX_UV])
					]
				})
	return result

func get_edge_data(fixture_type : String) -> PoolRealArray:
	var points : PoolVector2Array
	if fixture_type == "edge":
		points = calculate_evenly_spacedPoints()
	else:
		points = path.curve.tessellate(tessellate_max_stages, tessellate_tolerance)
	return Util.vector2_array_to_array(points)
