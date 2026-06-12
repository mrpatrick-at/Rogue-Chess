using Godot;
using System;
[GlobalClass]
public partial class Piece : MeshInstance2D
{
// enums
// consts
//const PackedVector2Array _knight_directions = {Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)};
//const PackedVector2Array _rook_directions = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
//const PackedVector2Array _bishop_directions = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
// exports
// public vars
public Vector2I coord = Vector2I.Zero;
// private vars
private static readonly Shader shader_res = GD.Load<Shader>("res://scenes/main_scene/systems/board/shaders/piece_shader.gdshader");
private Tween animation_tween;
private float y_offset;
// Called when the node enters the scene tree for the first time.
// onready vars
// built-in overide methods
	public override void _Ready(){
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta){

	}
// public methods
	public void setup(Vector2I starting_coord, String piece_name){
		ulong starting_time = Time.GetTicksUsec();
		GD.PrintRich("[color=Orange]Piece-[/color] Started Building Board");
		coord = starting_coord;

		QuadMesh quadmesh = new QuadMesh();
		quadmesh.Size = new Vector2I(16,32);

		this.Mesh = quadmesh;

		CompressedTexture2D texture = GD.Load<CompressedTexture2D>($"res://assets/images/pieces/{piece_name}.png");
		this.Texture = texture;

		this.ZIndex = -coord.Y + 7;
		
		ShaderMaterial mat = new ShaderMaterial();
		mat.Shader = shader_res;
		mat.SetShaderParameter("coord", coord);

		this.Material = mat;
		this.Scale = new Vector2I(8,8);
		float ending_time = (Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Orange]PIECE-[/color] Created at: [color=gold]{coord}[/color] in: [color=gold]{ending_time}ms[/color]");

	}
// private methods
}
