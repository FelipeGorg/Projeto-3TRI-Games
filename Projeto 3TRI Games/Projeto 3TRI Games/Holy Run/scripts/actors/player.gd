class_name Player
extends CharacterBody2D
## Personagem jogável: corrida com aceleração, pulo variável, coyote time e jump buffer.
## As animações são escolhidas por nome. Se o SpriteFrames não tiver uma delas, ela é ignorada.

signal died

const ANIM_IDLE := &"idle"
const ANIM_RUN := &"run"
const ANIM_JUMP := &"jump"
const ANIM_FALL := &"fall"
const ANIM_DIE := &"die"
const ANIM_KNEEL := &"kneel"

@export_group("Movimento")
@export var max_speed: float = 180.0
@export var acceleration: float = 1100.0
@export var friction: float = 1600.0
@export_range(0.0, 1.0) var air_control: float = 0.7

@export_group("Pulo")
@export var jump_velocity: float = -520.0
@export var fall_gravity_multiplier: float = 1.4
@export_range(0.0, 1.0) var jump_cut_multiplier: float = 0.5
@export var max_fall_speed: float = 300.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@export_group("Interações")
@export var stomp_bounce_velocity: float = -160.0
@export var death_jump_velocity: float = -100.0
## Distância do centro do personagem até os pés. Usada pelos inimigos para detectar pisão.
@export var feet_offset: float = 24.0

var is_dead: bool = false
var is_kneeling := false
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D


func _physics_process(delta):
	kneel()

	if is_dead:
		return
	if is_dead:
		_apply_gravity(delta)
		move_and_slide()
		return

	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_horizontal(delta)
	move_and_slide()
	_update_animation()


func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2(0.0, death_jump_velocity)
	# Sem colisão, o personagem cai atravessando o cenário.
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	_play(ANIM_DIE)
	died.emit()


func bounce(bounce_velocity: float = 0.0) -> void:
	velocity.y = bounce_velocity if bounce_velocity != 0.0 else stomp_bounce_velocity
	_coyote_timer = 0.0


func set_camera_limits(bounds: Rect2i) -> void:
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.end.x
	camera.limit_bottom = bounds.end.y
	camera.reset_smoothing()


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and not is_dead:
		return
	var gravity := _gravity
	if velocity.y > 0.0:
		gravity *= fall_gravity_multiplier
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _handle_jump(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Soltar o botão cedo corta o pulo, permitindo saltos curtos.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


func _handle_horizontal(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var control := 1.0 if is_on_floor() else air_control
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * control * delta)
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * control * delta)


func _update_animation() -> void:

	if is_kneeling and is_on_floor():
		_play(ANIM_KNEEL)
		return

	if not is_on_floor():
		_play(ANIM_JUMP if velocity.y < 0.0 else ANIM_FALL)
	elif absf(velocity.x) > 10.0:
		_play(ANIM_RUN)
	else:
		_play(ANIM_IDLE)




func _play(animation_name: StringName) -> void:
	var frames := sprite.sprite_frames
	if frames == null or not frames.has_animation(animation_name):
		return
	if sprite.animation != animation_name:
		sprite.play(animation_name)
		
func kneel():
	is_kneeling = Input.is_action_pressed("kneel")
