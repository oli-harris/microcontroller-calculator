;------------------------------------------------------------------------
;                              Ecall Handlers
;                              Oliver Harris
;
; A collection of ecall handlers for LCD, buttons, LEDs and timer.
; Combined into one file to make marking easier.
; Each handler is called by trap_handler_ecall.
;
;------------------------------------------------------------------------

; --- Button Ecalls ---
; Last modified: 10/03/26

buttons_prev         defw 0                             ; (4 bits)

; ecall_changed_buttons
; Purpose: Reads buttons and detects rising edges
; Input: None
; Output: a0 = button with changed value on rising edge
; Modifies: t0, t1, t2, a0
ecall_changed_buttons:
                     li t0, HARDWARE_BASE_ADDRESS
                     la t1, buttons_prev
                     lb t0, OFFSET_BUTTONS[t0]          ; t0 = current value of buttons
                     lb t2, [t1]                        ; t2 = previous value of buttons
                     sb t0, [t1]                        ; stores current into previous

                     not t2, t2                         ; Detect edge into a0
                     and a0, t0, t2
                     ret


; --- LCD Ecalls ---
; Last modified: 10/03/26

DATA_COMMAND_BIT     EQU 0x100                          ; bit 8
WRITE_COMMAND        EQU DATA_COMMAND_BIT


; ecall_lcd_write
; Purpose: Writes data or command to LCD, when not busy
; Input: a0 = data to write (bits 0:7)
;             0 for data, 1 for command (bit 8)
; Output: None
; Modifies: a0, a2, t0, t1, t2
; Requires: delay.s
ecall_lcd_write:
                     subi sp, sp, 4
                     sw ra, [sp]

                     li t2, HARDWARE_BASE_ADDRESS       ; t2 always hardware base address
lcd_write_step1      lbu t0, OFFSET_LCD_STATUS[t2]      ; Read control
                     ori t0, t0, LCD_RW                 ; R/W = 1
                     andi t0, t0, ~LCD_RS               ; RS = 0
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_2     ori t0, t0, LCD_ENABLE_BUS         ; Enable bus
                     sb t0, OFFSET_LCD_STATUS[t2]

lcd_write_step_2a    li a2, DELAY_PULSE
                     call delay_loop

lcd_write_step_3     lbu t1, OFFSET_LCD_BUS[t2]         ; Read LCD status byte
lcd_write_step_4     andi t0, t0, ~LCD_ENABLE_BUS       ; Disable bus
                     sb t0, OFFSET_LCD_STATUS[t2]

lcd_write_step_5     li a2, DELAY_SEPARATE
                     call delay_loop

lcd_write_step_6     andi t1, t1, LCD_BUSY_FLAG         ; loop if busy flag (bit 7)
                     bnez t1, lcd_write_step_2

lcd_write_step_7     andi t0, t0, ~(LCD_RW | LCD_RS)    ; R/W = 0, RS = 0
                     andi t1, a0, DATA_COMMAND_BIT      ; Set RS to 0 if data, 1 if command
                     srli t1, t1, 7
                     xori t1, t1, LCD_RS
                     or t0, t0, t1
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_8     sb a0, OFFSET_LCD_BUS[t2]          ; Put data onto bus
lcd_write_step_9     ori t0, t0, LCD_ENABLE_BUS         ; Enable bus
                     sb t0, OFFSET_LCD_STATUS[t2]


lcd_write_step_9a    li a2, DELAY_PULSE
                     call delay_loop

lcd_write_step_10    andi t0, t0, ~LCD_ENABLE_BUS       ; Disable bus (E = 0)
                     sb t0, OFFSET_LCD_STATUS[t2]

lcd_write_end        lw ra, [sp]
                     addi sp, sp, 4
                     ret


; --- Led Ecalls ---
; Last modified: 08/05/26

; ecall_set_leds
; Purpose: Set LEDs according to input
; Input: a0 = LED Colour (8 bits)
; Output: None
; Modifies: t0
ecall_set_leds:
                     la t0, HARDWARE_BASE_ADDRESS
                     sb a0, OFFSET_LED[t0]
                     ret


; --- Keyboard Ecalls ---
; Last modified: 27/03/26

; ecall_get_key
; Purpose: Get least recently pressed key, or -1 if no key
;          (wrapper for key_buffer_pop so agnostic to implementation)
; Output: a0 = -1 for no key, else 0-15
ecall_get_key:
                     subi sp, sp, 4
                     sw ra, [sp]

                     call key_buffer_pop

                     lw ra, [sp]
                     addi sp, sp, 4
                     ret

; --- Buzzer Ecalls ---
; Last modified: 11/05/26

; ecall_play_sound
; Purpose: Play a sound on the buzzer
; Input: a0 = note (1-50), or 0 to stop
ecall_play_sound:
                     li t0, USER_PERIPHERAL_BASE
                     bnez a0, play_sound

stop_buzzer          li t1, 0                           ; Sets disable bit and ignores note
                     j write_sound

play_sound           slli t1, a0, 1                     ; Set note (bits 1-6)
                     ori t1, t1, 1                      ; Set enable bit

write_sound          sb t1, OFFSET_BUZZER[t0]
                     ret
