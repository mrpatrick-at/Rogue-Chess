using Godot;
using System;

public partial class MoveManager : Node
{
// enums
// consts
// exports
// public vars
// private vars
private ulong[] knight_moves = new ulong[64];
private ulong[] king_moves = new ulong[64];
// onready vars
// built-in override methods
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {

	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) {

	}

// public methods

// public void PrecalcMoves() {
// 	knight_moves = _precalc_knight_moves();
// 	king_moves = _precalc_king_moves();

// }

// public int[] get_piece_moves(int index){
// 	int piece_int = get_piece_int(index);
// 	ulong white_pieces = get_occupied_bitboard((int)COLOR.WHITE);
// 	ulong black_pieces = get_occupied_bitboard((int)COLOR.BLACK);
// 	ulong all_pieces = white_pieces | black_pieces;

// 	bool is_white = is_piece_white(piece_int);
// 	ulong friendly_pieces = is_white ? white_pieces : black_pieces;

// 	ulong moves = 0UL;

// 	switch (piece_int){
// 		case (int)PIECE.W_PAWN:
// 		case (int)PIECE.B_PAWN:
// 			moves = get_pawn_moves(index, is_white, all_pieces, friendly_pieces);
// 			break;
		
// 		case (int)PIECE.W_ROOK:
// 		case (int)PIECE.B_ROOK:
// 			moves = get_slide_moves(index, all_pieces, (int)SLIDE_TYPE.ROOK);
// 			break;
		
// 		case (int)PIECE.W_KNIGHT:
// 		case (int)PIECE.B_KNIGHT:
// 			moves = knight_moves[index];
// 			break;

// 		case (int)PIECE.W_BISHOP:
// 		case (int)PIECE.B_BISHOP:
// 			moves = get_slide_moves(index, all_pieces, (int)SLIDE_TYPE.BISHOP);
// 			break;

// 		case (int)PIECE.W_QUEEN:
// 		case (int)PIECE.B_QUEEN:
// 			moves = get_slide_moves(index, all_pieces, (int)SLIDE_TYPE.ROOK) | get_slide_moves(index, all_pieces, (int)SLIDE_TYPE.BISHOP);
// 			break;

// 		case (int)PIECE.W_KING:
// 		case (int)PIECE.B_KING:
// 			moves = king_moves[index];
// 			break;
// 	}

// 	moves &= ~friendly_pieces;
	
// 	int[] translated_moves = new int[64];

// 	for(int i = 0; i < 64; i++){
// 		ulong step = 1UL << i;
// 		if((moves & step) != 0){
// 			translated_moves[i] = 1;
// 		};
// 	};

// 	return translated_moves;
// }
// public void move_piece(int index, int new_index) {
// 	ulong new_bitmask = get_bitmask(new_index);

// 	int capture_piece_int = get_piece_int(new_index);
// 	if (capture_piece_int != -1) { // If there is a piece on target coord
// 		bitboard[capture_piece_int] ^= new_bitmask;
// 		Piece capture_piece = (Piece)piece_objs[new_index];
// 		piece_objs.Remove(new_index);
// 		this.RemoveChild(capture_piece);
// 		capture_piece.Free();
// 	}

// 	ulong bitmask = get_bitmask(index);
// 	int piece_int = get_piece_int(index);
// 	bitboard[piece_int] ^= bitmask;
// 	bitboard[piece_int] |= new_bitmask;

// 	Piece piece = (Piece)piece_objs[index];
// 	piece_objs[new_index] = piece;
// 	piece_objs.Remove(index);
// 	piece.set_coord(get_vec2_from_index(new_index));

// 	turn_color ^= 1;
// 	GD.Print($"BOARD- Piece Moved! Turn Color: {Enum.GetName(typeof(COLOR), turn_color)}");
// }

// // private methods
// private ulong get_pawn_moves(int index, bool is_white, ulong all_pieces, ulong friendly_pieces){
// 	ulong bitmask = get_bitmask(index);
// 	ulong moves = 0UL;
	
// 	if (is_white) {
// 		moves |= bitmask >> 8;
// 		if ((bitmask & 71776119061217280) == bitmask) { // white in start pos
// 			moves |= bitmask >> 16;
// 		}
// 	} else {
// 		moves |= bitmask << 8;
// 		if ((bitmask & 65280) == bitmask) { // black in start pos
// 			moves |= bitmask << 16;
// 		}
// 	}

// 	ulong capturemask = 0UL;

// 	if((bitmask & 72340172838076673) == 0){ // can go left
// 		capturemask |= is_white ? bitmask >> 9 : bitmask << 7;
// 	}
// 	if((bitmask & 9259542123273814144) == 0){ // can go right
// 		capturemask |= is_white ? bitmask >> 7 : bitmask << 9;
// 	}

// 	moves |= capturemask & all_pieces;
// 	return moves;
// }
// private ulong get_slide_moves(int index, ulong all_pieces, ulong slide_type){
// 	ulong bitmask = get_bitmask(index);
// 	ulong moves = 0UL;
// 	Vector2I coord = get_vec2_from_index(index);
	
// 		int left_tiles = coord.X;
// 		int right_tiles = 7 - coord.X;

// 		int up_tiles = coord.Y;
// 		int down_tiles = 7 - coord.Y;

// 	if (slide_type == (int)SLIDE_TYPE.ROOK){
// 		for (int x = 0; x < left_tiles; x++) {
// 			ulong step_bitmask =  bitmask >> (x + 1);
// 			moves |= step_bitmask;
// 			if ((step_bitmask & all_pieces) != 0) {
// 				break;
// 			}
// 		}
// 		for (int x = 0; x < right_tiles; x++) {
// 			ulong step_bitmask = bitmask << (x + 1);
// 			moves |= step_bitmask;
// 			if ((step_bitmask & all_pieces) != 0) {
// 				break;
// 			}
// 		}
// 		for (int y = 0; y < up_tiles; y++) {
// 			ulong step_bitmask = bitmask >> ((y + 1) << 3);
// 			moves |= step_bitmask;
// 			if ((step_bitmask & all_pieces) != 0) {
// 				break;
// 			}
// 		}
// 		for (int y = 0; y < down_tiles; y++) {
// 			ulong step_bitmask = bitmask << ((y + 1) << 3);
// 			moves |= step_bitmask;
// 			if ((step_bitmask & all_pieces) != 0) {
// 				break;
// 			}
// 		}
// 	} else {
// 		for (int xy = 0; xy < left_tiles; xy++) {
// 			if (xy < up_tiles) {
// 				ulong step_bitmask = bitmask >> ((xy + 1) * 9);
// 				moves |= step_bitmask;
// 				if ((step_bitmask & all_pieces) != 0) {
// 					break;
// 				}
// 			}
// 			if (xy < down_tiles) {
// 				ulong step_bitmask = bitmask << ((xy + 1) * 7);
// 				moves |= step_bitmask;
// 				if ((step_bitmask & all_pieces) != 0) {
// 					break;
// 				}
// 			}
// 		}
// 		for (int yx = 0; yx < right_tiles; yx++) {
// 			if (yx < up_tiles) {
// 				ulong step_bitmask = bitmask >> ((yx + 1) * 7);
// 				moves |= step_bitmask;
// 				if ((step_bitmask & all_pieces) != 0) {
// 					break;
// 				}
// 			}
// 			if (yx < down_tiles) {
// 				ulong step_bitmask = bitmask << ((yx + 1) * 9);
// 				moves |= step_bitmask;
// 				if ((step_bitmask & all_pieces) != 0) {
// 					break;
// 				}
// 			}
// 		}
// 	}
// 	return moves;
// }
// private ulong[] _precalc_knight_moves(){
// 	ulong[] moves = new ulong[64];
// 	for (int i = 0; i < 64; i++) {
// 		ulong bitmask = get_bitmask(i);

// 		if ((bitmask & 65535) == 0) { // can go 2 up
// 			if ((bitmask & 72340172838076673) == 0) { // can go 1 left
// 				moves[i] |= bitmask >> 17;
// 			}
// 			if ((bitmask & 9259542123273814144) == 0) { // can go 1 right
// 				moves[i] |= bitmask >> 15;
// 			}
// 		}

// 		if ((bitmask & 18446462598732840960) == 0) { // can go 2 down
// 			if ((bitmask & 72340172838076673) == 0) { // can go 1 left
// 				moves[i] |= bitmask << 15;
// 			}
// 			if ((bitmask & 9259542123273814144) == 0) { // can go 1 right
// 				moves[i] |= bitmask << 17;
// 			}
// 		}

// 		if ((bitmask & 217020518514230019) == 0) { // can go 2 left
// 			if ((bitmask & 255) == 0) { // can go 1 up
// 				moves[i] |= bitmask >> 10;
// 			}
// 			if ((bitmask & 18374686479671623680) == 0) { // can go 1 down
// 				moves[i] |= bitmask << 6;
// 			}
// 		}

// 		if ((bitmask & 13889313184910721216) == 0) { // can go 2 right
// 			if ((bitmask & 255) == 0) { // can go 1 up
// 				moves[i] |= bitmask >> 6;
// 			}
// 			if ((bitmask & 18374686479671623680) == 0) { // can go 1 down
// 				moves[i] |= bitmask << 10;
// 			}
// 		}
// 	}

// 	return moves;
// }
// private ulong[] _precalc_king_moves(){
// 	ulong[] moves = new ulong[64];
// 	for (int i = 0; i < 64; i++) {
// 		ulong bitmask = get_bitmask(i);
// 		if ((bitmask & 255) == 0) { // can go up
// 			moves[i] |= bitmask >> 8;

// 			if ((bitmask & 72340172838076673) == 0) { // can go left
// 				moves[i] |= bitmask >> 9;
// 			}
// 			if ((bitmask & 9259542123273814144) == 0) { // can go right
// 				moves[i] |= bitmask >> 7;
// 			}

// 		}
// 		if ((bitmask & 18374686479671623680) == 0) { // can go down
// 			moves[i] |= bitmask << 8;

// 			if ((bitmask & 72340172838076673) == 0) { // can go left
// 				moves[i] |= bitmask << 7;
// 			}
// 			if ((bitmask & 9259542123273814144) == 0) { // can go right
// 				moves[i] |= bitmask << 9;
// 			}

// 		}
// 		if ((bitmask & 72340172838076673) == 0) { // can go left
// 			moves[i] |= bitmask >> 1;
// 		}
// 		if ((bitmask & 9259542123273814144) == 0) { // can go right
// 			moves[i] |= bitmask << 1;
// 		}

// 	}
// 	return moves;
// }
}

