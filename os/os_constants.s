; -----------------------------
;          OS Constants
;          Oliver Harris
;
;  Last Modified: 02/03/2026
;
; -----------------------------

HARDWARE_BASE_ADDRESS    EQU 0x0001_0000
OFFSET_LED               EQU 0x0            ; (8 bits; redundant but improves readability)
OFFSET_BUTTONS           EQU 0x1            ; (4 bits)
OFFSET_LCD               EQU 0x100

USER_BASE_ADDRESS        EQU 0x0004_0000    ; (65,536 words)
