class_name Enemy
extends CharacterBody2D
## Inimigo simples que patrulha e vira ao bater em parede ou ao chegar na beira de uma plataforma.
## Morre quando o jogador cai em cima dele. Encostar de lado ou por baixo mata o jogador.

@export var speed: float = 40.0
## -1 começa indo para a esquerda, 1 para a direita.
@export_enum("Esquerda:-1", "Direita:1") var start_direction: int = -1
## Folga em pixels para considerar que o jogador veio de cima.
@export var stomp_tolerance: float = 6.0
@export var death_duration: float = 0.35

var direction: int = -1
var is_dead: bool = false

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_check: RayCast2D = $FloorCheck
@onready var hitbox: Area2D = $Hitbox
@onready var body_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	direction = -1 if start_direction < 0 else 1
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_apply_direction()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += _gravity * delta
	velocity.x = direction * speed
	move_and_slide()

	# O raycast só atualiza sozinho no início do tick, então forçamos a leitura após mover.
	var reached_ledge := false
	if is_on_floor():
		floor_check.force_raycast_update()
		reached_ledge = not floor_check.is_colliding()
	if is_on_wall() or reached_ledge:
		_turn_around()


func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	hitbox.set_deferred("monitoring", false)
	body_shape.set_deferred("disabled", true)
	_play(&"die")

	# Efeito provisório de achatar. Some quando houver animação de morte pronta.
	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale:y", 0.2, death_duration)
	tween.tween_property(sprite, "position:y", sprite.position.y + 12.0, death_duration)
	tween.tween_property(sprite, "modulate:a", 0.0, death_duration)
	tween.chain().tween_callback(queue_free)


func _turn_around() -> void:
	direction *= -1
	_apply_direction()
	floor_check.force_raycast_update()


func _apply_direction() -> void:
	# A arte padrão olha para a esquerda.
	sprite.flip_h = direction > 0
	floor_check.position.x = absf(floor_check.position.x) * direction


func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead or not (body is Player):
		return
	var player := body as Player
	if player.is_dead:
		return
	var feet_y := player.global_position.y + player.feet_offset
	var came_from_above := player.velocity.y > 0.0 and feet_y <= global_position.y + stomp_tolerance
	if came_from_above:
		player.bounce()
		die()
	else:
		player.die()


func _play(animation_name: StringName) -> void:
	var frames := sprite.sprite_frames
	if frames != null and frames.has_animation(animation_name):
		sprite.play(animation_name)
