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

; --- Constants ---

LCD_ADDRESS           EQU 0x0001_0100            ; LCD base address
LCD_CMD_LEFT          EQU 0x10                   ; Backspace
LCD_CMD_RIGHT         EQU 0x14                   ; Tab
LCD_CMD_NEWLINE       EQU 0xC0                   ; Line feed (down line)
LCD_CMD_VTAB          EQU 0x80                   ; Vertical tab (up line)
LCD_CMD_CLEAR         EQU 0x01                   ; Form feed (clear display, reset cursor)

ASCII_SPECIALS_START  EQU 0x08                   ; Starts at backspace
ASCII_SPECIALS_END    EQU 0x0D                   ; Ends at carriage return

DELAY_PULSE           EQU 5                      ; pulse width delay (>= 20 cycles)
DELAY_SEPARATE        EQU 12                     ; seperate pulses (>= 48 cycles)
 
; --- Memory ---

lcd_line_pos        defb 0
                    align


; --- Functions ---

; write_string
; Input: a0 = string to write
write_string:
                    subi sp, sp, 4
                    sw ra, [sp]
                    mv a3, a0                      ; a3 stores pointer to pos in str
write_string_loop   lb a0, [a3]                    ; loop chars until reaches null terminator
                    beqz a0, end_write_string
                    call write_char
                    addi a3, a3, 1
                    j write_string_loop
write_string_end    lw ra, [sp]                  
                    addi sp, sp, 4
                    ret


; write_char
; a0 = character to write
write_char:
                    li t0, ASCII_SPECIALS_START     ; check if char is a special char
                    bgtu a0, t0, _write_char
                    li t0, ASCII_SPECIALS_END
                    bltu a0, t0, _write_char
                    la t0, specials_table           ; lookup special char function
                    subi a0, a0, ASCII_SPECIALS_START
                    slli a0, a0, 2
                    add t0, t0, a0
                    lw t0, [t0]
                    li a1, 0                       ; write command
                    jr t0

write_char_direct   li a1, 1
                    j write_data

; Handle Special characters
specials_table      defw _write_backspace
                    defw _write_tab
                    defw _write_line_feed
                    defw _write_vertical_tab
                    defw _write_form_feed
                    defw _write_carriage_return

_write_backspace:
                    li a0, LCD_CMD_LEFT            ; move cursor left
                    j write_data


_write_tab:
                    li a0, LCD_CMD_RIGHT           ; move cursor right
                    j write_data

_write_line_feed:
                    li a0, LCD_CMD_NEWLINE         ; move cursor down
                    la t0, lcd_line_pos            ; stores line pos 1
                    li t1, 1
                    sw t1, [t0]
                    j write_data

_write_vertical_tab:
                    li a0, LCD_CMD_VTAB            ; move cursor up
                    la t0, lcd_line_pos            ; stores line pos 0
                    sw x0, [t0]
                    j write_data

_write_form_feed:
                    li a0, LCD_CMD_CLEAR           ; clear display
                    la t0, lcd_line_pos            ; stores line pos 0
                    sw x0, [t0]
                    j write_data

_write_carriage_return:
                    lw t0, lcd_line_pos            ; check if currently on line 1
                    bnez t0, _return_line_1
_return_line_0      li a0, LCD_CMD_VTAB            ; return to line 0
                    j write_data
_return_line_1      li a0, LCD_CMD_NEWLINE         ; return to line 1
                    j write_data


; write_data
; a0 = data to write
; a1 = 1 for data, 0 for command
write_data:
                    subi sp, sp, 4                 ; store ra
                    sw ra, [sp]
                    li t2, LCD_ADDRESS             ; t2 always LCD_ADDRESS
write_data_step1    lb t0, 0x1[t2]                 ; read control
                    ori t0, t0, 0b0000_0001        ; R/W = 1
                    andi t0, t0, 0b1111_1101       ; RS = 0
                    sb t0, 0x1[t2]
write_data_step_2   ori t0, t0, 0b0000_0100        ; enable bus (E = 1)
                    sb t0, 0x1[t2]
write_data_step_2a  li a2, DELAY_PULSE             ; pulse width delay
                    call delay_loop
write_data_step_3   lb t1, 0x0[t2]                 ; read LCD status byte
write_data_step_4   andi t0, t0, 0b1111_1011       ; disable bus (E = 0)
                    sb t0, 0x1[t2]
write_data_step_5   li a2, DELAY_SEPARATE          ; seperate pulses
                    call delay_loop
write_data_step_6   andi t1, t1, 0b1000_0000       ; loop if busy flag (bit 7)
                    bnez t1, step_2
write_data_step_7   andi t0, t0, 0b1111_1100       ; R/W = 0, RS = 0
                    andi a1, a1, 1                 ; enforce input a1 boolean
                    slli a1, a1, 1
                    or t0, t0, a1                  ; RS = a1
                    sb t0, 0x1[t2]
write_data_step_8   sb a0, 0x0[t2]                 ; output data
write_data_step_9   ori t0, t0, 0b0000_0100        ; enable bus (E = 1)
                    sb t0, 0x1[t2]
write_data_step_9a  li a2, DELAY_PULSE             ; pulse width delay
                    call delay_loop
write_data_step_10  andi t0, t0, 0b1111_1011       ; disable bus (E = 0)
                    sb t0, 0x1[t2]
write_data_end      lw ra, [sp]                    ; restore ra
                    addi sp, sp, 4
                    ret
