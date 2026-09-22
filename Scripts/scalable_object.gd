class_name ScalableObject
extends CharacterBody2D

@export var scale_step: float = 0.2
@export var max_scale: float = 4
@export var min_scale: float = 0.4
@export var starting_scale: float = 1.0
@export var friction: float = 250
@export var gravity: float = 800
var is_lifted: bool = false

enum State {
	POCKETABLE,
	LIFTABLE,
	PUSHABLE,
	IMMOVABLE,
}
@export var current_state: State = State.PUSHABLE

@export var collider: CollisionShape2D
@export var sprite: Sprite2D

@export var raycast_down: RayCast2D
@export var raycast_up: RayCast2D
@export var raycast_right: RayCast2D
@export var raycast_left: RayCast2D

@export var landing_particles: GPUParticles2D = null
var was_on_floor: bool = false

enum Directions {
	LEFT,
	RIGHT,
	UP,
	DOWN
}
var colliding_sides: Dictionary[Directions , bool] = {
	Directions.LEFT : false,
	Directions.RIGHT : false,
	Directions.UP :  false,
	Directions.DOWN : false
}

@export var audio: AudioStreamPlayer
@export var shrink_sound: AudioStream
@export var enlarge_sound: AudioStream
@export var drag_sound: AudioStream
@export var landing_sound: AudioStream

func _ready() -> void:
	_check_state(scale.x)

func _physics_process(delta: float) -> void:
	if is_lifted:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()

func change_scale(ray_type: PlayerBullet.RayType):
	if is_lifted:
		return
	match ray_type:
		PlayerBullet.RayType.SHRINK:
			_shrink_flash()
			_play_sound(shrink_sound)
			resize(-scale_step)
		PlayerBullet.RayType.ENLARGE:
			_enlarge_flash()
			_play_sound(enlarge_sound)
			_check_colliding_sides()
			if _can_scale_up():
				resize(scale_step)

func _check_colliding_sides():
	if raycast_down == null:
		return
	if raycast_right == null:
		return
	if raycast_up == null:
		return
	if raycast_left == null:
		return
	
	colliding_sides[Directions.DOWN] = raycast_down.is_colliding()
	colliding_sides[Directions.UP] = raycast_up.is_colliding()
	colliding_sides[Directions.RIGHT] = raycast_right.is_colliding()
	colliding_sides[Directions.LEFT] = raycast_left.is_colliding()

func _can_scale_up() -> bool:
	var num_colliding_sides: int = 0
	var opposite_sides_colliding: bool = false
	for key in colliding_sides:
		if colliding_sides[key] == true:
			num_colliding_sides += 1
	
	if colliding_sides[Directions.LEFT] == true and colliding_sides[Directions.RIGHT] == true:
		opposite_sides_colliding = true
	if colliding_sides[Directions.UP] == true and colliding_sides[Directions.DOWN] == true:
		opposite_sides_colliding = true
	
	if num_colliding_sides >= 3:
		return false
	
	if opposite_sides_colliding:
		return false
	
	return true

func _check_state(curr_scale: float):
	if abs(curr_scale - min_scale) <= 0.1:
		current_state = State.POCKETABLE
	elif curr_scale == max_scale:
		current_state = State.IMMOVABLE
	elif curr_scale <= (min_scale + max_scale) / 2:
		current_state = State.LIFTABLE
	else:
		current_state = State.PUSHABLE

func resize(amount: float):
	var current_scale = scale.x
	current_scale += amount
	current_scale = clampf(current_scale, min_scale, max_scale)
	
	scale = Vector2(current_scale, current_scale)
	_check_state(current_scale)

func _on_lift():
	collider.disabled = true

func _on_visibility_changed() -> void:
	if visible:
		$BoxTrail.clear_points()
		set_physics_process.call_deferred(true)
		set_process.call_deferred(true)
		await get_tree().create_timer(0.03).timeout
		_disable_collider.call_deferred(false)
	else:
		set_physics_process.call_deferred(false)
		set_process.call_deferred(false)
		_disable_collider.call_deferred(true)

func _disable_collider(b: bool):
	collider.disabled = b

func _enlarge_flash():
	var tween = create_tween()
	tween.tween_property(sprite, "material:shader_parameter/progress_green", 1, 0.03)
	tween.tween_property(sprite, "material:shader_parameter/progress_green", 0, 0.07)

func _shrink_flash():
	var tween = create_tween()
	tween.tween_property(sprite, "material:shader_parameter/progress_red", 1, 0.03)
	tween.tween_property(sprite, "material:shader_parameter/progress_red", 0, 0.07)

func _play_sound(sound: AudioStream):
	if audio == null:
		return
	if sound == null:
		return
	audio.stream = sound
	audio.play()

func _process(_delta: float) -> void:
	if not was_on_floor and is_on_floor():
		_on_landing()
	was_on_floor = is_on_floor()

func _on_landing():
	if velocity.x:
		velocity.x = velocity.x / 4
	if landing_particles:
		landing_particles.restart()
