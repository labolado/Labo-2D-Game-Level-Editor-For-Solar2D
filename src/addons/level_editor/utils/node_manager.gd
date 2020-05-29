# Copyright 2020 Labo Lado.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

tool

const LHLayer = preload("../lh_layer.gd")
const LHSprite = preload("../lh_sprite.gd")
const LHAnimatedSprite = preload("../lh_animated_sprite.gd")
const LHBezierTrack = preload("../lh_bezier_track.gd")
const Track = preload("../track.gd")
const Ground = preload("../ground.gd")
const CoronaJoint = preload("../physics/corona_joint.gd")
const Utils = preload("../utils/util.gd")
const NameManager = preload("name_manager.gd")

static func node_added(node : Node, tree : SceneTree, name_manager : NameManager):
	if node is Node2D:
		var root : Node = tree.edited_scene_root
		if root != null && (root == node || root.is_a_parent_of(node)):
#			printt("Add:", node.name)
			if node is Sprite:
				var sprite = node as Sprite
				if sprite.get_script() != LHSprite:
					sprite.set_script(LHSprite)
					sprite.call("manual_init")
					print("Add ", sprite, " and attach script ", LHSprite)
			elif node is AnimatedSprite:
				if node.get_script() != LHAnimatedSprite:
					node.set_script(LHAnimatedSprite)
			elif node.get_class() == "Node2D" && node.get_script() != Track && node.get_script() != Ground && (not (node is CoronaJoint)):
				if node.get_script() != LHLayer:
					node.set_script(LHLayer)
			
			if not ignore(node, root):
				name_manager.added(node, root)
				if not node.is_connected("renamed", name_manager, "renamed"):
					node.connect("renamed", name_manager, "renamed", [node, root])

static func node_removed(node : Node, tree : SceneTree, name_manager : NameManager):
	if node is Node2D:
		var root : Node = tree.edited_scene_root
		if root != null && (root == node || root.is_a_parent_of(node)):
			if not ignore(node, root):
				name_manager.removed(node, root)

static func ignore(target : Node, root : Node) -> bool:
	if target == root:
		return false
	var parent : Node = target.get_parent()
	if (not target.is_inside_tree()) or parent is LHBezierTrack or parent is LHSprite:
#		printt(target.name, 1)
		return true
	while parent != root:
		if parent.get_filename() != "":
#			printt(target.name, 2, parent.name, target.get_parent().name)
			return true
		parent = parent.get_parent()
	return false
