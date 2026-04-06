; =============================================================================
; SNES Hardware Register Definitions
; =============================================================================

; --- PPU Registers ---
INIDISP     = $2100    ; Display control (brightness + force blank)
OBSEL       = $2101    ; Object size and base address
OAMADDL     = $2102    ; OAM address low
OAMADDH     = $2103    ; OAM address high
OAMDATA     = $2104    ; OAM data write
BGMODE      = $2105    ; BG mode and character size
MOSAIC      = $2106    ; Mosaic settings
BG1SC       = $2107    ; BG1 tilemap address and size
BG2SC       = $2108    ; BG2 tilemap address and size
BG3SC       = $2109    ; BG3 tilemap address and size
BG4SC       = $210A    ; BG4 tilemap address and size
BG12NBA     = $210B    ; BG1/BG2 character base address
BG34NBA     = $210C    ; BG3/BG4 character base address
BG1HOFS     = $210D    ; BG1 horizontal scroll
BG1VOFS     = $210E    ; BG1 vertical scroll
BG2HOFS     = $210F    ; BG2 horizontal scroll
BG2VOFS     = $2110    ; BG2 vertical scroll
BG3HOFS     = $2111    ; BG3 horizontal scroll
BG3VOFS     = $2112    ; BG3 vertical scroll
VMAIN       = $2115    ; VRAM address increment mode
VMADDL      = $2116    ; VRAM address low
VMADDH      = $2117    ; VRAM address high
VMDATAL     = $2118    ; VRAM data write low
VMDATAH     = $2119    ; VRAM data write high
M7SEL       = $211A    ; Mode 7 settings
CGADD       = $2121    ; CGRAM address
CGDATA      = $2122    ; CGRAM data write
W12SEL      = $2123    ; Window mask settings BG1/BG2
W34SEL      = $2124    ; Window mask settings BG3/BG4
WOBJSEL     = $2125    ; Window mask settings OBJ/Color
WH0         = $2126    ; Window 1 left position
WH1         = $2127    ; Window 1 right position
WH2         = $2128    ; Window 2 left position
WH3         = $2129    ; Window 2 right position
WBGLOG      = $212A    ; Window mask logic BG
WOBJLOG     = $212B    ; Window mask logic OBJ/Color
TM          = $212C    ; Main screen designation
TS          = $212D    ; Sub screen designation
TMW         = $212E    ; Window mask main screen
TSW         = $212F    ; Window mask sub screen
CGWSEL      = $2130    ; Color addition select
CGADSUB     = $2131    ; Color math designation
COLDATA     = $2132    ; Fixed color data
SETINI      = $2133    ; Screen mode / video select

; --- DMA Registers ---
MDMAEN      = $420B    ; DMA enable
HDMAEN      = $420C    ; HDMA enable
; DMA channel 0
DMAP0       = $4300    ; DMA parameters
BBAD0       = $4301    ; DMA B-bus address
A1T0L       = $4302    ; DMA source address low
A1T0H       = $4303    ; DMA source address high
A1B0        = $4304    ; DMA source bank
DAS0L       = $4305    ; DMA size low
DAS0H       = $4306    ; DMA size high
; DMA channel 1
DMAP1       = $4310
BBAD1       = $4311
A1T1L       = $4312
A1T1H       = $4313
A1B1        = $4314
DAS1L       = $4315
DAS1H       = $4316
; DMA channel 7 (for OAM)
DMAP7       = $4370
BBAD7       = $4371
A1T7L       = $4372
A1T7H       = $4373
A1B7        = $4374
DAS7L       = $4375
DAS7H       = $4376

; --- CPU Registers ---
NMITIMEN    = $4200    ; Interrupt enable
HTIMEL      = $4207    ; H-count timer low
HTIMEH      = $4208    ; H-count timer high
VTIMEL      = $4209    ; V-count timer low
VTIMEH      = $420A    ; V-count timer high
RDNMI       = $4210    ; NMI flag / CPU version
TIMEUP      = $4211    ; IRQ flag
HVBJOY      = $4212    ; PPU status (h/v blank, joypad ready)
JOY1L       = $4218    ; Joypad 1 data low
JOY1H       = $4219    ; Joypad 1 data high
JOY2L       = $421A    ; Joypad 2 data low
JOY2H       = $421B    ; Joypad 2 data high

; --- Math Registers ---
WRMPYA      = $4202    ; Multiplicand A
WRMPYB      = $4203    ; Multiplicand B
WRDIVL      = $4204    ; Dividend low
WRDIVH      = $4205    ; Dividend high
WRDIVB      = $4206    ; Divisor
RDDIVL      = $4214    ; Quotient low
RDDIVH      = $4215    ; Quotient high
RDMPYL      = $4216    ; Product / remainder low
RDMPYH      = $4217    ; Product / remainder high

MEMSEL      = $420D    ; ROM access speed
