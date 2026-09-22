class_name PlayerBullet
extends Area2D

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 500.0

@export var sprite: Sprite2D

enum RayType {
	SHRINK,
	ENLARGE
}
@export var bullet_type: RayType = RayType.SHRINK


func _physics_process(delta: float) -> void:
	translate(direction * speed * delta)
	rotation = direction.angle()

func set_bullet(type: RayType, dir: Vector2):
	bullet_type = type
	direction = dir
	
	if sprite == null:
		return
	
	match bullet_type:
		RayType.SHRINK:
			sprite.self_modulate = Color.ORANGE_RED
		RayType.ENLARGE:
			sprite.self_modulate = Color.SPRING_GREEN


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("change_scale"):
		body.change_scale(bullet_type)
	_destroy_bullet()

func _destroy_bullet():
	visible = false
	global_position = Vector2(99999, 99999)
