; CEDIT: Commodore-128 character editor
;
; asmsyntax=asm68k  (6502/8502 ASM, but better syntax highlighting in vim)
.include "c128_mmap.inc"

; Zero-page registers
SCR_ROW = $FB

.org $1C01              ; Default for c128-asm in cl65 config
.segment "STARTUP"
.segment "INIT"
.segment "CODE"

main:
    cld                 ; No BCD operations at all
    lda MMUCR           ; Indicate memory bank as sanity check (for den)
    sta VICSCN+39       ; At the top right of the screen

    lda #>(VICSCN)      ; Load VIC text screen pointer into ZP register
    sta SCR_ROW+1
    lda #<(VICSCN)      ; Loading LO byte last leaves A loaded for prchar
    sta SCR_ROW

    tay                 ; prchar init: Y = A = 00
prchar:                 ; Display 16 rows (of 16 chars) for 256 chars
    sta (SCR_ROW),y
    adc #$01
    cmp #$00            ; Have we printed 256 chars?
    beq done
    iny
    cpy #$10            ; Have we hit 16 chars on this row?
    bne prchar
    pha                 ; Save next character
    jsr nextline
    pla                 ; A = next character
    ldy #$00            ; Y = column 0 on current row
    jmp prchar
done:
    rts

nextline:
    clc
    lda #40             ; Skip one row of characters in VIC screen memory
    adc SCR_ROW
    sta SCR_ROW
    lda #$00            ; No HI byte for 8bit addend
    adc SCR_ROW+1       ; Carry bit -> HI byte of screen location pointer
    sta SCR_ROW+1
    rts

