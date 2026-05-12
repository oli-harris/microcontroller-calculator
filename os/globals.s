; ------------------------------
;      OS Global Constants
;        Oliver Harris
;
;  Last Modified: 08/05/2026
;
; -----------------------------

MSTACK_SIZE                    EQU 64                                    ; 64 words
USER_BASE_ADDRESS              EQU 0x0004_0000                           ; (65,536 words)

; --- CSR Bits ---
MSTATUS_MPP_MACHINE            EQU 0x1800                                ; MPP bits (bits 12 & 11)
MSTATUS_MIE                    EQU 0x8                                   ; Machine Interrupt Enable (bit 3)
MIE_EXTERNAL                   EQU 0x800                                 ; External Interrupt Enable (bit 11)

; --- ECALLS ---
ECALL_LCD_WRITE                EQU 0
ECALL_SET_LEDS                 EQU 1
ECALL_CHANGED_BUTTONS          EQU 2
ECALL_GET_KEY                  EQU 3
ECALL_PLAY_SOUND               EQU 4

; --- HARDWARE ---
HARDWARE_BASE_ADDRESS          EQU 0x0001_0000

; LED + Buttons
OFFSET_LED                     EQU 0x0                                   ; (8 bits; redundant but improves readability)
OFFSET_BUTTONS                 EQU 0x1                                   ; (4 bits)
MASK_BUTTON_1                  EQU 0b0001
MASK_BUTTON_2                  EQU 0b0010
MASK_BUTTON_3                  EQU 0b0100
MASK_BUTTON_4                  EQU 0b1000

LEDS_RAINBOW                   EQU 0b1111
LEDS_RED                       EQU 0b0001
LEDS_ORANGE                    EQU 0b0010
LEDS_GREEN                     EQU 0b0100
LEDS_BLUE                      EQU 0b1000
LEDS_RIGHT                     EQU 4

; LCD
OFFSET_LCD_BUS                 EQU 0x100                                 ; (8 bits)
OFFSET_LCD_STATUS              EQU 0x101                                 ; (4 bits)
DELAY_PULSE                    EQU 5                                     ; pulse width delay (>= 20 cycles)
DELAY_SEPARATE                 EQU 12                                    ; separate pulses (>= 48 cycles)

LCD_RW                         EQU 0b0000_0001                           ; R/W = 1 for read, 0 for write
LCD_RS                         EQU 0b0000_0010                           ; RS
LCD_ENABLE_BUS                 EQU 0b0000_0100                           ; E = 1 to enable bus
LCD_BUSY_FLAG                  EQU 0b1000_0000                           ; Busy flag (bit 7 of status)

LCD_CMD_LEFT                   EQU 0x110                                 ; Backspace
LCD_CMD_RIGHT                  EQU 0x114                                 ; Tab
LCD_CMD_NEWLINE                EQU 0x1C0                                 ; Line feed (down line)
LCD_CMD_VTAB                   EQU 0x180                                 ; Vertical tab (up line)
LCD_CMD_CLEAR                  EQU 0x101                                 ; Form feed (clear display, reset cursor)


; TIMER
OFFSET_TIMER_COUNTER           EQU 0x200                                 ; Counter value (32 bits)
OFFSET_TIMER_MODULUS           EQU 0x204                                 ; Modulus -1 (32 bits)
OFFSET_TIMER_STATUS            EQU 0x20C                                 ; Control Status (32 bits)
OFFSET_TIMER_CLEAR             EQU 0x210                                 ; Control Clear (32 bits)
OFFSET_TIMER_SET               EQU 0x214                                 ; Control Set (32 bits)

TIMER_COMPARE_FLAG             EQU 0x1F                                  ; (bit 31)
TIMER_TERMINAL_COUNT_CLR       EQU 0x10                                  ; Clear terminal count (bit 4)
TIMER_INTERRUPT_FLAG           EQU 0x8                                   ; Interrupt flag (bit 3)
TIMER_ENABLE_FLAG              EQU 0x1                                   ; Enable timer (bit 0)

TIMER_TICKS_PER_SEC            EQU 1_000_000                             ; Number of timer ticks per second
TIMER_INIT_VALUE               EQU 0xB                                   ; Enabled, Modulus, Free Running, Interrupts Disabled

TIMER_TICK_MS                  EQU 1 * ( TIMER_TICKS_PER_SEC / 1000 )    ; Number of timer ticks per ms

; PARALLEL INPUT OUTPUT
OFFSET_PIO_DATA                EQU 0x300                                 ; (32 bits)
OFFSET_PIO_DIRECTION           EQU 0x304                                 ; Pin direction {'0' = output, '1' = input} (32 bits)
OFFSET_PIO_CLEAR               EQU 0x308                                 ; Atomic clear bits (32 bits)
OFFSET_PIO_SET                 EQU 0x30C                                 ; Atomic set bits (32 bits)

; KEYBOARD
KEYBOARD_DIRECTIONS            EQU ~MASK_KEYBOARD_ROWS                   ; Set rows as output and columns as input
MASK_KEYBOARD_ROWS             EQU 0xF00                                 ; Mask for keyboard rows (bits 8-11)
MASK_KEYBOARD_COLUMNS          EQU 0xF000                                ; Mask for keyboard columns (bits 12-15)

KEYBOARD_ROWS                  EQU 4                                     ; 4 rows to read
KEYBOARD_ROW_START             EQU 0x100                                 ; Row 1 (bit 8)

KEYBOARD_COLUMNS               EQU 4                                     ; 4 columns to read

; SYSTEM CONTRLLER
OFFSET_PINMUX                  EQU 0x708                                 ; Pin mux control (32 bits)
PIZO_ENABLE_BITS               EQU 0xC0                                  ; Enable bits for piezo (bits 6 and 7)

; USER PERIPHERALS
USER_PERIPHERAL_BASE           EQU 0x0002_0000                           ; Base address for user peripherals

; BUZZER
OFFSET_BUZZER                  EQU 0                                     ; Offset for buzzer (bit 0: enable, bits 1-5: pitch)

; EXTERNAL INTERRUPTS
MASK_INTERRUPT_USER1           EQU 0x01                                  ; (bit 0)
MASK_INTERRUPT_USER2           EQU 0x02                                  ; (bit 1)
MASK_INTERRUPT_USER3           EQU 0x04                                  ; (bit 2)
MASK_INTERRUPT_USER4           EQU 0x08                                  ; (bit 3)
MASK_INTERRUPT_TIMER           EQU 0x10                                  ; Timer reached terminal count (bit 4)
MASK_INTERRUPT_BUTTON          EQU 0x20                                  ; Top left button pressed (bit 5)
MASK_INTERRUPT_VIDEO1          EQU 0x40                                  ; Display vertical sync (bit 6)
MASK_INTERRUPT_VIDEO2          EQU 0x80                                  ; (bit 7)
MASK_INTERRUPT_SERIAL_TX       EQU 0x100                                 ; Serial available for writing (bit 8)
MASK_INTERRUPT_SERIAL_RX       EQU 0x200                                 ; Serial has byte(s) waiting (bit 9)
MASK_INTERRUPT_SERIAL_ERROR    EQU 0x400                                 ; Serial has overrun error (bit 10)

; INTERRUPT CONTROLLER
OFFSET_INTERRUPT_INPUT         EQU 0x400                                 ; RO Raw signal (32 bits)
OFFSET_INTERRUPT_ENABLE        EQU 0x404                                 ; RW enable masks per input (32 bits)
OFFSET_INTERRUPT_REQUESTS      EQU 0x408                                 ; RO pending bits  (32 bits)
OFFSET_INTERRUPT_MODE          EQU 0x40C                                 ; RW per input 0 = level, 1 = edge-sticky (32 bits)
OFFSET_INTERRUPT_EDGE_CLEAR    EQU 0x410                                 ; RW read to view, write 1 to clear (32 bits)
OFFSET_INTERRUPT_EDGE_SET      EQU 0x414                                 ; WO edge set (32 bits)
OFFSET_INTERRUPT_OUTPUT        EQU 0x41C                                 ; RO Status = bit 0 (32 bits)
