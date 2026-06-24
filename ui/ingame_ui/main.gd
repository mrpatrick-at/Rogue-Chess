extends CenterContainer
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var turn_amount_label: Label = $PanelContainer/BoxContainer/TurnAmount/PanelContainer/BoxContainer/TurnAmountLabel
@onready var color_move_label: Label = $PanelContainer/BoxContainer/ColorMove/PanelContainer/BoxContainer/ColorMoveLabel
@onready var fifty_move_rule_label: Label = $PanelContainer/BoxContainer/FiftyMoveRule/PanelContainer/BoxContainer/FiftyMoveRuleLabel
var board: Board
# obj_ for node refrences1 test
## built-in override methods

#func _ready() -> void:
	#board = Scripts.BOARD_MANAGER.board
#
#func _physics_process(_delta: float) -> void:
	#set_labels()
#
### public methods
#
#func set_labels() -> void:
	#set_turn_label()
	#set_color_move_label()
	##set_fifty_move_rule_label()
#
#func set_turn_label() -> void:
	#turn_amount_label.text = str(board.turn_amount)
#
#func set_color_move_label() -> void:
	#if board.turn_color == Consts.COLOR.WHITE:
		#color_move_label.text = "White's"
	#else:
		#color_move_label.text = "Black's"

#func set_fifty_move_rule_label() -> void:
	#fifty_move_rule_label.text = str(board.fifty_move_rule)
## private methods
