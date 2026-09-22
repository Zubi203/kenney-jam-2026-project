extends Control


func _on_play_button_pressed() -> void:
	GameManager.reset_manager()
	SceneTransition.change_scene("res://Scenes/Levels/tutorial_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
