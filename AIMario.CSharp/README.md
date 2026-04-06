# AIMario - C# MonoGame Port

A cyberpunk-themed Super Mario Bros clone built with .NET 9 and MonoGame. All sprites are procedurally generated -- no image assets required.

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) (or newer)
- [Visual Studio Code](https://code.visualstudio.com/)
- [C# Dev Kit extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit) for VS Code

## Building and Running

### From the terminal

```bash
cd AIMario.CSharp
dotnet restore
dotnet run
```

### From VS Code

1. Open the `AIMario.CSharp` folder in VS Code
2. When prompted, install recommended extensions (C# Dev Kit)
3. Press **Ctrl+Shift+B** to build, or **F5** to build and run with debugging
4. If no launch configuration exists, create one:
   - Open the Command Palette (**Ctrl+Shift+P**)
   - Select **Debug: Add Configuration...**
   - Choose **.NET: Launch Executable** and point it to `bin/Debug/net9.0/AIMario.CSharp.exe`

Alternatively, use the integrated terminal and run `dotnet run`.

## Controls

| Action       | Key                    |
|--------------|------------------------|
| Move left    | Left arrow             |
| Move right   | Right arrow            |
| Duck / Pipe  | Down arrow             |
| Jump         | Z or Space             |
| Run / Fire   | X or Left Shift        |
| Start        | Enter                  |
| Quit         | Escape                 |

## Project Structure

```
AIMario.CSharp/
  Audio/            Audio manager
  Core/             Constants, camera, game state
  Entities/         Mario, enemies, items, fireballs
  Graphics/         Procedural sprite generation, animation
  Input/            Keyboard/gamepad input handling
  Level/            Level loading, data, and game logic
  Physics/          Collision detection and physics bodies
  Tiles/            Tile types and tile state
  UI/               HUD and title screen
  Program.cs        Entry point
  MarioGame.cs      Main game class (MonoGame Game subclass)
```

## Technical Details

- **Resolution:** 256x240 (NES native), scaled 3x to 768x720
- **Framework:** .NET 9, MonoGame 3.8 (DesktopGL)
- **Rendering:** All sprites generated at startup via `SpriteGenerator`, drawn to a 256x240 render target then scaled to the window
- **Physics:** 2-pass collision system (X then Y) at 60 FPS fixed timestep
