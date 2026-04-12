extends Control
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var turn_amount_label: Label = $TopUI/PanelContainer/BoxContainer/TurnAmount/PanelContainer/BoxContainer/Value
@onready var color_move_label: Label = $TopUI/PanelContainer/BoxContainer/ColorMove/PanelContainer/BoxContainer/Value
@onready var fifty_move_rule_label: Label = $TopUI/PanelContainer/BoxContainer/FiftyMoveRule/PanelContainer/BoxContainer/Value
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
	set_color_move_label()
	set_fifty_move_rule_label()

func set_turn_label() -> void:
	turn_amount_label.text = str(Scripts.turn_amount)

func set_color_move_label() -> void:
	if Scripts.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		color_move_label.text = "White's"
	else:
		color_move_label.text = "Black's"
	

func set_fifty_move_rule_label() -> void:
	fifty_move_rule_label.text = str(Scripts.fifty_move_rule)
## private methods
