;--------------------------------------------
;      LCD Privileged Hardware Functions
;             Oliver Harris
;
; Last modified: 02/03/26
;
; Requires: delay.s
;
;--------------------------------------------

; ecall_lcd_write
; Purpose: Writes data or command to LCD, when not busy
; Input: a0 = data to write
;        a1 = 1 for data, 0 for command
; Output: None
; Modifies: a0, a1, t0, t1, t2
ecall_lcd_write:
                     subi sp, sp, 4                  ; store ra
                     sw ra, [sp]
                     li t2, HARDWARE_BASE_ADDRESS    ; t2 always hardware base address
lcd_write_step1      lb t0, OFFSET_LCD_STATUS[t2]    ; read control
                     ori t0, t0, 0b0000_0001         ; R/W = 1
                     andi t0, t0, 0b1111_1101        ; RS = 0
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_2     ori t0, t0, 0b0000_0100         ; enable bus (E = 1)
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_2a    li a2, DELAY_PULSE              ; pulse width delay
                     call delay_loop
lcd_write_step_3     lb t1, OFFSET_LCD_BUS[t2]       ; read LCD status byte
lcd_write_step_4     andi t0, t0, 0b1111_1011        ; disable bus (E = 0)
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_5     li a2, DELAY_SEPARATE           ; separate pulses
                     call delay_loop
lcd_write_step_6     andi t1, t1, 0b1000_0000        ; loop if busy flag (bit 7)
                     bnez t1, lcd_write_step_2
lcd_write_step_7     andi t0, t0, 0b1111_1100        ; R/W = 0, RS = 0
                     andi a1, a1, 1                  ; enforce input a1 boolean
                     slli a1, a1, 1
                     or t0, t0, a1                   ; RS = a1
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_8     sb a0, OFFSET_LCD_BUS[t2]       ; output data
lcd_write_step_9     ori t0, t0, 0b0000_0100         ; enable bus (E = 1)
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_step_9a    li a2, DELAY_PULSE              ; pulse width delay
                     call delay_loop
lcd_write_step_10    andi t0, t0, 0b1111_1011        ; disable bus (E = 0)
                     sb t0, OFFSET_LCD_STATUS[t2]
lcd_write_end        lw ra, [sp]                     ; restore ra
                     addi sp, sp, 4
                     ret
