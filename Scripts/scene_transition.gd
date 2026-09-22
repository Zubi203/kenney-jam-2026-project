extends CanvasLayer

@export var animation_player: AnimationPlayer

func change_scene(path_name: String):
	if animation_player == null:
		return
	animation_player.play("appear")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(path_name)
	await get_tree().create_timer(0.5).timeout
	animation_player.play("dissolve")
