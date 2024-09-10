; CEDIT: Commodore-128 character editor
;
; asmsyntax=asm68k  (6510/8502 ASM, but better syntax highlighting in vim)
;-----------------------------------------------------------------------------
.include "c128.inc"         ; cc65 definitions [origin: Elite128]
.include "c128_mmap.inc"    ; More definitions needed for this project

; Zero-page registers
ZP_SCN_ROW = $FB            ; Current display row

; Constants
VIC_ROW_CSET = 8            ; Character set on 9th row (starting at 0)

.macro set_vic_row row
    addr .set VICSCN+(row*40)
    lda #<(addr)            ; Load VIC text screen pointer into ZP register
    sta ZP_SCN_ROW
    lda #>(addr)
    sta ZP_SCN_ROW+1
.endmacro

.macro sta_vic row,col
    sta VICSCN+(row*40)+col
.endmacro

.macro sta_vic_code row,col,code
    lda #code
    sta_vic (row,col)
.endmacro

;-----------------------------------------------------------------------------
.org $1C01                  ; Default for c128-asm in cl65 config
                            ; (why not $1C00?)
.segment "STARTUP"
.segment "INIT"
.segment "CODE"

main:
    cld                     ; No BCD operations at all
    lda MMU_CR              ; Indicate memory bank for comparison with cc65 C
    sta VICSCN+40+38        ; At the top right of the screen
    jsr frame               ; Draw border & cut out screen regions for work
    set_vic_row(VIC_ROW_CSET)

; Display 16 rows (of 16 chars) for 256 chars
    lda #$00                ; A <- screen display code (character)
    ldy #$01                ; Y <- column to print character
prt_char:
    sta (ZP_SCN_ROW),y      ; Print current char (A) at column Y
    adc #$01                ; Next character
    beq done
    iny
    cpy #$10+1              ; Have we hit 16 chars (plus 1 for the border)
    bne prt_char
    pha                     ; Save next character
    jsr next_row
    pla                     ; A = next character
    ldy #$01                ; Y = column 1 on new row
    jmp prt_char
done:
    rts

next_row:
    clc
    lda #40                 ; Skip one row of characters in VIC screen memory
    adc ZP_SCN_ROW
    sta ZP_SCN_ROW
    lda #$00                ; No HI byte for 8bit addend
    adc ZP_SCN_ROW+1        ; Carry bit -> HI byte of screen location pointer
    sta ZP_SCN_ROW+1
    rts

;-----------------------------------------------------------------------------
frame:
    set_vic_row(0)          ; Top row of screen
    jsr prt_frame_h_full

    ldx #23                 ; 23 rows (skipping top and bottom)
prt_frame_sides:
    jsr next_row
    lda #C_VLINE
    jsr prt_frame_v
    dex
    bne prt_frame_sides

    ; Box off character set display
    set_vic_row(VIC_ROW_CSET-1)
    jsr prt_frame_h_full

    set_vic_row(VIC_ROW_CSET)
    ldx #24-VIC_ROW_CSET    ; rows from character block down to bottom but 1
    ldy #1+16               ; border + characters
prt_char_frame_v:           ; Print vertical frame section
    lda #C_VLINE
    sta (ZP_SCN_ROW),y
    jsr next_row
    dex
    bne prt_char_frame_v

    set_vic_row(24)         ; Bottom of screen
    lda #C_HLINE
    jsr prt_frame_h_full

    ; Print corners
    sta_vic_code 00,00,C_NW_CNR
    sta_vic_code 00,39,C_NE_CNR
    sta_vic_code 24,00,C_SW_CNR
    sta_vic_code 24,39,C_SE_CNR

    ; Print T-joints
    sta_vic_code (VIC_ROW_CSET-1),00,C_R_TEE
    sta_vic_code (VIC_ROW_CSET-1),39,C_L_TEE
    sta_vic_code (VIC_ROW_CSET-1),17,C_DN_TEE
    rts

prt_frame_h_full:           ; Print horizontal frame
    lda #C_HLINE
    ldy #38                 ; Start at end of row and work back to beginning
prt_frame_h:
    sta (ZP_SCN_ROW),y
    dey
    bne prt_frame_h
    rts

prt_frame_v:                ; Print vertical frame section
    ldy #0
    sta (ZP_SCN_ROW),y
    ldy #39
    sta (ZP_SCN_ROW),y
    rts




