extends Control


@export var audio: AudioStreamPlayer
@export var click_sound: AudioStream

func _on_play_again_button_pressed() -> void:
	GameManager.reset_manager()
	SceneTransition.change_scene("res://Scenes/Levels/tutorial_level.tscn")
	_play_sound(click_sound)

func _on_exit_button_pressed() -> void:
	_play_sound(click_sound)
	get_tree().quit()

func _play_sound(sound: AudioStream):
	if audio == null:
		return
	if sound == null:
		return
	audio.stream = sound
	audio.play()
