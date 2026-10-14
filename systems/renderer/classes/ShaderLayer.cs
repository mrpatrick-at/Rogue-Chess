using System;
using Godot;

namespace Chess.systems.renderer.classes;

public sealed class ShaderLayer {
    public Rid Item { get; private set; }
    public Rid Material { get; private set; }

    // Creation Func
    public ShaderLayer(
        CanvasItem Parent,
        Shader LayerShader,
        Rect2 SizeRect,
        int DrawIndex = 0
    ) {
        Item = RenderingServer.CanvasItemCreate();

        RenderingServer.CanvasItemSetParent(
            Item,
            Parent.GetCanvasItem()
        );

        // Apply the Given Shader to the CanvasItem
        Material = RenderingServer.MaterialCreate();

        RenderingServer.MaterialSetShader(
            Material,
            LayerShader.GetRid()
        );

        RenderingServer.CanvasItemSetMaterial(
            Item,
            Material
        );

        // Set the z Index of the CanvasItem
        RenderingServer.CanvasItemSetDrawIndex(
            Item,
            DrawIndex
        );

        // Add a Surface Area to the CanvasItem
        RenderingServer.CanvasItemAddRect(
            Item,
            SizeRect,
            Colors.White
        );
    }

    // --- Public Funcs ---
    public void SetShaderParameter(String Name, Variant Value) {
        RenderingServer.MaterialSetParam(
            Material,
            Name,
            Value
        );
    }

    public void Free() {
        if (Item.IsValid) {
            RenderingServer.FreeRid(Item);
            Item = new Rid();
        }

        if (Material.IsValid) {
            RenderingServer.FreeRid(Material);
            Material = new Rid();
        }
    }
}
