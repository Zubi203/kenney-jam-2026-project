extends CanvasLayer



func _on_reset_button_pressed() -> void:
	GameManager.ManualKill.emit()


func _on_exit_button_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Levels/main_menu.tscn")
