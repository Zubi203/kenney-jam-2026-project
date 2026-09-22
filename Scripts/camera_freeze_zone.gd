extends Area2D

@export var camera_lock_point: Node2D
var current_target: Node2D

func _process(_delta: float) -> void:
	if camera_lock_point == null:
		return
	for body in get_overlapping_bodies():
		if not body.is_in_group("Player"):
			return
		if current_target == camera_lock_point:
			return
		current_target = camera_lock_point
		GameManager.SetCameraTarget.emit(current_target)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	current_target = body
	GameManager.SetCameraTarget.emit(current_target)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	current_target = camera_lock_point
	GameManager.SetCameraTarget.emit(current_target)
