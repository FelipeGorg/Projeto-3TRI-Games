class_name KillZone
extends Area2D
## Área de perigo, usada abaixo do mapa para quedas em buracos.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()
	elif body is Enemy:
		body.queue_free()
