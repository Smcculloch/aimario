# AIMario SNES V2 — Build Guide

SNES assembly port of Cyber Mario using the **ca65/ld65** toolchain (from cc65).
Outputs a LoROM 128KB `.sfc` ROM.

## Prerequisites

- **cc65 toolchain** installed at `C:\cc65\bin\` (needs `ca65.exe` and `ld65.exe`)
  - Download from https://cc65.github.io/
- **VS Code** with a terminal (Git Bash recommended)

## Building from VS Code

Open a terminal in VS Code (**Ctrl+`**), `cd` into this folder, and run:

### 1. Assemble all source files

```bash
CA65=/c/cc65/bin/ca65

$CA65 --cpu 65816 -I include -o src/ram.o        src/ram.asm
$CA65 --cpu 65816 -I include -o src/header.o     src/header.asm
$CA65 --cpu 65816 -I include -o src/init.o       src/init.asm
$CA65 --cpu 65816 -I include -o src/main.o       src/main.asm
$CA65 --cpu 65816 -I include -o src/joypad.o     src/joypad.asm
$CA65 --cpu 65816 -I include -o src/mario.o      src/mario.asm
$CA65 --cpu 65816 -I include -o src/physics.o    src/physics.asm
$CA65 --cpu 65816 -I include -o src/collision.o  src/collision.asm
$CA65 --cpu 65816 -I include -o src/camera.o     src/camera.asm
$CA65 --cpu 65816 -I include -o src/level.o      src/level.asm
$CA65 --cpu 65816 -I include -o src/sprites.o    src/sprites.asm
$CA65 --cpu 65816 -I include -o src/dma.o        src/dma.asm
$CA65 --cpu 65816 -I include -o src/hud.o        src/hud.asm
$CA65 --cpu 65816 -I include -o src/tiles.o      src/tiles.asm
$CA65 --cpu 65816 -I include -o data/palettes.o     data/palettes.asm
$CA65 --cpu 65816 -I include -o data/bg_tiles.o     data/bg_tiles.asm
$CA65 --cpu 65816 -I include -o data/sprite_tiles.o data/sprite_tiles.asm
$CA65 --cpu 65816 -I include -o data/metatiles.o    data/metatiles.asm
$CA65 --cpu 65816 -I include -o data/level_1_1.o    data/level_1_1.asm
$CA65 --cpu 65816 -I include -o data/hud_tiles.o    data/hud_tiles.asm
```

### 2. Link into a ROM

```bash
/c/cc65/bin/ld65 -C ld65.cfg -o aimario_v2.sfc \
  src/ram.o src/header.o src/init.o src/main.o \
  src/joypad.o src/mario.o src/physics.o src/collision.o \
  src/camera.o src/level.o src/sprites.o src/dma.o \
  src/hud.o src/tiles.o \
  data/palettes.o data/bg_tiles.o data/sprite_tiles.o \
  data/metatiles.o data/level_1_1.o data/hud_tiles.o
```

This produces `aimario_v2.sfc`.

### Quick rebuild (one-liner)

If you only changed a single file (e.g. `data/palettes.asm`), you can reassemble just that file and re-link:

```bash
/c/cc65/bin/ca65 --cpu 65816 -I include -o data/palettes.o data/palettes.asm && \
/c/cc65/bin/ld65 -C ld65.cfg -o aimario_v2.sfc \
  src/ram.o src/header.o src/init.o src/main.o \
  src/joypad.o src/mario.o src/physics.o src/collision.o \
  src/camera.o src/level.o src/sprites.o src/dma.o \
  src/hud.o src/tiles.o \
  data/palettes.o data/bg_tiles.o data/sprite_tiles.o \
  data/metatiles.o data/level_1_1.o data/hud_tiles.o
```

### VS Code task (optional)

To add a **Ctrl+Shift+B** build shortcut, create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build SNES ROM",
      "type": "shell",
      "command": "bash",
      "args": ["-c", "CA65=/c/cc65/bin/ca65; for f in src/*.asm data/*.asm; do $CA65 --cpu 65816 -I include -o ${f%.asm}.o $f || exit 1; done && /c/cc65/bin/ld65 -C ld65.cfg -o aimario_v2.sfc src/ram.o src/header.o src/init.o src/main.o src/joypad.o src/mario.o src/physics.o src/collision.o src/camera.o src/level.o src/sprites.o src/dma.o src/hud.o src/tiles.o data/palettes.o data/bg_tiles.o data/sprite_tiles.o data/metatiles.o data/level_1_1.o data/hud_tiles.o"],
      "group": { "kind": "build", "isDefault": true },
      "problemMatcher": []
    }
  ]
}
```

## Running

Open `aimario_v2.sfc` in any SNES emulator (bsnes, Mesen, snes9x, etc.).

## Project Layout

```
include/          Header files (.inc) — constants, register maps, macros, RAM defs
src/              Code — game logic, physics, rendering, I/O
data/             Data — palettes, tile graphics, level map, metatile defs
ld65.cfg          Linker config (LoROM, 4 banks)
aimario_v2.sfc    Output ROM
```
