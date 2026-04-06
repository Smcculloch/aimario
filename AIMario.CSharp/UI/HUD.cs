using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Graphics;

namespace AIMario.UI;

public class HUD
{
    private SpriteGenerator _sprites;

    private static readonly Color HudWhite = new(252, 252, 252);
    private static readonly Color HudGold = new(248, 184, 0);

    public HUD(SpriteGenerator sprites)
    {
        _sprites = sprites;
    }

    public void Draw(SpriteBatch sb, Level.Level level)
    {
        float scale = 1f;
        float y = 8;

        // MARIO
        DrawText(sb, "MARIO", 24, y, scale, HudWhite);
        DrawText(sb, level.Score.ToString("D6"), 24, y + 10, scale, HudWhite);

        // Coins
        DrawText(sb, "x" + level.Coins.ToString("D2"), 96, y + 10, scale, HudGold);

        // WORLD
        DrawText(sb, "WORLD", 144, y, scale, HudWhite);
        DrawText(sb, "1-1", 152, y + 10, scale, HudWhite);

        // TIME
        DrawText(sb, "TIME", 200, y, scale, HudWhite);
        DrawText(sb, ((int)level.Timer).ToString("D3"), 208, y + 10, scale, HudWhite);
    }

    private void DrawText(SpriteBatch sb, string text, float x, float y, float scale, Color color)
    {
        float cx = x;
        foreach (char c in text.ToUpper())
        {
            string key = "font_" + c;
            if (_sprites.Textures.ContainsKey(key))
            {
                sb.Draw(_sprites.Textures[key], new Vector2(cx, y),
                    null, color, 0f, Vector2.Zero, scale, SpriteEffects.None, 0f);
            }
            cx += 6 * scale;
        }
    }
}
