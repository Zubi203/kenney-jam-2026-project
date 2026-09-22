extends Area2D

@export var audio: AudioStreamPlayer
@export var end_flag_sound: AudioStream
@export var flag_particles: GPUParticles2D = null

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_play_sound(end_flag_sound)
	if flag_particles:
		flag_particles.restart()
	await get_tree().create_timer(1).timeout
	SceneTransition.change_scene("res://Scenes/Levels/end_screen.tscn")

func _play_sound(sound: AudioStream):
	if audio == null:
		return
	if sound == null:
		return
	audio.stream = sound
	audio.play()
