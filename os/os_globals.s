; ------------------------------
;      OS Global Constants
;        Oliver Harris
;
;  Last Modified: 02/03/2026
;
; -----------------------------

MSTACK_SIZE              EQU 32 * 4         ; 32 words
USER_BASE_ADDRESS        EQU 0x0004_0000    ; (65,536 words)
ECALL_MAX                EQU 1              ; number of supported ecalls

; --- HARDWARE ---
HARDWARE_BASE_ADDRESS    EQU 0x0001_0000

; LED + Buttons
OFFSET_LED               EQU 0x0            ; (8 bits; redundant but improves readability)
OFFSET_BUTTONS           EQU 0x1            ; (4 bits)

; LCD
OFFSET_LCD_BUS           EQU 0x100          ; (8 bits)
OFFSET_LCD_STATUS        EQU 0x101          ; (4 bits)
DELAY_PULSE              EQU 5              ; pulse width delay (>= 20 cycles)
DELAY_SEPARATE           EQU 12             ; separate pulses (>= 48 cycles)
