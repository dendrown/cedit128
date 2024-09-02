; Commodore-128 definitions
;
; asmsyntax=asm68k  (6502/8502 ASM, but better syntax highlighting in vim)
.ifndef __C128_INC              ; FIXME: build off cc65/asminc/c128.inc
__C128_INC = 1

; C128 memory map
VICSCN  = $0400     ; VIC 40-col text screen
MMUCR   = $FF00     ; Memory configuration register

.endif
