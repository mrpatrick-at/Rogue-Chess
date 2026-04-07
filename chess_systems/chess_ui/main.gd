extends Control
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var turn_amount_label: Label = $CenterContainer/PanelContainer/BoxContainer/TurnAmountValue
# obj_ for node refrences1 test
## built-in override methods

func _ready() -> void:
	pass 

func _physics_process(_delta: float) -> void:
	set_labels()
	pass

## public methods

func set_labels() -> void:
	set_turn_label()

func set_turn_label() -> void:
	turn_amount_label.text = str(Scripts.turn_amount)

## private methods
