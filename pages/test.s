; -----------------------------------------------------------------------------
;                              Test Page
;                            Oliver Harris
;
; Implements a test page, which can be navigated with the buttons.
; Used to demonstrate and verify functionality of library functions,
; by running tests and presenting the results in a user friendly way
; using the menu and pages system.
;
; Known issues: may cause 5 and 1 errors.*
; Requires: calc.s and calculator.s page
;
; Last modified: 13/05/26
; -----------------------------------------------------------------------------

; --- Test Pages ---

current_test_page     DEFB 0

TEST_UNTESTED         EQU 0
TEST_PASS             EQU 1
TEST_FAIL             EQU 2

TEST_UNTESTED_STR     DEFB "\n- Run Test", 0
TEST_PASS_STR         DEFB "\n- PASS :)", 0
TEST_FAIL_STR         DEFB "\n- FAIL :(", 0
                      align

test_str_table        defw TEST_UNTESTED_STR, TEST_PASS_STR, TEST_FAIL_STR

test_buttons          defw test_home
                      defw test_okay
                      defw test_left
test_buttons_end      defw test_right

; test_handler
; Purpose: Handle button presses, then call test_render to update test page.
; Input: a0 = button pressed
test_handler          subi sp, sp, 4
                      sw ra, [sp]

                      subi t0, a0, KEYBOARD_BUTTONS                                              ; t0 = index (0-3 expected)
                      li t1, (test_buttons_end - test_buttons) / 4
                      bgtu t0, t1, test_handler_end                                              ; If index is out of bounds, return to main loop

                      slli t0, t0, 2
                      la t1, test_buttons
                      add t0, t0, t1                                                             ; t0 = address of appropriate handler
                      lw t0, [t0]
                      jalr t0                                                                    ; Jump to appropriate handler, then continue

test_handler_end      lw ra, [sp]
                      addi sp, sp, 4
                      ret

; test_init
; Purpose: Initialise test page and render it for the first time.
test_init             subi sp, sp, 4
                      sw ra, [sp]

                      la t0, current_test_page
                      sb zero, [t0]                                                              ; Set current test page to 0

                      call test_render

                      lw ra, [sp]
                      addi sp, sp, 4
                      ret

; test_render
; Purpose: Render test page based on current state and test page.
; Modifies: t0, a0, a1
test_render           subi sp, sp, 8
                      sw s0, 4[sp]
                      sw ra, [sp]

                      li a0, '\f'                                                                ; Clear screen
                      call write_char

                      la s0, current_test_page
                      lb s0, [s0]                                                                ; s0 = current test page

                      addi a0, s0, 1                                                             ; Displays 'hex page number) '
                      li a1, 2
                      call write_hex

                      li a0, ')'
                      call write_char

                      li a0, ' '
                      call write_char

                      la t0, TESTS_TABLE                                                         ; Display test name
                      slli t1, s0, 4                                                             ; t0 = offset of current test (16 bytes per test)
                      add t0, t1, t0                                                             ; t0 = address of current test in TESTS_TABLE

                      lw a0, 4[t0]                                                               ; a0 = address of test string
                      call write_string


                      la t0, TESTS_RESULTS                                                       ; Display test result
                      add t0, t0, s0                                                             ; t0 = address of current test result
                      lb t0, [t0]                                                                ; t0 = current test result
                      la t1, test_str_table
                      slli t0, t0, 2                                                             ; t0 = current test result * 4 (4 bytes per pointer)
                      add t0, t0, t1                                                             ; t0 = address of appropriate result string
                      lw a0, [t0]                                                                ; a0 = address of appropriate result string
                      call write_string

                      lw ra, [sp]
                      lw s0, 4[sp]
                      addi sp, sp, 8
                      ret

; --- Button Handlers ---

test_home             ret

; test_okay
; Purpose: Run test, verify a0 and a1 values, and update PASS/FAIL
; For debugging, place a breakpoint and check value of registers a0 and a1
test_okay:            subi sp, sp, 8
                      sw s0, 4[sp]
                      sw ra, [sp]

                      la t0, current_test_page
                      lb t0, [t0]                                                                ; t0 = current test page

                      la t1, TESTS_TABLE
                      slli t0, t0, 4                                                             ; t0 = offset of current test (16 bytes per test)
                      add s0, t0, t1                                                             ; s0 = address of current test in TESTS_TABLE

                      lw t0, [s0]
                      jalr t0                                                                    ; Run test

test_ret              lw t0, 8[s0]                                                               ; t0 = expected a0 (BREAKPOINT HERE)
                      lw t1, 12[s0]                                                              ; t1 = expected a1
                      lw t0, [t0]                                                                ; t0 = lower expected value
                      lw t1, [t1]                                                                ; t1 = upper expected value

                      la s0, current_test_page                                                   ; s0 reused for address of current test page
                      lb s0, [s0]

                      xor t0, t0, a0                                                             ; 0 if lower pass
                      xor t1, t1, a1                                                             ; 0 if upper pass
                      or t0, t0, t1                                                              ; 0 if both pass, non-zero if either fails
                      bnez t0, test_okay_fail                                                    ; If either value is not as expected, test fails

                      li t0, TEST_PASS                                                           ; Test passed if both values are as expected
                      j test_okay_end

test_okay_fail        li t0, TEST_FAIL

test_okay_end         la t1, TESTS_RESULTS                                                       ; Store result
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
                      lb t1, [t0]                                                                ; t1 = current menu page
                      blez t1, test_left_end                                                     ; If on page 0, don't decrement
                      subi t1, t1, 1                                                             ; Move page left
                      sb t1, [t0]
test_left_end         ret

; test_right
; Purpose: Handler for right button, increments menu page without wrapping.
test_right:
                      la t0, current_test_page
                      lb t1, [t0]
                      li t2, TEST_PAGES - 1
                      bgeu t1, t2, test_right_end                                                ; If on last page, don't increment
                      addi t1, t1, 1                                                             ; Move page right
                      sb t1, [t0]
test_right_end        ret




; --- Tests ---

; Test Table
; Function pointer, string pointer, a0 value, a1 value
TESTS_TABLE           defw test_add_1, test_add_1_str, test_add_1_lower, test_add_1_upper
                      defw test_add_2, test_add_2_str, test_add_2_lower, test_add_2_upper
                      defw test_add_3, test_add_3_str, test_add_3_lower, test_add_3_upper
                      defw test_sub_1, test_sub_1_str, test_sub_1_lower, test_sub_1_upper
                      defw test_sub_2, test_sub_2_str, test_sub_2_lower, test_sub_2_upper
                      defw test_sub_3, test_sub_3_str, test_sub_3_lower, test_sub_3_upper
                      defw test_mul_1, test_mul_1_str, test_mul_1_lower, test_mul_1_upper
                      defw test_mul_2, test_mul_2_str, test_mul_2_lower, test_mul_2_upper
                      defw test_mul_3, test_mul_3_str, test_mul_3_lower, test_mul_3_upper
                      defw test_mul_4, test_mul_4_str, test_mul_4_lower, test_mul_4_upper
                      defw test_div_1, test_div_1_str, test_div_1_lower, test_div_1_upper
                      defw test_div_2, test_div_2_str, test_div_2_lower, test_div_2_upper
                      defw test_div_3, test_div_3_str, test_div_3_lower, test_div_3_upper
                      defw test_eval_1, test_eval_1_str, test_eval_1_lower, test_eval_1_upper
                      defw test_eval_2, test_eval_2_str, test_eval_2_lower, test_eval_2_upper
                      defw test_eval_3, test_eval_3_str, test_eval_3_lower, test_eval_3_upper
TESTS_TABLE_END

TESTS_RESULTS         defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      align

TEST_PAGES            EQU (TESTS_TABLE_END - TESTS_TABLE) / 16

; Test Functions
test_add_1_upper      DEFW 0
test_add_1_lower      DEFW 3_000_000_000
test_add_1_str        defb "Add64 lower", 0
                      align

test_add_1            li a0, 1_000_000_000
                      li a1, 0
                      li a2, 2_000_000_000
                      li a3, 0
                      call add_64
                      j test_ret
; test 2
test_add_2_upper      DEFW 1
test_add_2_lower      DEFW 0x00000020
test_add_2_str        defb "Add64 carry", 0
                      align

test_add_2            li a0, 0xFFFFFFF0
                      li a1, 0
                      li a2, 0x00000030
                      li a3, 0
                      call add_64
                      j test_ret


test_add_3_upper      DEFW 0
test_add_3_lower      DEFW ERR_OVERFLOW
test_add_3_str        defb "Add64 error", 0
                      align

test_add_3            li a0, 0xFFFFFFFF
                      li a1, 0xFFFFFFFF
                      li a2, 1
                      li a3, 0
                      call add_64
                      mv a0, a2
                      li a1, 0
                      j test_ret


test_sub_1_upper      DEFW 0
test_sub_1_lower      DEFW 2_000_000_000
test_sub_1_str        defb "Sub64: lower bits", 0
                      align

test_sub_1            li a0, 3_000_000_000
                      li a1, 0
                      li a2, 1_000_000_000
                      li a3, 0
                      call sub_64
                      j test_ret


test_sub_2_upper      DEFW 0
test_sub_2_lower      DEFW 0xFFFFFFFF
test_sub_2_str        defb "Sub64 borrow", 0
                      align

test_sub_2            li a0, 0
                      li a1, 1
                      li a2, 1
                      li a3, 0
                      call sub_64
                      j test_ret


test_sub_3_upper      DEFW 0
test_sub_3_lower      DEFW ERR_OVERFLOW
test_sub_3_str        defb "Sub64 error", 0
                      align

test_sub_3            li a0, 0
                      li a1, 0
                      li a2, 1
                      li a3, 0
                      call sub_64
                      mv a0, a2
                      li a1, 0
                      j test_ret


test_mul_1_upper      DEFW 0
test_mul_1_lower      DEFW 12
test_mul_1_str        defb "Mul64 32", 0
                      align

test_mul_1            li a0, 3
                      li a1, 0
                      li a2, 4
                      li a3, 0
                      call mul_64
                      j test_ret


test_mul_2_upper      DEFW 1
test_mul_2_lower      DEFW 0
test_mul_2_str        defb "Mul64 32->64", 0
                      align

test_mul_2            li a0, 0x00010000
                      li a1, 0
                      li a2, 0x00010000
                      li a3, 0
                      call mul_64
                      j test_ret


test_mul_3_upper      DEFW 0xDFFFFFFF
test_mul_3_lower      DEFW 0xFFFFFFF9
test_mul_3_str        defb "Mul64 64*32", 0
                      align

test_mul_3            li a0, 0xFFFFFFFF
                      li a1, 0x1FFFFFFF
                      li a2, 7
                      li a3, 0
                      call mul_64
                      j test_ret


test_mul_4_upper      DEFW 0
test_mul_4_lower      DEFW ERR_OVERFLOW
test_mul_4_str        defb "Mul64 error", 0
                      align

test_mul_4            li a0, 0
                      li a1, 1
                      li a2, 0
                      li a3, 1
                      call mul_64
                      mv a0, a2
                      li a1, 0
                      j test_ret


test_div_1_upper      DEFW 0
test_div_1_lower      DEFW 4
test_div_1_str        defb "Div64 lower", 0
                      align

test_div_1            li a0, 12
                      li a1, 0
                      li a2, 3
                      li a3, 0
                      call div_64
                      j test_ret


test_div_2_upper      DEFW 0
test_div_2_lower      DEFW 0x80000000
test_div_2_str        defb "Div64 u+l", 0
                      align

test_div_2            li a0, 0
                      li a1, 1
                      li a2, 2
                      li a3, 0
                      call div_64
                      j test_ret


test_div_3_upper      DEFW 0
test_div_3_lower      DEFW ERR_DIV_ZERO
test_div_3_str        defb "Div64 0error", 0
                      align

test_div_3            li a0, 1
                      li a1, 0
                      li a2, 0
                      li a3, 0
                      call div_64
                      mv a0, a2
                      li a1, 0
                      j test_ret

; --- Calc tests ---


test_eval_1_buffer    defb "3+8*4-2", 0
                      align
test_eval_1_upper     DEFW 0
test_eval_1_lower     DEFW 33
test_eval_1_str       defb "Eval 3+8*4-2", 0
                      align

test_eval_1           la a0, test_eval_1_buffer
                      la a1, operator_stack
                      li a2, 0
                      la a3, output_stack
                      li a4, 0
                      call shunting_yard
                      bnez a2, test_eval_1_fail                                                  ; Exit early if non-zero error code

                      mv a1, a0
                      la a0, output_stack
                      call evaluate_rpn
                      bnez a2, test_eval_1_fail                                                  ; Exit early if non-zero error code
                      j test_eval_1_end

test_eval_1_fail      li a0, 0
                      j test_eval_1_end

test_eval_1_end       j test_ret


test_eval_2_buffer    defb "50+70*13+92-64*11+12-5+60*2", 0
                      align
test_eval_2_upper     DEFW 0
test_eval_2_lower     DEFW 475
test_eval_2_str       defb "Eval COMPLEX", 0
                      align

test_eval_2           la a0, test_eval_2_buffer
                      la a1, operator_stack
                      li a2, 0
                      la a3, output_stack
                      li a4, 0
                      call shunting_yard
                      bnez a2, test_eval_2_fail

                      mv a1, a0
                      la a0, output_stack
                      call evaluate_rpn
                      bnez a2, test_eval_2_fail
                      j test_eval_2_end

test_eval_2_fail      li a0, 0
                      j test_eval_2_end

test_eval_2_end       j test_ret


test_eval_3_buffer    defb "20+6/3*4-5", 0
                      align
test_eval_3_upper     DEFW 0
test_eval_3_lower     DEFW 23
test_eval_3_str       defb "Eval 20+6/3*4-5", 0
                      align

test_eval_3           la a0, test_eval_3_buffer
                      la a1, operator_stack
                      li a2, 0
                      la a3, output_stack
                      li a4, 0
                      call shunting_yard
                      bnez a2, test_eval_3_fail

                      mv a1, a0
                      la a0, output_stack
                      call evaluate_rpn
                      bnez a2, test_eval_3_fail
                      j test_eval_3_end

test_eval_3_fail      li a0, 0
                      j test_eval_3_end

test_eval_3_end       j test_ret


