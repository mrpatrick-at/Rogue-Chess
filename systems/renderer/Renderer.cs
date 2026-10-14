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
    private Rid SpriteSheet;
    // Layers
    private ShaderLayer BoardLayer;
    private ShaderLayer SnakeLayer;
    // Render Vars
    private Rect2 RenderRect;
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
    public void UpdateTileState(int[] TileStates) {
        BoardLayer.SetShaderParameter("TileStates", TileStates);
    }
    public void UpdatePiecePosistions(int[] PiecePosistions) {
        BoardLayer.SetShaderParameter("PiecePosistions", PiecePosistions);
    }
    // --- Private Methods ---
    private void ApplyGrid() {
        Vector2 ScreenSize = GetViewportRect().Size;

        // Vector2 RenderSize = Consts.BoardSize * Consts.BoardSize * 4;
        Vector2 RenderSize = new Vector2I(8, 8) * new Vector2I(8, 8) * 4;
        Vector2 RenderPosition = (ScreenSize - RenderSize) / 2;

        RenderRect = new Rect2(RenderPosition, RenderSize);

        // Make Grid Layer
        Shader GridShader = GD.Load<Shader>(BoardShaderPath);

        SpriteSheet = GD.Load<Texture2D>(SpriteSheetPath).GetRid();

        BoardLayer = new ShaderLayer(
            this,
            GridShader,
            RenderRect,
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

