;------------------------------------------------------------
;                LCD Write Data/Command
;                     Oliver Harris
;
; Purpose: Writes data or command to LCD, when not busy
; Input: a0 = data to write (bits 0:7)
;             0 for data, 1 for command (bit 8)
; Output: None
; Modifies: a0, a2, t0, t1, t2
; Requires: delay.s
;
; Last modified: 10/03/26
;
;------------------------------------------------------------

DATA_COMMAND_BIT     EQU 0x100                          ; bit 8
WRITE_COMMAND        EQU DATA_COMMAND_BIT

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
