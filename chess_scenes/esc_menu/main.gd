extends Control
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

func _on_continue_pressed() -> void:
	hide()

func _on_options_pressed() -> void:
	Scripts.MAIN.clear_data()
	get_tree().change_scene_to_file("res://chess_scenes/main_menu/main.tscn") # Add Options Scene Later

func _on_restart_pressed() -> void:
	Scripts.MAIN.clear_data()
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	Scripts.MAIN.clear_data()
	get_tree().change_scene_to_file("res://chess_scenes/main_menu/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

## public methods

## private methods
