extends Node

@warning_ignore("unused_signal")
signal ManualKill
@warning_ignore("unused_signal")
signal SetCameraTarget(target: Node2D)
@warning_ignore("unused_signal")
signal ShakeCamera

var current_checkpoint: Vector2 = Vector2.ZERO

func reset_manager():
	current_checkpoint = Vector2.ZERO
