;---------------------------------------------
;   Tests for LCD
;   Oliver Harris
;
; Last modified: 17/02/26
;
;---------------------------------------------
                                 la sp, STACK_END

; --- ALL AVAILABLE TESTS ---
;  j test_clear_screen
;  j test_newline

; j test_str_hello_world
; j test_str_null_terminator
; j test_str_carriage_return
; j test_str_backspace
; j test_str_tab
; j test_str_vertical_tab
                                 j test_str_vertical_tab_complex
; j test_carriage_both_lines

; --- CHAR TESTS ---

; test_clear_screen
; OUTPUT: "Sam" (clears "Bob" first)
test_clear_screen:
                                 li a0, 'B'
                                 call write_char
                                 li a0, 'o'
                                 call write_char
                                 li a0, 'b'
                                 call write_char
                                 li a0, '\f'                              ; clear screen
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
test_newline:
                                 li a0, '\f'
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
                                 li a0, '\n'                              ; newline
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


; test_str_vertical_tab
; OUTPUT: Line 1: "Up"
;         Line 2: "Down"
p_str_vertical_tab               defb "\f\nDown\vUp\0"
                                 align
test_str_vertical_tab            la a0, p_str_vertical_tab
                                 call write_string
                                 j end

; test_str_vertical_tab_complex
; OUTPUT: Line 1: "Up World"
;         Line 2: "Down Hello"
p_str_vertical_tab_complex       defb "\f\nDown\vUp\n World\v Hello\0"
                                 align
test_str_vertical_tab_complex    la a0, p_str_vertical_tab_complex
                                 call write_string
                                 j end


; test_carriage_both_lines
; OUTPUT: Line 1: "123" (overwrites "ABC")
;         Line 2: "456" (overwrites "XYZ")
p_str_carriage_both_lines        defb "\fABC\nXYZ\r456\v123\0"
                                 align
test_str_carriage_both_lines     la a0, p_str_carriage_both_lines
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

end               j .

; --- STACK ---

STACK                            DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
