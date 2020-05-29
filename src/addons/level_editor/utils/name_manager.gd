# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

#tool
#extends Object

var data := {}
var node_manager : Object

func added(node : Node, root : Node):
	var key := root
	var t = data.get(key)
	if t == null:
		t = {}
		data[key] = t
	if t.has(node.name):
		printt(node.name, "is unique false")
		if t[node.name] != node:
			generate_serial_unique_name(node, root, t)
		t[node] = node.name
	else:
#		printt(node.name, "is unique true")
		t[node.name] = node
		t[node] = node.name

func removed(node : Node, root : Node):
	var key := node
	if node == root:
		var t = data.get(key)
		if t != null:
			t.clear()
			data.erase(key)
			data.erase(root)
#			printt("remove root", root.name, data.size())
	else:
		var t = data.get(key)
		if t != null:
			t.erase(node.name)
			t.erase(node)
#			printt("remove child", node.name, t.size())

func renamed(node : Node, root : Node):
	var dict := get_all_children(root)
	if dict.has(node.name):
		generate_serial_unique_name(node, root, dict)
	else:
		dict[node.name] = node
		var old_name := str(dict.get(node))
		if old_name != null && old_name != node.name && dict.get(old_name) == node:
			dict.erase(old_name)

func generate_serial_unique_name(target : Node, root : Node, dict : Dictionary):
	var name := target.name
	var list := range(name.length())
	list.invert()
	var nums := ""
	for i in list:
		var n : String = name[i]
		if n >= '0' and n <= '9':
			nums = n + nums
		else:
			break
	var str_name := name.substr(0, name.length() - nums.length())
	var flag := true
	var new_name := ""
	while flag:
		nums = String(nums.to_int() + 1)
		new_name = str_name + nums
		flag = dict.has(new_name)
	dict[new_name] = target
	
	var old_name := str(dict.get(target))
	if old_name != null && old_name != new_name && dict.get(old_name) == target:
		dict.erase(old_name)

	if target.is_connected("renamed", self, "renamed"):
		target.disconnect("renamed", self, "renamed")
	target.name = new_name
	dict[target] = new_name
	target.connect("renamed", self, "renamed", [target, root])

func get_all_children(root : Node) -> Dictionary:
	var key := root
	var t = data.get(key)
	if t == null:
		t = {}
		data[key] = t
	return t

func clear():
	for k in data:
		var dict : Dictionary = data[k]
		if dict:
			dict.clear()
