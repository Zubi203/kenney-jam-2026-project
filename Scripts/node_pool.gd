extends Node

@export var node_scene: PackedScene
var cached_nodes: Array[Node2D]

func _create_new() -> Node2D:
	if node_scene == null:
		return null
	
	var new_node = node_scene.instantiate()
	get_tree().root.add_child.call_deferred(new_node)
	cached_nodes.append(new_node)
	return new_node

func spawn() -> Node2D:
	for node in cached_nodes:
		if not node.visible:
			node.visible = true
			return node
	
	return _create_new()
