;--------------------------------------------------
;              LCD Utility Functions
;                 Oliver Harris
;
; Allows: - writing of characters including special characters:
;           \b (backspace), \t (tab), \n (lower line), \v (upper line),
;           \f (clear & reset), \r (carriage return)
;         - writing of padded hex values
;         - writing of decimal values
;
; Last modified: 09/03/26
;
; Known bugs: \n and \v dont track col position
;
;--------------------------------------------------

; --- Library Specific Constants ---

LCD_CMD_LEFT            EQU 0x110                            ; Backspace
LCD_CMD_RIGHT           EQU 0x114                            ; Tab
LCD_CMD_NEWLINE         EQU 0x1C0                            ; Line feed (down line)
LCD_CMD_VTAB            EQU 0x180                            ; Vertical tab (up line)
LCD_CMD_CLEAR           EQU 0x101                            ; Form feed (clear display, reset cursor)

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

; write_hex
; Purpose: Outputs 32-bit value to LCD as n nibbles, padded
; Input: a0 = value to write
;        a1 = nibbles to write (1-8)
; Output: None
; Modifies: a0, t0
write_hex:
                        subi sp, sp, 12
                        sw ra, [sp]
                        sw s0, 4[sp]
                        sw s1, 8[sp]

                        mv s0, a0                            ; s0 = original value
                        li t0, 4
                        mul s1, a1, t0                       ; s1 = shift amount
                        subi s1, s1, 4                       ; shift of first nibble

write_hex_nibble        srl a0, s0, s1                       ; mask off current nibble
                        andi a0, a0, 0xF
                        addi a0, a0, '0'                     ; 0-9
                        li t0, '9'
                        bleu a0, t0, _write_hex_call_char    ; preserve ra
                        addi a0, a0, 'A' - '9' - 1           ; A-E
_write_hex_call_char    call write_char

                        subi s1, s1, 4                       ; shift to next nibble
                        bgez s1, write_hex_nibble            ; loop until all nibbles written

write_hex_end           lw s1, 8[sp]
                        lw s0, 4[sp]
                        lw ra, [sp]
                        addi sp, sp, 12
                        ret

; write_decimal
; Purpose: Outputs single decimal digit to LCD, simpler than write_hex
; Input: a0 = decimal digit to write (0-9)
; Output: None
; Modifies: a0
write_decimal:
                        subi sp, sp, 4
                        sw ra, [sp]

                        li t0, 9                             ; check valid digit
                        bgt a0, t0, write_decimal_end

                        addi a0, a0, '0'                     ; convert digit to ASCII
                        li a7, ECALL_LCD_WRITE               ; ecall write to lcd
                        ecall

write_decimal_end       lw ra, [sp]
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
                        ori a0, a0, WRITE_COMMAND            ; write command

                        andi a0, a0, 0xFF                    ; enforce input a0 is ASCII
                        li t0, ASCII_SPECIALS_END            ; check if char is a special char
                        bgtu a0, t0, _write_data
                        li t0, ASCII_SPECIALS_START
                        bltu a0, t0, _write_data
                        la t0, specials_table                ; lookup special char function
                        subi a0, a0, ASCII_SPECIALS_START
                        slli a0, a0, 2
                        add t0, t0, a0
                        lw t0, [t0]
                        jr t0

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
                        sw zero, [t0]
                        j _write_data

_write_form_feed:
                        li a0, LCD_CMD_CLEAR                 ; clear display
                        la t0, lcd_line_pos                  ; stores line pos 0
                        sw zero, [t0]
                        j _write_data

_write_carriage_return:
                        lw t0, lcd_line_pos                  ; check if currently on line 1
                        bnez t0, _return_line_1
_return_line_0          li a0, LCD_CMD_VTAB                  ; return to line 0
                        j _write_data
_return_line_1          li a0, LCD_CMD_NEWLINE               ; return to line 1
                        j _write_data

_write_data             li a7, ECALL_LCD_WRITE
                        ecall                                ; ecall write to lcd

                        lw ra, [sp]
                        addi sp, sp, 4
                        ret
