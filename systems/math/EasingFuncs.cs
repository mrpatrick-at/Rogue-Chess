using System;

namespace Chess.systems.math;
public static class EasingFuncs {
    public static float EaseOutCubic(float x) {
        return 1F - MathF.Pow(1 - x, 3);
    }
}
