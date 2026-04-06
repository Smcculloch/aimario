; =============================================================================
; SNES ROM Header + Interrupt Vectors
; =============================================================================

.include "registers.inc"
.include "constants.inc"

.import NMI_Handler, Reset_Handler

; =============================================================================
; ROM Header at $00FFC0
; =============================================================================
.segment "HEADER"

;              1234567890123456789012
.byte "CYBER MARIO SECTOR 1"  ; $FFC0: Game title (21 bytes, space-padded)
.byte " "                     ; pad to 21
.byte $20                     ; $FFD5: Map mode (LoROM, no FastROM)
.byte $00                     ; $FFD6: Cartridge type (ROM only)
.byte $09                     ; $FFD7: ROM size (2^9 = 512 KB... we use 128K but round up)
.byte $00                     ; $FFD8: RAM size (0 = no SRAM)
.byte $01                     ; $FFD9: Country (North America)
.byte $00                     ; $FFDA: Developer ID
.byte $00                     ; $FFDB: ROM version
.word $0000                   ; $FFDC: Complement checksum (filled by tool)
.word $0000                   ; $FFDE: Checksum (filled by tool)

; =============================================================================
; Interrupt Vectors (Native mode) at $FFE0
; =============================================================================
.segment "VECTORS"

; Native mode vectors ($FFE0-$FFEF) - unused ones point to dummy
.word $0000                   ; $FFE0: unused
.word $0000                   ; $FFE2: unused
.word $0000                   ; $FFE4: COP
.word $0000                   ; $FFE6: BRK
.word $0000                   ; $FFE8: ABORT
.word .loword(NMI_Handler)    ; $FFEA: NMI (VBlank)
.word $0000                   ; $FFEC: unused
.word $0000                   ; $FFEE: IRQ

; Emulation mode vectors ($FFF0-$FFFF)
.word $0000                   ; $FFF0: unused
.word $0000                   ; $FFF2: unused
.word $0000                   ; $FFF4: COP
.word $0000                   ; $FFF6: unused
.word $0000                   ; $FFF8: ABORT
.word $0000                   ; $FFFA: NMI (emulation)
.word .loword(Reset_Handler)  ; $FFFC: RESET
.word $0000                   ; $FFFE: IRQ/BRK
