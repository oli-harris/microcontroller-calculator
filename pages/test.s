; -----------------------------------------------------------------------------
;                              Test Page
;                            Oliver Harris
;
; Implements a test page, which can be navigated with the buttons.
;
; Known issues: may cause 5 and 1 errors.*
;
; Last modified: 13/05/26
; -----------------------------------------------------------------------------

; --- Test Pages ---

current_test_page    DEFB 0

TEST_UNTESTED        EQU 0
TEST_PASS            EQU 1
TEST_FAIL            EQU 2

TEST_UNTESTED_STR    DEFB "\n- Run Test", 0
TEST_PASS_STR        DEFB "\n- PASS :)", 0
TEST_FAIL_STR        DEFB "\n- FAIL :(", 0
                     align

test_str_table       defw TEST_UNTESTED_STR, TEST_PASS_STR, TEST_FAIL_STR

test_buttons         defw test_home
                     defw test_okay
                     defw test_left
test_buttons_end     defw test_right

; test_handler
; Purpose: Handle button presses, then call test_render to update test page.
; Input: a0 = button pressed
test_handler         subi sp, sp, 4
                     sw ra, [sp]

                     subi t0, a0, KEYBOARD_BUTTONS                           ; t0 = index (0-3 expected)
                     li t1, (test_buttons_end - test_buttons) / 4
                     bgtu t0, t1, test_handler_end                           ; If index is out of bounds, return to main loop

                     slli t0, t0, 2
                     la t1, test_buttons
                     add t0, t0, t1                                          ; t0 = address of appropriate handler
                     lw t0, [t0]
                     jalr t0                                                 ; Jump to appropriate handler, then continue

                     li a0, 0
                     call test_render                                        ; Render test page after handling button press

test_handler_end     lw ra, [sp]
                     addi sp, sp, 4
                     ret

; test_init
; Purpose: Initialise test page and render it for the first time.
test_init            subi sp, sp, 4
                     sw ra, [sp]

                     la t0, current_test_page
                     sb zero, [t0]                                           ; Set current test page to 0

                     call test_render

                     lw ra, [sp]
                     addi sp, sp, 4
                     ret

; test_render
; Purpose: Render test page based on current state and test page.
; Modifies: t0, a0, a1
test_render          subi sp, sp, 8
                     sw s0, 4[sp]
                     sw ra, [sp]

                     li a0, '\f'                                             ; Clear screen
                     call write_char

                     la s0, current_test_page
                     lb s0, [s0]        menu_init                            ; s0 = current test page

                     addi a0, s0, 1                                          ; Displays 'hex page number) '
                     li a1, 2
                     call write_hex

                     li a0, ')'
                     call write_char

                     li a0, ' '
                     call write_char

                     la t0, TESTS_TABLE                                      ; Display test name
                     slli t1, s0, 4                                          ; t0 = offset of current test (16 bytes per test)
                     add t0, t1, t0                                          ; t0 = address of current test in TESTS_TABLE

                     lw a0, 4[t0]                                            ; a0 = address of test string
                     call write_string


                     la t0, TESTS_RESULTS                                    ; Display test result
                     add t0, t0, s0                                          ; t0 = address of current test result
                     lb t0, [t0]                                             ; t0 = current test result
                     la t1, test_str_table
                     slli t0, t0, 2                                          ; t0 = current test result * 4 (4 bytes per pointer)
                     add t0, t0, t1                                          ; t0 = address of appropriate result string
                     lw a0, [t0]                                             ; a0 = address of appropriate result string
                     call write_string

                     lw ra, [sp]
                     lw s0, 4[sp]
                     addi sp, sp, 8
                     ret


test_home            ret

; test_okay
; Purpose: Run test, and update PASS/FAIL
; For debugging, place a breakpoint and check value of registers a0 and a1
test_okay:           subi sp, sp, 8
                     sw s0, 4[sp]
                     sw ra, [sp]

                     la t0, current_test_page
                     lb t0, [t0]                                             ; t0 = current test page

                     la t1, TESTS_TABLE
                     slli t0, t0, 4                                          ; t0 = offset of current test (16 bytes per test)
                     add s0, t0, t1                                          ; s0 = address of current test in TESTS_TABLE

                     lw t0, [s0]
                     jalr t0                                                 ; Run test

                     lw t1, 8[s0]                                            ; t1 = pointer to upper expected value
                     lw t0, 12[s0]                                           ; t0 = pointer to lower expected value
                     lw t1, [t1]                                             ; t1 = upper expected value
                     lw t0, [t0]                                             ; t0 = lower expected value

                     la s0, current_test_page                                ; s0 reused for address of current test page
                     lb s0, [s0]

                     bne a0, t0, test_okay_fail                              ; If either value is not as expected, test fails
                     bne a1, t1, test_okay_fail

                     li t0, TEST_PASS                                        ; Test passed if both values are as expected
                     j test_okay_end

test_okay_fail       li t0, TEST_FAIL

test_okay_end        la t1, TESTS_RESULTS                                    ; Store result
                     add t1, t1, s0
                     sb t0, [t1]

                     lw ra, [sp]
                     lw s0, 4[sp]
                     addi sp, sp, 8
                     ret




; test_left
; Purpose: Handler for left button, decrements menu page without wrapping.
test_left:
                     la t0, current_test_page
                     lb t1, [t0]                                             ; t1 = current menu page
                     blez t1, test_left_end                                  ; If on page 0, don't decrement
                     subi t1, t1, 1                                          ; Move page left
                     sb t1, [t0]
test_left_end        ret

; test_right
; Purpose: Handler for right button, increments menu page without wrapping.
test_right:
                     la t0, current_test_page
                     lb t1, [t0]
                     li t2, TEST_PAGES - 1
                     bgeu t1, t2, test_right_end                             ; If on last page, don't increment
                     addi t1, t1, 1                                          ; Move page right
                     sb t1, [t0]
test_right_end       ret




; --- Tests ---

; Test Table
; Function pointer, string pointer, upper expected value pointer, lower expected value pointer
TESTS_TABLE          defw test_1, test1_str, test1_upper, test1_lower
                     defw test_2, test2_str, test2_upper, test2_lower
                     defw test_3, test3_str, test3_upper, test3_lower
TESTS_TABLE_END

TESTS_RESULTS        defb 0, 0, 0
                     align

TEST_PAGES           EQU (TESTS_TABLE_END - TESTS_TABLE) / 16

; test 1
test1_upper          DEFW 0
test1_lower          DEFW 4
test1_str            defb "2 + 2", 0
                     align

test_1               li a0, 4
                     li a1, 0
                     ret

; test 2
test2_upper          DEFW 0
test2_lower          DEFW 5
test2_str            defb "2 + 3", 0
                     align

test_2               li a0, 5
                     li a1, 0
                     ret

; test 3
test3_upper          DEFW 0
test3_lower          DEFW 5
test3_str            defb "2 + 3", 0
                     align

test_3               li a0, 6
                     li a1, 0
                     ret



test_home            ret

; test_okay
; Purpose: Run test, and update PASS/FAIL
; For debugging, place a breakpoint and check value of registers a0 and a1
test_okay:           subi sp, sp, 8
                     sw s0, 4[sp]
                     sw ra, [sp]

                     la t0, current_test_page
                     lb t0, [t0]                                             ; t0 = current test page

                     la t1, TESTS_TABLE
                     slli t0, t0, 4                                          ; t0 = offset of current test (16 bytes per test)
                     add s0, t0, t1                                          ; s0 = address of current test in TESTS_TABLE

                     lw t0, [s0]
                     jalr t0                                                 ; Run test

                     lw t1, 8[s0]                                            ; t1 = pointer to upper expected value
                     lw t0, 12[s0]                                           ; t0 = pointer to lower expected value
                     lw t1, [t1]                                             ; t1 = upper expected value
                     lw t0, [t0]                                             ; t0 = lower expected value

                     la s0, current_test_page                                ; s0 reused for address of current test page
                     lb s0, [s0]

                     bne a0, t0, test_okay_fail                              ; If either value is not as expected, test fails
                     bne a1, t1, test_okay_fail

                     li t0, TEST_PASS                                        ; Test passed if both values are as expected
                     j test_okay_end

test_okay_fail       li t0, TEST_FAIL

test_okay_end        la t1, TESTS_RESULTS                                    ; Store result
                     add t1, t1, s0
                     sb t0, [t1]

                     lw ra, [sp]
                     lw s0, 4[sp]
                     addi sp, sp, 8
                     ret




; test_left
; Purpose: Handler for left button, decrements menu page without wrapping.
test_left:
                     la t0, current_test_page
                     lb t1, [t0]                                             ; t1 = current menu page
                     blez t1, test_left_end                                  ; If on page 0, don't decrement
                     subi t1, t1, 1                                          ; Move page left
                     sb t1, [t0]
test_left_end        ret

; test_right
; Purpose: Handler for right button, increments menu page without wrapping.
test_right:
                     la t0, current_test_page
                     lb t1, [t0]
                     li t2, TEST_PAGES - 1
                     bgeu t1, t2, test_right_end                             ; If on last page, don't increment
                     addi t1, t1, 1                                          ; Move page right
                     sb t1, [t0]
test_right_end       ret




; --- Tests ---

; Test Table
; Function pointer, string pointer, upper expected value pointer, lower expected value pointer
TESTS_TABLE          defw test_1, test1_str, test1_upper, test1_lower
                     defw test_2, test2_str, test2_upper, test2_lower
                     defw test_3, test3_str, test3_upper, test3_lower
TESTS_TABLE_END

TESTS_RESULTS        defb 0, 0, 0
                     align

TEST_PAGES           EQU (TESTS_TABLE_END - TESTS_TABLE) / 16

; test 1
test1_upper          DEFW 0
test1_lower          DEFW 4
test1_str            defb "2 + 2", 0
                     align

test_1               li a0, 4
                     li a1, 0
                     ret

; test 2
test2_upper          DEFW 0
test2_lower          DEFW 5
test2_str            defb "2 + 3", 0
                     align

test_2               li a0, 5
                     li a1, 0
                     ret

; test 3
test3_upper          DEFW 0
test3_lower          DEFW 5
test3_str            defb "2 + 3", 0
                     align

test_3               li a0, 6
                     li a1, 0
                     ret

