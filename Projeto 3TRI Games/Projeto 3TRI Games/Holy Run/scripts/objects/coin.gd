class_name Coin
extends Area2D
## Coletável. Soma no contador global ao ser tocado pelo jogador.

@export var value: int = 1

var _collected: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not (body is Player):
		return
	_collected = true
	Game.add_coins(value)
	shape.set_deferred("disabled", true)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "position:y", -16.0, 0.25).as_relative()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
