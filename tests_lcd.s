;---------------------------------------------
;   Tests for LCD
;   Oliver Harris
;
; Last modified: 17/02/26
;
;---------------------------------------------
                                 la sp, STACK_END

; --- ALL AVAILABLE TESTS ---
                                 j test_clear_screen
                                 j test_newline

                                 j test_str_hello_world
                                 j test_str_null_terminator
                                 j test_str_carriage_return
                                 j test_str_backspace
                                 j test_str_tab
                                 j test_str_vertical_tab
                                 j test_str_vertical_tab_complex
                                 j test_carriage_both_lines
                                 j test_str_overflow
                                 j test_str_row_overflow

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
; OUTPUT: Line 1: "Hello"
;         Line 2: "World"
p_str_vertical_tab_complex       defb "\f\nDown\vUp\nWorld\vHello\0"
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
test_str_row_overflow            la a                                             ;----------------------------------------------------------------------
;                Exercise 3
;                Oliver Harris
;
; Trivia game to guess european capitals
; Features: displays all 52 european countries and capitals
;         : btn1: previous country,        btn2: next country
;         : btn3: view answer (one char),  btn4: view entire answer
;
; Last modified: 20/02/26
;
;------------------------------------------------------------------------

                                 j start

; --- Constants ---
LEDS_ADDRESS                     EQU 0x0001_0000
BUTTONS_ADDRESS                  EQU 0x0001_0001

LEDS_RAINBOW                     EQU 0b1111                                       ; using half of leds, as too bright
LEDS_RED                         EQU 0b0001
LEDS_GREEN                       EQU 0b0100

DEBOUNCE_MS                      EQU 20                                           ; delay for button debounce


; --- Memory ---
buttons_prev                     defb 0
table_position        defb -1                             ; position in table (clamped)
; starts at -1 to show first question on btn press
                                 align
p_str_answer                     defw 0                                           ; points to answer string
p_null                           defw 0                                           ; null pointer
welcome_message                  defb "\fCapitals Trivia!\n...\0"
                                 align

; --- Main Section ---
start                            la sp, STACK_END
                                 la a0, welcome_message                           ; Startup display
                                 call write_string
                                 li a0, LEDS_RAINBOW
                                 call set_leds

loop                             call read_buttons

check_buttons                    andi t0, a0, 0b0001                              ; Button 1 Pressed
                                 bnez t0, display_prev_trivia
                                 andi t0, a0, 0b0010                              ; Button 2 Pressed
                                 bnez t0, display_next_trivia
                                 andi t0, a0, 0b0100                              ; Button 3 Pressed
                                 bnez t0, display_next_answer
                                 andi t0, a0, 0b1000                              ; Button 4 Pressed
                                 bnez t0, display_entire_answer

end_loop                         li a1, DEBOUNCE_MS
                                 call delay_ms

end                              j loop

; --- Functions ---

; read_buttons
; Purpose: Reads buttons and detects rising edges
; Input: None
; Output: a0 = button with changed value on rising edge
read_buttons:
                                 li t0, BUTTONS_ADDRESS
                                 la t1, buttons_prev
                                 lb t0, [t0]                                      ; t0 = current value of buttons
                                 lb t2, [t1]                                      ; t2 = previous value of buttons
                                 sb t0, [t1]                                      ; stores current into previous

                                 not t2, t2                                       ; keep only difference in a0
                                 and a0, t0, t2
                                 ret


; display_prev_trivia
; Purpose: Fetches previous trivia question and displays it
; Input/Output: None
display_prev_trivia:
                                 la t0, table_position                            ; table_pos--
                                 lb a0, [t0]
                                 subi a0, a0, 1
                                 bgez a0, skip_prev_clamp
                                 li a0, CAPITALS_TABLE_SIZE
                                 subi a0, a0, 1
skip_prev_clamp                  sb a0, [t0]
                                 j display_question


; display_next_trivia
; Purpose: Fetches next trivia question and displays it
; Input/Output: None
display_next_trivia:
                                 la t0, table_position                            ; table_pos++
                                 lb a0, [t0]
                                 addi a0, a0, 1
                                 li t1, CAPITALS_TABLE_SIZE                       ; overflow to 0
                                 blt a0, t1, skip_next_clamp
                                 mv a0, x0
skip_next_clamp                  sb a0, [t0]
                                 j display_question


; display_question
; Purpose: Displays question at current table position, and sets answer pointer
; Input: a0 = position
; Output: None
display_question:
                                 la t0, capitals_table
                                 slli a0, a0, 3                                   ; a0 *= 8, as each entry is 8 bytes
                                 add t0, t0, a0
                                 lw a0, [t0]                                      ; a0=question string

                                 lw t1, 4[t0]                                     ; store pointer to answer string
                                 la t0, p_str_answer
                                 sw t1, [t0]

                                 call write_string

                                 li a0, LEDS_RED                                  ; Lights red
                                 call set_leds
                                 j end_loop


; display_entire_answer
; Purpose: Displays entire answer, sets light green
; Input/Output: None
display_entire_answer:
                                 li a0, LEDS_GREEN                                ; Lights green
                                 call set_leds

                                 la s0, p_str_answer                              ; stores p_str_answer address
                                 lw a0, [s0]
                                 call write_string

                                 la t0, p_null                                    ; finished, so point to end of string
                                 sw t0, [s0]

                                 j end_loop


; display_next_answer
; Purpose: Displays next char in answer, sets light green after completion
; Input/Output: None
display_next_answer:
                                 la s0, p_str_answer                              ; t0 = pointer to char in answer
                                 lw s1, [s0]
                                 lb a0, [s1]                                      ; a0 = char

                                 beqz a0, answer_all_printed                      ; entire answer printed, skip
                                 call write_char

                                 addi s1, s1, 1                                   ; p_str_answer++
                                 sb s1, [s0]
                                 j end_loop
answer_all_printed               li a0, LEDS_GREEN                                ; Lights green
                                 call set_leds
                                 j end_loop

; --- Set Leds ---
; Purpose: Enable/disable given LEDs
; Input: a0 = LED Colour
; Output: None
set_leds:
                                 la t0, LEDS_ADDRESS
                                 sb a0, [t0]
                                 ret


; --- STACK ---
STACK                            DEFS 128
STACK_END


; --- INCLUDES ---
include lcd.s
include utility.s
include capitals_table.s
0, p_str_row_overflow
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
