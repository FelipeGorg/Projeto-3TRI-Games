@tool
class_name Platform
extends StaticBody2D
## Bloco retangular redimensionável. Mude `size` no Inspetor e a colisão e o visual acompanham.
## A origem fica no canto superior esquerdo. Para trocar a arte, altere a textura do Sprite2D.

@export var size: Vector2 = Vector2(96.0, 32.0):
	set(value):
		size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var rect := RectangleShape2D.new()
	rect.size = size
	$CollisionShape2D.shape = rect
	$CollisionShape2D.position = size * 0.5
	$Sprite2D.region_rect = Rect2(Vector2.ZERO, size)
