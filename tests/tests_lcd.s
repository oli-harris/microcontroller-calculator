;---------------------------------------------
;   Tests for LCD
;   Oliver Harris
;
; Last modified: 06/03/26
;
;---------------------------------------------

                                 include ../os/init.s
STACK_SIZE                       EQU 32 * 4

; --- ALL AVAILABLE TESTS ---
start:
;  j test_clear_screen
;  j test_newline

;  j test_hex_3
;  j test_hex_0F
;  j test_hex_F3
;  j test_hex_ABCD1234
                                 j test_hex_A001F34


;  j test_str_hello_world
;  j test_str_null_terminator
;  j test_str_carriage_return
;  j test_str_backspace
;  j test_str_tab
;  j test_str_tab_complex
;  j test_str_vertical_tab
;  j test_str_vertical_tab_complex
;  j test_str_carriage_both_lines
;  j test_str_col_overflow
;  j test_str_row_overflow

; --- CHAR TESTS ---

; test_clear_screen
; OUTPUT: "Sam" (clears "Bob" first)
test_clear_screen                li a0, 'B'
                                 call write_char
                                 li a0, 'o'
                                 call write_char
                                 li a0, 'b'
                                 call write_char
                                 li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 'S'
                                 call write_char
                                 li a0, 'a'
                                 call write_char
                                 li a0, 'm'
                                 call write_char
                                 j end

; test_newline
; OUTPUT: Line 1: "Hello"
;         Line 2: "World"
test_newline                     li a0, '\f'
                                 call write_char
                                 li a0, 'H'
                                 call write_char
                                 li a0, 'e'
                                 call write_char
                                 li a0, 'l'
                                 call write_char
                                 li a0, 'l'
                                 call write_char
                                 li a0, 'o'
                                 call write_char
                                 li a0, '\n'                                      ; newline
                                 call write_char
                                 li a0, 'W'
                                 call write_char
                                 li a0, 'o'
                                 call write_char
                                 li a0, 'r'
                                 call write_char
                                 li a0, 'l'
                                 call write_char
                                 li a0, 'd'
                                 call write_char
                                 j end

; --- HEX TESTS ---
; test_hex_3
; OUTPUT: "3"
test_hex_3                       li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 0x3
                                 li a1, 1
                                 call write_hex
                                 j end

; test_hex_0F
; OUTPUT: "0F"
test_hex_0F                      li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 0xF
                                 li a1, 2
                                 call write_hex
                                 j end

; test_hex_F3
; OUTPUT: "F3"
test_hex_F3                      li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 0xF3
                                 li a1, 2
                                 call write_hex
                                 j end

; test_hex_ABCD1234
; OUTPUT: "ABCD1234"
test_hex_ABCD1234                li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 0xABCD1234
                                 li a1, 8
                                 call write_hex
                                 j end

; test_hex_A001F34
; OUTPUT: "A001F34"
test_hex_A001F34                 li a0, '\f'                                      ; clear screen
                                 call write_char
                                 li a0, 0xA001F34
                                 li a1, 7
                                 call write_hex
                                 j end

; --- STRING TESTS ---

; test_str_hello_world
; OUTPUT: Line 1: "Hello"
;         Line 2: "World!"
p_str_hello_world                defb "\fHello\nWorld!\0"
                                 align
test_str_hello_world             la a0, p_str_hello_world
                                 call write_string
                                 j end


; test_str_null_terminator
; OUTPUT: "Hello."
p_str_null_terminator            defb "\fHello.\0ignore me"
                                 align
test_str_null_terminator         la a0, p_str_null_terminator
                                 call write_string
                                 j end


; test_str_carriage_return
; OUTPUT: "XYZ" (overwrites "ABC")
p_str_carriage_return            defb "\fABC\rXYZ\0"
                                 align
test_str_carriage_return         la a0, p_str_carriage_return
                                 call write_string
                                 j end


; test_str_backspace
; OUTPUT: "Hello." (fixes typo)
p_str_backspace                  defb "\fHelyo\b\blo.\0"
                                 align
test_str_backspace               la a0, p_str_backspace
                                 call write_string
                                 j end


; test_str_tab
; OUTPUT: "A   B" (three tabs between A and B)
p_str_tab                        defb "\fA\t\t\tB\0"
                                 align
test_str_tab                     la a0, p_str_tab
                                 call write_string
                                 j end

; test_str_tab_complex
; OUTPUT: "A C B" (three tabs between A and B)
p_str_tab_complex                defb "\fA\t\t\tB\b\b\bC\0"
                                 align
test_str_tab_complex             la a0, p_str_tab_complex
                                 call write_string
                                 j end


; test_str_vertical_tab
; OUTPUT: Line 1: "Up"
;         Line 2: "Down"
p_str_vertical_tab               defb "\f\nDown\vUp\0"
                                 align
test_str_vertical_tab            la a0, p_str_vertical_tab
                                 call write_string
                                 j end

; test_str_vertical_tab_complex
; OUTPUT: Line 1: "Hello"
;         Line 2: "World"
p_str_vertical_tab_complex       defb "\f\nDown\vUp\nWorld\vHello\0"
                                 align
test_str_vertical_tab_complex    la a0, p_str_vertical_tab_complex
                                 call write_string
                                 j end


; test_carriage_both_lines
; OUTPUT: Line 1: "789" (overwrites "ABC")
;         Line 2: "456" (overwrites "XYZ")
p_str_carriage_both_lines        defb "\fABC\nXYZ\r456\v123\r789\0"
                                 align
test_str_carriage_both_lines     la a0, p_str_carriage_both_lines
                                 call write_string
                                 j end


; test_str_col_overflow
; OUTPUT: Line 1: "123456789abcdeFG"
;         Line 2:
; Proves controller tracks col_pos past 16
p_str_col_overflow               defb "\f123456789abcdefghijk\b\b\b\b\b\bFG\0"
                                 align
test_str_col_overflow            la a0, p_str_col_overflow
                                 call write_string
                                 j end

; test_str_row_overflow
; OUTPUT: Line 1: "Hello"
;         Line 2: "World"
; Proves controller doesnt track row_pos past 1
p_str_row_overflow               defb "\f\n\n\n\nWorld\v\vHello\0"
                                 align
test_str_row_overflow            la a0, p_str_row_overflow
                                 call write_string
                                 j end


; test_str_copy_me
; OUTPUT: Line 1:
;         Line 2:
p_str_copy_me                    defb "\0"
                                 align
test_str_copy_me                 la a0, p_str_copy_me
                                 call write_string
                                 j end


; --- END TESTS ---

                                 end j .

; --- STACK ---

                                 STACK DEFS 128
STACK_END

; --- INCLUDES ---
                                 include ../lib/lcd.s
