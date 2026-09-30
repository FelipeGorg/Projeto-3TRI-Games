extends CanvasLayer
## HUD com o contador de moedas.

@onready var coin_label: Label = %CoinLabel


func _ready() -> void:
	Game.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(Game.coins)


func _on_coins_changed(total: int) -> void:
	coin_label.text = "Moedas: %d" % total
