class_name ButtonAudioComponent
extends AudioStreamPlayer

@export var override_button_enter_sound: AudioStream
@export var override_button_exit_sound: AudioStream
@export var override_button_press_sound: AudioStream
@export var pitch_variation: float = 0.3
@export var volume_decibels: float = -20

@onready var default_button_enter_sound = preload("uid://ddwxkcwnugcyn")
@onready var default_button_exit_sound = preload("uid://cmimx4ru3j1c6")
@onready var default_button_press_sound = preload("uid://cnwo1ju33tfx7")

func _ready() -> void:
	volume_db = volume_decibels
	var parent = get_parent()
	if parent is BaseButton:
		parent.pressed.connect(_play_press_sound)
		parent.mouse_entered.connect(_play_mouse_enter_sound)
		parent.mouse_exited.connect(_play_mouse_exit_sound)

func play_sound(sound: AudioStream):
	if not is_inside_tree():
		return
	if sound == null:
		return
	var parent = get_parent()
	if parent is BaseButton:
		if parent.disabled:
			return
	stream = sound
	play.call_deferred()

func play_sound_random_pitch(sound: AudioStream):
	var base_pitch = pitch_scale
	pitch_scale = randf_range(base_pitch - pitch_variation, base_pitch + pitch_variation)
	play_sound(sound)
	pitch_scale = base_pitch

func _play_mouse_enter_sound():
	if override_button_enter_sound:
		play_sound_random_pitch(override_button_enter_sound)
	else:
		if default_button_enter_sound:
			play_sound_random_pitch(default_button_enter_sound)

func _play_mouse_exit_sound():
	if override_button_exit_sound:
		play_sound_random_pitch(override_button_exit_sound)
	else:
		if default_button_exit_sound:
			play_sound_random_pitch(default_button_exit_sound)

func _play_press_sound():
	if override_button_press_sound:
		play_sound_random_pitch(override_button_press_sound)
	else:
		if default_button_press_sound:
			play_sound_random_pitch(default_button_press_sound)
