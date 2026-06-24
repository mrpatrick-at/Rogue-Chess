using Godot;
using System;
using System.Globalization;
[GlobalClass]
public partial class BoardManager : AspectRatioContainer
{
// enums
// consts
// exports
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

// public methods

// private methods
}

