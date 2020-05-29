# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool

static func log2(value):
	return log(value) / log(2)

static func vector2_array_to_array(value : PoolVector2Array) -> PoolRealArray:
	var arr : PoolRealArray = PoolRealArray()
	arr.resize(value.size() * 2)
	for i in (value.size()):
		arr.set(2 * i, value[i].x)
		arr.set(2 * i + 1, value[i].y)
	return arr

static func vector2_to_array(value : Vector2) -> Array:
	return [value.x, value.y]

static func to_corona_indices(tris : PoolIntArray) -> PoolIntArray:
	var corona_indices : PoolIntArray = PoolIntArray()
	corona_indices.resize(tris.size())
	for i in tris.size():
		corona_indices.set(i, tris[i] + 1)
	return corona_indices

static func vertices_to_polygon(verts : Array) -> PoolVector2Array:
	var polygon := PoolVector2Array()
	polygon.resize(verts.size() / 2)
	var n := 0
	for i in range(0, verts.size() - 1, 2):
		polygon.set(n, Vector2(verts[i], verts[i + 1]))
		n += 1
	return polygon

static func to_corona_color(col : Color) -> String:
	var col_str = col.to_html()
	return col_str.substr(2, col_str.length() - 2) + col_str.substr(0, 2)

static func from_corona_color(col : String) -> Color:
	var col_str = col.substr(col.length() - 2, 2) + col.substr(0, col.length() - 2)
#	print(col_str)
	return Color(col_str)

static func disconnect_all(target : Object, name : String):
	var list := target.get_signal_connection_list(name)
	for v in list:
		target.disconnect(name, v["target"], v["method"])

static func get_all_children(node : Node, target : Node, list : Array):
	if node != target:
		list.push_back(node.name)
	if not (node is Sprite and node is Path2D):
		for i in node.get_child_count():
			get_all_children(node.get_child(i), target, list)
	
static func get_all_children2(node : Node, target : Node, list : Dictionary):
	if node != target:
		list[node.name] = true
	for i in node.get_child_count():
		get_all_children2(node.get_child(i), target, list)

static func save_data(path : String, content : String):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

static func load_data(path : String):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

static func load_json(path : String):
	var value := JSON.parse(load_data(path))
	if value.error == OK:
		return value.result
	else:
		print("Load json error: ", path, "\n", value.error_line, ", ", value.error_string)
		return null
