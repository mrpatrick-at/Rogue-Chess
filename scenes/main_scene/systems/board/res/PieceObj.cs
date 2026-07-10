using Godot;
using Godot.NativeInterop;
using System;
using System.Threading;
using System.Threading.Tasks;
[GlobalClass]
public partial class PieceObj : MeshInstance2D
{
// enums
// consts
// exports
// public vars
public Vector2I coord = Vector2I.Zero;
// private vars
private static readonly Shader shader_res = GD.Load<Shader>("res://scenes/main_scene/systems/board/shaders/piece_shader.gdshader");
private Tween animation_tween;
private float y_offset;
// onready vars
// built-in overide methods
	public override void _Ready(){
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta){
	}
// public methods
	public void Setup(Vector2I starting_coord, String piece_name){
		ulong starting_time = Time.GetTicksUsec();
		GD.PrintRich("[color=Orange]Piece-[/color] Started Building Board");
		coord = starting_coord;

		QuadMesh quadmesh = new QuadMesh();
		quadmesh.Size = new Vector2I(16,32);

		this.Mesh = quadmesh;

		CompressedTexture2D texture = GD.Load<CompressedTexture2D>($"res://assets/images/pieces/{piece_name}.png");
		this.Texture = texture;

		this.ZIndex = coord.Y;
		
		ShaderMaterial mat = new ShaderMaterial();
		mat.Shader = shader_res;
		mat.SetShaderParameter("coord", coord);

		this.Material = mat;
		this.Scale = new Vector2I(8,8);
		float ending_time = (Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich($"[color=Orange]PIECE-[/color] Created at: [color=gold]{coord}[/color] in: [color=gold]{ending_time}ms[/color]");
	}
	public void highlight(){
		if(animation_tween != null){
			animation_tween.Kill();
		}
		animation_tween = CreateTween().SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Sine);
		animation_tween.TweenMethod(Callable.From<float>((val) => _set_shader_value(val)), y_offset, 4.0, 0.07);
	}
	public async void unhighlight(){
		await Task.Delay(50);
		if(animation_tween != null){
			animation_tween.Kill();
		}
		animation_tween = CreateTween().SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Sine);
		animation_tween.TweenMethod(Callable.From<float>((val) => _set_shader_value(val)), y_offset, 0.0, 0.05);
	}
	public void reset_highlight(){
		if(animation_tween != null){
			animation_tween.Kill();
		}
		_set_shader_value(0);
	}
	public void set_coord(Vector2I new_coord){
		this.coord = new_coord;
		((ShaderMaterial)Material).SetShaderParameter("coord", coord);
		this.reset_highlight();
		this.ZIndex = coord.Y;
	}
// private methods
private void _set_shader_value(float value){
	y_offset = value;
	((ShaderMaterial)Material).SetShaderParameter("y_offset", y_offset);
}
}
