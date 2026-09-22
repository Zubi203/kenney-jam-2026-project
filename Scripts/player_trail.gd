extends Line2D

@export var trail_length: int = 30

func _process(_delta: float) -> void:
	add_point(get_parent().global_position)
	if points.size() > trail_length:
		remove_point(0)
