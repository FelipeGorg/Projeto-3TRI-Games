extends Node
## Autoload "Game": estado global da partida e navegação entre cenas.
## Todo o resto do jogo conversa com ele por sinais e métodos simples.

signal coins_changed(total: int)

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const FIRST_LEVEL_SCENE := "res://scenes/levels/level_01.tscn"

var coins: int = 0
var current_level_path: String = FIRST_LEVEL_SCENE


func add_coins(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)


func start_game() -> void:
	coins = 0
	change_level(FIRST_LEVEL_SCENE)


func change_level(path: String) -> void:
	current_level_path = path
	_change_scene(path)


func restart_level() -> void:
	coins = 0
	_change_scene(current_level_path)


func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)


func _change_scene(path: String) -> void:
	# A tela de game over pausa a árvore, então sempre despausamos antes de trocar.
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
