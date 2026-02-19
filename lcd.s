;--------------------------------------------------
;                LCD Utility Functions
;                Oliver Harris
;
; Allows writing of characters including
; special characters: \b, \t, \n, \v, \f, \r
;
; Last modified: 17/02/26
;
; Known bugs: only supports two lines,
;             \n and \v dont track col position
;
; Requires: utility.s
;
;--------------------------------------------------

LCD_ADDRESS         EQU 0x0001_0100

lcd_line_pos        defw 0


; write_string
; a0 = string to write
write_string:
                    subi sp, sp, 4
                    sw ra, [sp]
                    mv a3, a0                      ; a3 stores pointer to pos in str
loop_write_char     lb a0, [a3]
                    beqz a0, end_write_string
                    call write_char
                    addi a3, a3, 1
                    j loop_write_char
end_write_string    lw ra, [sp]
                    addi sp, sp, 4
                    ret


; write_char
; a0 = character to write
write_char:
                    li t0, 0x0D
                    bgtu a0, t0, _write_char
                    li t0, 0x08
                    bltu a0, t0, _write_char
                    la t0, specials_table
                    subi a0, a0, 0x08
                    slli a0, a0, 2
                    add t0, t0, a0
                    lw t0, [t0]
                    li a1, 0                       ; writing command
                    jr t0

_write_char         li a1, 1
                    j write_data

; Handle Special characters
specials_table      defw _write_backspace
                    defw _write_tab
                    defw _write_line_feed
                    defw _write_vertical_tab
                    defw _write_form_feed
                    defw _write_carriage_return

_write_backspace:
                    li a0, 0x10                    ; move cursor left
                    j write_data


_write_tab:
                    li a0, 0x14                    ; move cursor right
                    j write_data

_write_line_feed:
                    li a0, 0xC0                    ; move cursor down
                    li t0, lcd_line_pos            ; stores at line 1
                    li t1, 1
                    sw t1, [t0]
                    j write_data

_write_vertical_tab:
                    li a0, 0x80                    ; move cursor up
                    la t0, lcd_line_pos            ; stores at line 0
                    li t1, 1
                    sw t1, [t0]
                    j write_data

_write_form_feed:
                    li a0, 0x01                    ; clear display
                    li t0, lcd_line_pos            ; stores at line 0
                    li t1, 0
                    sw t1, [t0]
                    j write_data

_write_carriage_return:
                    lw t0, lcd_line_pos
                    bnez t0, _return_line_1
_return_line_0      li a0, 0x80
                    li a1, 0
                    j write_data
_return_line_1      li a0, 0xC0
                    li a1, 0
                    j write_data


; write_data
; a0 = data to write
; a1 = 1 for data, 0 for command
write_data:
                    subi sp, sp, 4                 ; store ra
                    sw ra, [sp]
                    li t2, LCD_ADDRESS             ; t2 always LCD_ADDRESS
step_1              lb t0, 0x1[t2]                 ; read control
                    ori t0, t0, 0b0000_0001        ; R/W = 1
                    andi t0, t0, 0b1111_1101       ; RS = 0
                    sb t0, 0x1[t2]
step_2              ori t0, t0, 0b0000_0100        ; enable bus (E = 1)
                    sb t0, 0x1[t2]
step_2a             li a2, 5                       ; pulse width delay (>= 20 cycles)
                    call delay_loop
step_3              lb t1, 0x0[t2]                 ; read LCD status byte
step_4              andi t0, t0, 0b1111_1011       ; disable bus (E = 0)
                    sb t0, 0x1[t2]
step_5              li a2, 12                      ; seperate pulses (>= 48 cycles)
                    call delay_loop
step_6              andi t1, t1, 0b1000_0000       ; loop if busy flag (bit 7)
                    bnez t1, step_2
step_7              andi t0, t0, 0b1111_1100       ; R/W = 0, RS = 0
                    andi a1, a1, 1                 ; enforce input a1 boolean
                    slli a1, a1, 1
                    or t0, t0, a1                  ; RS = a1
                    sb t0, 0x1[t2]
step_8              sb a0, 0x0[t2]                 ; output data
step_9              ori t0, t0, 0b0000_0100        ; enable bus (E = 1)
                    sb t0, 0x1[t2]
step_9a             li a2, 5                       ; pulse width delay (>=20 cycles)
                    call delay_loop
step_10             andi t0, t0, 0b1111_1011       ; disable bus (E = 0)
                    sb t0, 0x1[t2]
write_data_end      lw ra, [sp]                    ; restore ra
                    addi sp, sp, 4
                    ret
