using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;

namespace AIMario.UI;

public class TitleScreen
{
    private SpriteGenerator _sprites;
    private float _blinkTimer;
    private float _glitchTimer;

    public TitleScreen(SpriteGenerator sprites)
    {
        _sprites = sprites;
    }

    public void Update(float dt)
    {
        _blinkTimer += dt;
        _glitchTimer += dt;
    }

    public void Draw(SpriteBatch sb)
    {
        Color titleRed = new(200, 36, 0);
        Color titleWhite = new(252, 252, 252);

        // Shadow layer
        DrawText(sb, "SUPER", 81, 51, 2f, new Color(0, 0, 0, 80));
        DrawText(sb, "MARIO BROS", 45, 76, 2f, new Color(0, 0, 0, 80));

        // Main title
        DrawText(sb, "SUPER", 80, 50, 2f, titleRed);
        DrawText(sb, "MARIO BROS", 44, 75, 2f, titleWhite);

        // Subtitle
        DrawText(sb, "WORLD 1-1", 89, 120, 1f, new Color(248, 184, 0));

        // Blinking prompt
        float flicker = ((int)(_blinkTimer * 3)) % 2 == 0 ? 1f : 0f;
        if (flicker > 0)
        {
            DrawText(sb, "PRESS ENTER", 74, 170, 1f, titleWhite * flicker);
        }

        // Credits
        DrawText(sb, "A FAITHFUL RECREATION", 38, 210, 1f, new Color(188, 188, 188));
    }

    private void DrawText(SpriteBatch sb, string text, float x, float y, float scale, Color? color = null)
    {
        Color c = color ?? Color.White;
        float cx = x;
        foreach (char ch in text.ToUpper())
        {
            string key = "font_" + ch;
            if (_sprites.Textures.ContainsKey(key))
            {
                sb.Draw(_sprites.Textures[key], new Vector2(cx, y),
                    null, c, 0f, Vector2.Zero, scale, SpriteEffects.None, 0f);
            }
            cx += 6 * scale;
        }
    }
}
