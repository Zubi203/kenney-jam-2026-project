extends Camera2D

@export var follow_rate: float = 1
var current_target: Node2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

@export var shake_intensity: float = 3
@export var shake_falloff: float = 2
var intensity: float

func _ready() -> void:
	GameManager.SetCameraTarget.connect(_set_target)
	if player:
		_move_to_position.call_deferred(player.global_position)
	GameManager.ShakeCamera.connect(_damage_shake)

func _move_to_position(pos : Vector2):
	global_position = pos

func _process(delta: float) -> void:
	if current_target:
		global_position = global_position.lerp(current_target.global_position, follow_rate * delta)
	if intensity > 0:
		offset = _get_random_offset()
		intensity = lerp(intensity, 0.0, shake_falloff * delta)

func _set_target(target: Node2D):
	current_target = target

func _damage_shake():
	intensity = shake_intensity

func _get_random_offset() -> Vector2:
	var x = randf_range(-intensity, intensity)
	var y = randf_range(-intensity, intensity)
	
	return Vector2(x, y)
