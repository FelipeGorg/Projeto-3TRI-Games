extends Node2D
## Script base de uma fase: configura a câmera e reage à morte do jogador.

## Área da fase em pixels. A câmera não sai dela.
@export var bounds: Rect2i = Rect2i(0, 0, 2560, 360)
@export var game_over_delay: float = 1.0

@onready var player: Player = %Player
@onready var game_over_screen: GameOverScreen = %GameOver


func _ready() -> void:
	player.set_camera_limits(bounds)
	player.died.connect(_on_player_died)


func _on_player_died() -> void:
	await get_tree().create_timer(game_over_delay).timeout
	if is_inside_tree():
		game_over_screen.open()
