; ------------------------------
;      OS Global Constants
;        Oliver Harris
;
;  Last Modified: 06/03/2026
;
; -----------------------------

MSTACK_SIZE                 EQU 32 * 4         ; 32 words
USER_BASE_ADDRESS           EQU 0x0004_0000    ; (65,536 words)
ECALL_MAX                   EQU 6              ; number of supported ecalls

; --- HARDWARE ---
HARDWARE_BASE_ADDRESS       EQU 0x0001_0000

; LED + Buttons
OFFSET_LED                  EQU 0x0            ; (8 bits; redundant but improves readability)
OFFSET_BUTTONS              EQU 0x1            ; (4 bits)
MASK_BUTTON_1               EQU 0b0001
MASK_BUTTON_2               EQU 0b0010
MASK_BUTTON_3               EQU 0b0100
MASK_BUTTON_4               EQU 0b1000

; LCD
OFFSET_LCD_BUS              EQU 0x100          ; (8 bits)
OFFSET_LCD_STATUS           EQU 0x101          ; (4 bits)
DELAY_PULSE                 EQU 5              ; pulse width delay (>= 20 cycles)
DELAY_SEPARATE              EQU 12             ; separate pulses (>= 48 cycles)

; TIMER
OFFSET_TIMER_COUNTER        EQU 0x200          ; Counter value (32 bits)
OFFSET_TIMER_MODULUS        EQU 0x204          ; Modulus -1 (32 bits)
OFFSET_TIMER_STATUS         EQU 0x20C          ; Control Status (32 bits)
OFFSET_TIMER_CLEAR          EQU 0x210          ; Control Clear (32 bits)
OFFSET_TIMER_SET            EQU 0x214          ; Control Set (32 bits)

TIMER_COMPARE_FLAG          EQU 0x1F           ; (bit 31)
TIMER_TERMINAL_COUNT_CLR    EQU 0x10           ; Clear terminal count (bit 4)
TIMER_ENABLE_FLAG           EQU 0x1            ; Timer enable = bit 0

TIMER_TICKS_PER_SEC         EQU 1_000_000      ; Number of timer ticks per second
TIMER_INIT_FREE_RUNNING     EQU 0x3            ; Enabled, free running, modulus, no interrupt
