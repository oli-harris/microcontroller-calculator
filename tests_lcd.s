;---------------------------------------------
;   Tests for LCD (using generative ai)
;    Oliver Harris, Claude Sonnet 4.5
;
; Last modified: 17/02/26
;
;---------------------------------------------
         la sp, STACK_END

; --- TESTS ---

; test_clear_screen
; OUTPUT: "Sam" (clears "Bob" first)
test_clear_screen:
                  li a0, 'B'
                  call write_char
                  li a0, 'o'
                  call write_char
                  li a0, 'b'
                  call write_char
                  li a0, '\f'              ; clear screen
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
                  li a0, '\n'              ; newline
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

; test_carriage_return
; OUTPUT: "XXX" (overwrites "ABC")
test_carriage_return:
                  li a0, '\f'
                  call write_char
                  li a0, 'A'
                  call write_char
                  li a0, 'B'
                  call write_char
                  li a0, 'C'
                  call write_char
                  li a0, '\r'              ; return to start
                  call write_char
                  li a0, 'X'
                  call write_char
                  li a0, 'X'
                  call write_char
                  li a0, 'X'
                  call write_char
                  j end

; test_backspace
; OUTPUT: "Test" (deletes extra 't')
test_backspace:
                  li a0, '\f'
                  call write_char
                  li a0, 'T'
                  call write_char
                  li a0, 'e'
                  call write_char
                  li a0, 's'
                  call write_char
                  li a0, 't'
                  call write_char
                  li a0, 't'
                  call write_char
                  li a0, '\b'              ; backspace
                  call write_char
                  li a0, ' '               ; clear the extra char
                  call write_char
                  j end

; test_tab
; OUTPUT: "A    B" (tabs between A and B)
test_tab:
                  li a0, '\f'
                  call write_char
                  li a0, 'A'
                  call write_char
                  li a0, '\t'              ; tab
                  call write_char
                  li a0, '\t'
                  call write_char
                  li a0, '\t'
                  call write_char
                  li a0, 'B'
                  call write_char
                  j end

; test_vertical_tab
; OUTPUT: Line 1: (empty)
;         Line 2: "Down"
test_vertical_tab:
                  li a0, '\f'
                  call write_char
                  li a0, '\v'              ; move down
                  call write_char
                  li a0, 'D'
                  call write_char
                  li a0, 'o'
                  call write_char
                  li a0, 'w'
                  call write_char
                  li a0, 'n'
                  call write_char
                  j end

; test_hello_world
; OUTPUT: Line 1: "Hello"
;         Line 2: "World"
test_hello_world:
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
                  li a0, '\n'
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

; test_carriage_both_lines
; OUTPUT: Line 1: "XXX" (overwrites "ABC")
;         Line 2: "YYY" (overwrites "DEF")
; Tests that \r tracks which line it's on
test_carriage_both_lines:
                  li a0, '\f'
                  call write_char
                  ; Line 1: write ABC
                  li a0, 'A'
                  call write_char
                  li a0, 'B'
                  call write_char
                  li a0, 'C'
                  call write_char
                  ; Move to line 2
                  li a0, '\n'
                  call write_char
                  ; Line 2: write DEF
                  li a0, 'D'
                  call write_char
                  li a0, 'E'
                  call write_char
                  li a0, 'F'
                  call write_char
                  ; Carriage return on line 2 (should stay on line 2)
                  li a0, '\r'
                  call write_char
                  ; Overwrite with YYY (should be on line 2)
                  li a0, 'Y'
                  call write_char
                  li a0, 'Y'
                  call write_char
                  li a0, 'Y'
                  call write_char
                  ; Move back to line 1
                  li a0, '\v'              ; or implement a "move up" command
                  call write_char
                  ; Carriage return on line 1
                  li a0, '\r'
                  call write_char
                  ; Overwrite with XXX (should be on line 1)
                  li a0, 'X'
                  call write_char
                  li a0, 'X'
                  call write_char
                  li a0, 'X'
                  call write_char
                  j end


; --- END TESTS ---

end               j .

; --- STACK ---

STACK             DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
