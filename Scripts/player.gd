extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 150
@export var acceleration: float = 350
@export var braking: float = 500
var direction_x: float

@export var coyote_time_duration: float = 0.3
@export var coyote_timer: Timer
var on_floor: bool
@export var jump_cut_damping_rate: float = 10000
@export var jump_height: float = 80
@export var jump_time_to_peak: float = 0.5
@export var jump_time_to_descent: float = 0.4

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0 

@export var jump_buffer_duration: float = 0.15
@export var jump_buffer_timer: Timer

@export var jump_particles: GPUParticles2D = null

@export_category("Shooting")
@export var shoot_rate: float = 0.25
@export var shrink_ray_offset: float = 15.0
@export var bullet_pool: Node
var last_shoot_time: float
var shoot_dir: Vector2

var controller_input: bool = false

@export_category("Object Interactions")
@export var interact_area: Area2D
@export var foot_marker: Marker2D
@export var throw_direction: Vector2 = Vector2(1.0, -0.5)
@export var throw_force: float = 200
var facing_left: bool = true
var lifted_object: ScalableObject
@export var lifted_object_attach_point: Marker2D
@export var max_pockets: int = 1
@export var pocket_object_toss_force = 300
@export var push_force: float = 30
var pocketed_objects: Array[ScalableObject]
@export var overhead_object_detector: Node2D

@export_category("Sound")
@export var sprite: AnimatedSprite2D
@export var shrink_ray: Sprite2D
@export var pocket_sprite: Sprite2D
@export var audio: AudioStreamPlayer
@export var footstep_sounds: Array[AudioStream]
@export var shoot_sounds: Array[AudioStream]
@export var footstep_interval: float = 0.5
@export var death_sound: AudioStream
@export var pickup_sound: AudioStream
@export var throw_sound: AudioStream
var last_footstep_time: float

var base_sprite_scale: Vector2
var base_offset: Vector2
var unhandled_input: bool = false
@export var death_particles: PackedScene = null

func _ready() -> void:
	if sprite:
		base_sprite_scale = sprite.scale
		base_offset = sprite.scale
	GameManager.ManualKill.connect(die)
	GameManager.SetCameraTarget.emit.call_deferred(self)
	on_spawn.call_deferred()

func _physics_process(delta: float) -> void:
	_get_input(delta)
	if direction_x:
		velocity.x = move_toward(velocity.x, direction_x * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, braking * delta)
	if not is_on_floor():
		velocity.y += _get_custom_gravity() * delta
	if on_floor != is_on_floor() and velocity.y >= 0:
		if coyote_timer:
			coyote_timer.start(coyote_time_duration)
	if is_on_floor() and not on_floor:
		_on_landing()
	on_floor = is_on_floor()
	_animate()
	move_and_slide()

func _on_landing():
	if jump_particles:
		jump_particles.restart()
	sprite.scale = base_sprite_scale
	sprite.offset = base_offset
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x + 0.2, 0.1)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y - 0.2, 0.1)
	tween.tween_property(sprite, "offset:y", base_offset.y + 6, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x, 0.1)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y, 0.1)
	tween.tween_property(sprite, "offset:y", base_offset.y, 0.1)

func _jump_animation():
	if jump_particles:
		jump_particles.restart()
	sprite.scale = base_sprite_scale
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x - 0.2, 0.1)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y + 0.2, 0.1)
	tween.set_parallel(false)
	tween.tween_interval(0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property(sprite, "scale:x", base_sprite_scale.x, 0.1)
	tween.tween_property(sprite, "scale:y", base_sprite_scale.y, 0.1)


func _process(_delta: float) -> void:
	if shrink_ray:
		shrink_ray.global_position = global_position + shoot_dir * shrink_ray_offset
		shrink_ray.rotation = shoot_dir.angle() + deg_to_rad(90)
	if direction_x and is_on_floor():
		_play_footsteps()
	_check_overhead_object()

func _get_input(_delta: float):
	
	if controller_input:
		var dir = Input.get_vector("aim_left","aim_right","aim_up","aim_down")
		if dir:
			shoot_dir = dir.normalized()
		if Input.is_action_pressed("enlarge"):
			_shoot(PlayerBullet.RayType.ENLARGE)
		if Input.is_action_pressed("shrink"):
			_shoot(PlayerBullet.RayType.SHRINK)
	else:
		var dir = global_position.direction_to(get_global_mouse_position())
		if dir:
			shoot_dir = dir.normalized()
		if unhandled_input:
			if Input.is_action_pressed("enlarge"):
				_shoot(PlayerBullet.RayType.ENLARGE)
			if Input.is_action_pressed("shrink"):
				_shoot(PlayerBullet.RayType.SHRINK)
	
	if jump_buffer_timer == null:
		return
	direction_x = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start(jump_buffer_duration)
	if jump_buffer_timer.time_left and (is_on_floor() or coyote_timer.time_left):
		velocity.y = jump_velocity
		_jump_animation()
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = velocity.y / 4
	if Input.is_action_pressed("interact"):
		_try_interact_object()
	if Input.is_action_just_pressed("throw"):
		_throw()

func _input(event: InputEvent) -> void:
	if Input.get_vector("aim_left","aim_right","aim_up","aim_down"):
		controller_input = true
	if event is InputEventMouseMotion:
		controller_input = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		unhandled_input = true
	if event is InputEventMouseButton and event.is_released():
		unhandled_input = false

func _get_custom_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _shoot(bullet_type: PlayerBullet.RayType):
	if bullet_pool == null:
		return
	var time = Time.get_unix_time_from_system()
	if time - last_shoot_time < shoot_rate:
		return
	last_shoot_time = time
	var bullet = bullet_pool.spawn()
	bullet.global_position = shrink_ray.global_position
	bullet.set_bullet(bullet_type, shoot_dir)
	if shoot_sounds.is_empty():
		return
	_play_sound(shoot_sounds.pick_random())

func _animate():
	if sprite == null:
		return
	
	if direction_x:
		sprite.flip_h = velocity.x > 0
		facing_left = velocity.x < 0
	var current_animation: String
	if is_on_floor():
		current_animation = "idle" if direction_x == 0 else "walk"
	else:
		current_animation = "jump"
	sprite.play(current_animation)

func _try_interact_object():
	if interact_area == null:
		return
	if foot_marker == null:
		return
	if not interact_area.has_overlapping_bodies():
		return
	var closest_dist: float = 99999
	var closest_body: ScalableObject
	for body in interact_area.get_overlapping_bodies():
		if not body.is_in_group("Object"):
			continue
		if global_position.distance_to(body.global_position) < closest_dist:
			closest_dist = global_position.distance_to(body.global_position)
			closest_body = body
	
	match closest_body.current_state:
		ScalableObject.State.POCKETABLE:
			_pocket_object(closest_body)
		ScalableObject.State.LIFTABLE:
			_lift_object(closest_body)
		ScalableObject.State.PUSHABLE:
			_push_object(closest_body)

func _lift_object(object: ScalableObject):
	if object.global_position.y > foot_marker.global_position.y:
		return
	if lifted_object_attach_point == null:
		return
	if lifted_object:
		return
	_play_sound(pickup_sound)
	lifted_object = object
	lifted_object.is_lifted = true
	lifted_object.reparent(lifted_object_attach_point, true)
	lifted_object.global_position = lifted_object_attach_point.global_position

func _pocket_object(object: ScalableObject):
	if len(pocketed_objects) >= max_pockets:
		return
	_play_sound(pickup_sound)
	pocketed_objects.append(object)
	if pocket_sprite:
		pocket_sprite.visible = true
	object.visible = false

func _push_object(object: ScalableObject):
	if not object.State.PUSHABLE:
		return
	if object.global_position.y > foot_marker.global_position.y:
		return
	object.velocity.x = direction_x * push_force

func _throw():
	if lifted_object:
		lifted_object_attach_point.remove_child(lifted_object)
		get_tree().current_scene.add_child(lifted_object)
		lifted_object.is_lifted = false
		lifted_object.global_position = lifted_object_attach_point.global_position
		
		var dir: Vector2
		dir.x = throw_direction.x * -1 if facing_left else throw_direction.x
		dir.y = throw_direction.y
			
		lifted_object.velocity = dir.normalized() * throw_force 
		lifted_object = null
		_play_sound(throw_sound)
		return
	
	if pocketed_objects.is_empty():
		return
	if pocket_sprite:
		pocket_sprite.visible = false
	_play_sound(throw_sound)
	var object_to_throw = pocketed_objects.pop_front()
	object_to_throw.visible = true
	object_to_throw.global_position = shrink_ray.global_position
	object_to_throw.velocity = shoot_dir * pocket_object_toss_force

func die():
	if death_particles:
		var particles = death_particles.instantiate()
		get_tree().current_scene.add_child(particles)
		particles.global_position = global_position
	_play_sound(death_sound)
	GameManager.ShakeCamera.emit()
	visible = false
	await get_tree().create_timer(0.3).timeout
	SceneTransition.change_scene("res://Scenes/Levels/tutorial_level.tscn")

func on_spawn():
	if GameManager.current_checkpoint == Vector2.ZERO:
		return
	global_position = GameManager.current_checkpoint
	#wait for scene transition to end before giving control

func _play_footsteps():
	if footstep_sounds.is_empty():
		return
	
	var time = Time.get_unix_time_from_system()
	if time - last_footstep_time < footstep_interval:
		return
	
	last_footstep_time = time
	_play_sound(footstep_sounds.pick_random())

func _play_sound(sound: AudioStream):
	if audio == null:
		return
	if sound == null:
		return
	audio.stream = sound
	audio.play()

func _check_overhead_object():
	if overhead_object_detector == null:
		return
	var raycasts: Array[RayCast2D]
	for child in overhead_object_detector.get_children():
		if child is RayCast2D:
			raycasts.append(child)
	for ray in raycasts:
		if not ray.is_colliding():
			continue
		var body: ScalableObject = ray.get_collider()
		if not body.is_in_group("Object"):
			continue
		if body.velocity.y > 0 and not body.is_lifted:
			match body.current_state:
				ScalableObject.State.POCKETABLE:
					_pocket_object.call_deferred(body)
				ScalableObject.State.LIFTABLE:
					_lift_object.call_deferred(body)
				ScalableObject.State.PUSHABLE:
					if is_on_floor():
						die()
				ScalableObject.State.IMMOVABLE:
					if is_on_floor():
						die()
