# SNES Cyber Mario Makefile
# Requires: ca65 + ld65 from cc65 suite

CA65 = ca65
LD65 = ld65
ROM  = cybermario.sfc

# CPU and include path
CAFLAGS = --cpu 65816 -I include

# Source files
SRC_ASM = \
	src/ram.asm \
	src/header.asm \
	src/init.asm \
	src/main.asm \
	src/joypad.asm \
	src/mario.asm \
	src/physics.asm \
	src/collision.asm \
	src/camera.asm \
	src/level.asm \
	src/sprites.asm \
	src/dma.asm \
	src/tiles.asm \
	src/items.asm \
	src/hud.asm \
	data/palettes.asm \
	data/bg_tiles.asm \
	data/sprite_tiles.asm \
	data/metatiles.asm \
	data/level_1_1.asm \
	data/level_blocks.asm \
	data/hud_tiles.asm

# Object files (replace .asm with .o)
OBJ = $(SRC_ASM:.asm=.o)

.PHONY: all clean run

all: $(ROM)

$(ROM): $(OBJ) ld65.cfg
	$(LD65) -C ld65.cfg -o $@ $(OBJ)

%.o: %.asm
	$(CA65) $(CAFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) $(ROM)

run: $(ROM)
	/c/snes9x/snes9x-x64.exe $(ROM) &
