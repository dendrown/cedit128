; CEDIT: Commodore-128 character editor
;
; asmsyntax=asm68k  (6502/8502 ASM, but better syntax highlighting in vim)
.include "c128.inc"         ; cc65 definitions [origin: Elite128]
.include "c128_mmap.inc"    ; More definitions needed for this project

; Zero-page registers
SCR_ROW = $FB               ; Current display row

; Constants
VIC_ROW_CSET = VICSCN+(9*40); Character set on 10th row

.org $1C01                  ; Default for c128-asm in cl65 config
                            ; (why not $1C00?)
.segment "STARTUP"
.segment "INIT"
.segment "CODE"

main:
    cld                     ; No BCD operations at all
    lda MMU_CR              ; Indicate memory bank for comparison with cc65 C
    sta VICSCN+39           ; At the top right of the screen

    lda #<(VIC_ROW_CSET)    ; Load VIC text screen pointer into ZP register
    sta SCR_ROW
    lda #>(VIC_ROW_CSET)
    sta SCR_ROW+1

; Display 16 rows (of 16 chars) for 256 chars
    lda #$00                ; init: Y = A = 00
    tay
prchar:
    sta (SCR_ROW),y         ; Print current char (A) at column Y
    adc #$01
    cmp #$00                ; Have we printed 256 chars?
    beq done
    iny
    cpy #$10                ; Have we hit 16 chars on this row?
    bne prchar
    pha                     ; Save next character
    jsr nextline
    pla                     ; A = next character
    ldy #$00                ; Y = column 0 on current row
    jmp prchar
done:
    rts

nextline:
    clc
    lda #40                 ; Skip one row of characters in VIC screen memory
    adc SCR_ROW
    sta SCR_ROW
    lda #$00                ; No HI byte for 8bit addend
    adc SCR_ROW+1           ; Carry bit -> HI byte of screen location pointer
    sta SCR_ROW+1
    rts

