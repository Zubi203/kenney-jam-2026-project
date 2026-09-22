extends Area2D

var is_active: bool
@export var starting_checkpoint: bool

@export var sprite: AnimatedSprite2D

@export var audio: AudioStreamPlayer
@export var checkpoint_audio: AudioStream
@export var particles: GPUParticles2D = null

func _ready() -> void:
	if starting_checkpoint and GameManager.current_checkpoint == Vector2.ZERO:
		GameManager.current_checkpoint = global_position
	is_active = false
	_update_state()

func _update_state():
	if sprite == null:
		return
	if is_active:
		sprite.play("active")
	else:
		sprite.play("inactive")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_play_sound(checkpoint_audio)
	if particles:
		particles.restart()
	is_active = true
	GameManager.current_checkpoint = global_position
	_update_state()

func _play_sound(sound: AudioStream):
	if audio == null:
		return
	if sound == null:
		return
	audio.stream = sound
	audio.play()
