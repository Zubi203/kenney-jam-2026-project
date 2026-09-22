class_name AnimatedButtonComponent
extends Node2D

var button_parent: BaseButton = null
@export var hover_scale_increase: float = 0.1
@export var pressed_scale_increase: float = 0.2
var base_scale: Vector2 = Vector2.ONE
@export var animation_duration: float = 0.2
var tween: Tween

@onready var scale_color: Color = Color.GREEN
@onready var shrink_color: Color = Color.RED


func _ready() -> void:
	if get_parent() is BaseButton:
		button_parent = get_parent()
		base_scale = button_parent.scale
		button_parent.pivot_offset.y = button_parent.size.y / 2
		button_parent.pivot_offset.x = button_parent.size.x / 2
	_connect_button_signals()

func _connect_button_signals():
	if button_parent == null:
		return
	button_parent.mouse_entered.connect(_on_mouse_entered)
	button_parent.mouse_exited.connect(_on_mouse_exited)
	button_parent.pressed.connect(_on_pressed)
	button_parent.focus_entered.connect(_on_focus_entered)
	button_parent.focus_exited.connect(_on_focus_exited)

func _on_mouse_entered():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(button_parent, "modulate", scale_color, animation_duration)
	tween.tween_property(button_parent, "scale", base_scale + Vector2.ONE * hover_scale_increase, animation_duration)

func _on_mouse_exited():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration)
	tween.tween_property(button_parent, "modulate", Color.WHITE, animation_duration)

func _on_focus_entered():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(button_parent, "modulate", scale_color, animation_duration)
	tween.tween_property(button_parent, "scale", base_scale + Vector2.ONE * hover_scale_increase, animation_duration)

func _on_focus_exited():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration)
	tween.tween_property(button_parent, "modulate", Color.WHITE, animation_duration)


func _on_pressed():
	if button_parent.disabled:
		_reset()
		return
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button_parent, "scale", base_scale + Vector2.ONE * pressed_scale_increase, animation_duration)
	tween.tween_property(button_parent, "scale", base_scale, animation_duration)

func _reset():
	tween.tween_property(button_parent, "modulate", Color.WHITE, animation_duration)
	button_parent.scale = base_scale
