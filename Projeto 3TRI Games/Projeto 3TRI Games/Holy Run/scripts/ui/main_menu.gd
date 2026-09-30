extends Control
## Menu inicial com um único botão.

@onready var play_button: Button = %PlayButton


func _ready() -> void:
	play_button.pressed.connect(Game.start_game)
	play_button.grab_focus()
