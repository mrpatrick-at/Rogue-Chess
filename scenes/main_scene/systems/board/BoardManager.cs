using Godot;
using System;
using System.Globalization;
using Chess.Consts;
using System.Numerics;
[GlobalClass]
// enums
public partial class BoardManager : CenterContainer {
	// consts
	// exports
	// signals
	// public vars
	public Board board;
	// private vars
	// onready vars
	// built-in override methods
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		board = new Board();
		this.AddChild(board);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) {

	}

	// public funcs

	// public static funcs
	public static bool IsValidIndex(int Index) {
		if(Index >= 0 && Index < 64){
			return true;
		};
		return false;
	}
	public static Vector2I GetVec2FromIndex(int Index) {
		int x = Index % 8;
		int y = Index >> 3;
		return new Vector2I(x, y);
	}
	public static int GetIndexFromBitmask(ulong Bitmask) {
		return BitOperations.TrailingZeroCount(Bitmask);
	}
	public static ulong GetBitmask(int Index) {
		ulong Bitmask = 1UL << Index;
		return Bitmask;
	}
	public static int GetPieceType(int PieceInt) {
		return PieceInt % 6;
	}
	public static int GetPieceColor(int PieceInt) {
		return PieceInt / 6;
	}
	public static string GetPieceString(int PieceInt) {
		return Enum.GetName(typeof(Piece.Name), PieceInt);
	}
	// private funcs
}

