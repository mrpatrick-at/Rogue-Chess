using Godot;
using System;
using System.Linq;

using Chess.systems.game.consts;
using Chess.systems.renderer.classes;

namespace Chess.systems.renderer;

// enums
enum CellTexs : int {
    HeadUp = 0,
    HeadRight = 1,
    HeadDown = 2,
    HeadLeft = 3,
    BodyUp = 4,
    BodyRight = 5,
    BodyDown = 6,
    BodyLeft = 7
}

[GlobalClass]
public partial class Renderer : Node2D {
    // signals
    // exports
    // --- Consts ---
    const String BoardShaderPath = "res://assets/shaders/board/board.gdshader";
    // const String SnakeShaderPath = "res://assets/shaders/board/piece.gdshader";
    const String SpriteSheetPath = "res://assets/images/pieces/spritesheet.png";
    // --- Public Vars ---
    public int SizeMult = 8;
    // --- Private Vars ---
    private Rid SpriteSheet;
    // Layers
    private ShaderLayer BoardLayer;
    // Layer Vars
    private Rect2 RenderRect;
    private Transform2D BoardTransform;
    // --- Override Methods ---
    public override void _Ready() {
        ApplyGrid();
    }
    public override void _ExitTree() {
        base._ExitTree();
        // Free all Layers
        BoardLayer.Free();
        // SnakeLayer.Free();
    }
    public override void _Process(double delta) {
    }
    // --- Public Methods ---
    public void UpdateTileStates(int[] TileStates) {
        BoardLayer.SetShaderParameter("TileStates", TileStates);
    }
    public void UpdatePiecePosistions(int[] PiecePosistions) {
        BoardLayer.SetShaderParameter("PiecePosistions", PiecePosistions);
    }
    public void UpdatePieceOffsets(float[] PieceOffsets) {
        BoardLayer.SetShaderParameter("PieceOffsets", PieceOffsets);
    }
    // --- Private Methods ---
    private void ApplyGrid() {
        Vector2 ScreenSize = GetViewportRect().Size;
        Vector2 RenderSize = Consts.BoardPixelSize;

        RenderRect = new Rect2(Vector2.Zero, RenderSize);
        BoardTransform = new(new Vector2(SizeMult, 0), new Vector2(0, SizeMult), ScreenSize / 2 - RenderSize * SizeMult / 2);
        // BoardTransform = new();

        // Make Grid Layer
        Shader GridShader = GD.Load<Shader>(BoardShaderPath);

        SpriteSheet = GD.Load<Texture2D>(SpriteSheetPath).GetRid();

        BoardLayer = new ShaderLayer(
            this,
            GridShader,
            RenderRect,
            BoardTransform,
            0
        );

        BoardLayer.SetShaderParameter("BoardSize", 8);

        BoardLayer.SetShaderParameter("BrightTileColor", new Godot.Vector4(1, 1, 1, 1));
        BoardLayer.SetShaderParameter("DarkTileColor", new Godot.Vector4(0, 0, 0, 1));

        BoardLayer.SetShaderParameter("SpriteSheet", SpriteSheet);

        // Make Snake Layer
        // Shader SnakeShader = GD.Load<Shader>(SnakeShaderPath);

        // SnakeLayer = new ShaderLayer(
        //     this,
        //     SnakeShader,
        //     RenderRect,
        //     1
        // );

        // SpriteSheet = GD.Load<Texture2D>(SpriteSheetPath).GetRid();
        // SnakeLayer.SetShaderParameter("SpriteSheet", SpriteSheet);

        // SnakeLayer.SetShaderParameter("GridSize", Consts.GridDimensions);
        // SnakeLayer.SetShaderParameter("CellAmount", Consts.CellAmount);

        // (ShaderMat as ShaderMaterial).SetShaderParameter("SpritePixelSize", Consts.SpritePixelSize);
    }
}

