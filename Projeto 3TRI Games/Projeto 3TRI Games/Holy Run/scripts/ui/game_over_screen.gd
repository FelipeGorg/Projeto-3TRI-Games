class_name GameOverScreen
extends CanvasLayer
## Tela de game over. Pausa o jogo ao abrir. O nó raiz roda em modo "Always" para os botões funcionarem.

@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	hide()
	retry_button.pressed.connect(Game.restart_level)
	menu_button.pressed.connect(Game.go_to_main_menu)


func open() -> void:
	show()
	get_tree().paused = true
	retry_button.grab_focus()
