;--------------------------------------------------
;              LCD Utility Functions
;                 Oliver Harris
;
; Allows writing of characters including
; special characters: \b, \t, \n, \v, \f, \r
;
; Last modified: 20/02/26
;
; Known bugs: only supports two lines,
;             \n and \v dont track col position
;
; Requires: delay.s
;
;--------------------------------------------------

; --- Constants ---

LCD_CMD_LEFT            EQU 0x10                             ; Backspace
LCD_CMD_RIGHT           EQU 0x14                             ; Tab
LCD_CMD_NEWLINE         EQU 0xC0                             ; Line feed (down line)
LCD_CMD_VTAB            EQU 0x80                             ; Vertical tab (up line)
LCD_CMD_CLEAR           EQU 0x01                             ; Form feed (clear display, reset cursor)

ASCII_SPECIALS_START    EQU 0x08                             ; Starts at backspace
ASCII_SPECIALS_END      EQU 0x0D                             ; Ends at carriage return

; --- Memory ---

lcd_line_pos            defb 0
                        align


; --- Functions ---

; write_string
; Purpose: Outputs string to LCD, interpreting special characters
;          (\b, \t, \n, \v, \f, \r)
; Input: a0 = pointer to null-terminated string
; Output: None
; Modifies: a0, a3, t0, a1
; Preserves: ra
write_string:
                        subi sp, sp, 4
                        sw ra, [sp]
                        mv a3, a0                            ; a3 stores pointer to pos in str
write_string_loop       lb a0, [a3]                          ; loop chars until reaches null terminator
                        beqz a0, write_string_end
                        call write_char
                        addi a3, a3, 1
                        j write_string_loop
write_string_end        lw ra, [sp]
                        addi sp, sp, 4
                        ret


; write_char
; Purpose: Outputs character to LCD, interpreting special characters
;          (\b, \t, \n, \v, \f, \r)
; Input: a0 = character to write
; Output: None
; Modifies: a0, t0, a1
write_char:
                        subi sp, sp, 4
                        sw ra, [sp]
                        li t0, ASCII_SPECIALS_END            ; check if char is a special char
                        bgtu a0, t0, _write_char
                        li t0, ASCII_SPECIALS_START
                        bltu a0, t0, _write_char
                        la t0, specials_table                ; lookup special char function
                        subi a0, a0, ASCII_SPECIALS_START
                        slli a0, a0, 2
                        add t0, t0, a0
                        lw t0, [t0]
                        li a1, 0                             ; write command
                        jr t0

_write_char             li a1, 1                             ; write data
                        j _write_data

; Jump table for special characters handling
specials_table          defw _write_backspace
                        defw _write_tab
                        defw _write_line_feed
                        defw _write_vertical_tab
                        defw _write_form_feed
                        defw _write_carriage_return

_write_backspace:
                        li a0, LCD_CMD_LEFT                  ; move cursor left
                        j _write_data


_write_tab:
                        li a0, LCD_CMD_RIGHT                 ; move cursor right
                        j _write_data

_write_line_feed:
                        li a0, LCD_CMD_NEWLINE               ; move cursor down
                        la t0, lcd_line_pos                  ; stores line pos 1
                        li t1, 1
                        sw t1, [t0]
                        j _write_data

_write_vertical_tab:
                        li a0, LCD_CMD_VTAB                  ; move cursor up
                        la t0, lcd_line_pos                  ; stores line pos 0
                        sw x0, [t0]
                        j _write_data

_write_form_feed:
                        li a0, LCD_CMD_CLEAR                 ; clear display
                        la t0, lcd_line_pos                  ; stores line pos 0
                        sw x0, [t0]
                        j _write_data

_write_carriage_return:
                        lw t0, lcd_line_pos                  ; check if currently on line 1
                        bnez t0, _return_line_1
_return_line_0          li a0, LCD_CMD_VTAB                  ; return to line 0
                        j _write_data
_return_line_1          li a0, LCD_CMD_NEWLINE               ; return to line 1
                        j _write_data

_write_data             li a7, 0
                        ecall                                ; ecall write to lcd
                        lw ra, [sp]
                        addi sp, sp, 4
                        ret
