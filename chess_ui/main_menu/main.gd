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

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://chess_scenes/main_scene/main.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://chess_scenes/main_scene/main.tscn") # Add Option Scene Later

func _on_quit_pressed() -> void:
	get_tree().quit()

## public methods

## private methods
