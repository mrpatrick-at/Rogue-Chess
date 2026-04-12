extends RefCounted
## Board Consts
enum BOARD_LIST{_0, # use _0 for none
	COLOR,
	PIECE,
}
enum COLOR_LIST{
	NONE, # 0
	WHITE, # 1
	BLACK, # 2
}

## Piece Consts
enum PIECE_LIST{_0, # use _0 for null
	PIECE_TYPE,
	PIECE_COLOR,
	PIECE_OBJ,
	PIECE_SPRITE,
	TIMES_MOVED,
	PAWN_MOVED_TWO_TILES,
}
enum PIECE_TYPE{_0, # use _0 for null
	NONE,
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}
enum PIECE_COLOR{_0, # use _0 for null
WHITE,
BLACK,
}
enum PAWN_MOVED_TWO_TILES{_0, # use _0 for null
TRUE,
FALSE,
}
