; -----------------------------------------------------------------------------------
;                              Calculator Functions
;                                 Oliver Harris
;
; Implements 64 bit integer arithmetic, and support for parsing and evaluating
; strings via converting to reverse polish notation, and evaluating the RPN.
;
; Buffers required (not allocated by library):
; - Input buffer: 1 bytes per character, null terminated string
; - Operator stack: 1 byte per operator, null terminated
; - Output stack: 8 bytes per operand, null terminated
;
; Last modified: 15/05/26
;
; -----------------------------------------------------------------------------------

; --- Library Constants ---

ERR_SUCCESS                EQU 0
ERR_OVERFLOW               EQU 1                                 ; overflow and underflow treated as same
ERR_DIV_ZERO               EQU 2
ERR_INTERNAL               EQU 4                                 ; unexpected internal error, ie. stack overflow

OPERAND_TYPE               EQU 0
OPERATOR_TYPE              EQU 1

PRECEDENCE_MUL_DIV         EQU 2
PRECEDENCE_ADD_SUB         EQU 1
PRECEDENCE_INVALID         EQU 0

; --- Helper Functions ---
; get_precedence
; Input: a0 = operator character
; Output: a0 = precedence
;         * or / = 2
;         + or - = 1
;         invalid operator = 0
; Modifies: t2
get_precedence:
                           li t2, '+'
                           beq a0, t2, get_precedence_add_sub
                           li t2, '-'
                           beq a0, t2, get_precedence_add_sub
                           li t2, '*'
                           beq a0, t2, get_precedence_mul_div
                           li t2, '/'
                           beq a0, t2, get_precedence_mul_div
                           li a0, PRECEDENCE_INVALID
                           j get_precedence_done

get_precedence_add_sub     li a0, PRECEDENCE_ADD_SUB
                           j get_precedence_done

get_precedence_mul_div     li a0, PRECEDENCE_MUL_DIV
                           j get_precedence_done

get_precedence_done        ret


; --- Library Functions ---

; shunting_yard
; Purpose: Parse the input buffer from infix notation, and convert to RPN with two stacks: one for operators, and one for output.
; Implements a modified version of the shunting yard algorithm, without parentheses.
; Note: no stack overflow checks implemented, assuming correct size is already allocated.
;
; Input: a0 = pointer to input buffer, a1 = pointer to operator stack, a2 = operator stack head, a3 = pointer to output stack, a4 = output stack head
;        Input buffer: null terminated 1 byte per character, with digits '0' to '9' and operators +, -, *, / only.
;        Output stack: 12 bytes fixed width, [type, high, low] or [type, padding, operator], head points to next free position.
;                 The padding wastes space, however it simplifies execution so is an acceptable trade-off.
;        Operator stack: 1 byte per operator, head points to next free position.
;
; Output: a0 = output stack head, a2 = error code (register used for consistency with all functions in library)
shunting_yard:
                           subi sp, sp, 24
                           sw s4, 20[sp]
                           sw s3, 16[sp]
                           sw s2, 12[sp]
                           sw s1, 8[sp]
                           sw s0, 4[sp]
                           sw ra, 0[sp]

                           mv s0, a0                             ; s0 = pointer to input buffer
                           mv s1, a1                             ; s1 = pointer to operator stack base
                           mv s2, a2                             ; s2 = operator stack head
                           mv s3, a3                             ; s3 = pointer to output stack base
                           mv s4, a4                             ; s4 = output stack head

parse_start                lbu t0, 0[s0]                         ; t0 = char
                           beqz t0, parse_err_success            ; if null terminator, done parsing

                           li t1, '0'
                           blt t0, t1, parse_operator            ; if character < '0', not a digit
                           li t1, '9'
                           bgt t0, t1, parse_operator            ; if character > '9', not a digit

parse_digit                li a0, 0                              ; a0 = value lower
                           li a1, 0                              ; a1 = value upper

parse_digit_loop           lbu t0, 0[s0]                         ; t0 = character

                           li t1, '0'
                           blt t0, t1, parse_digit_done          ; if character < '0', done parsing number
                           li t1, '9'
                           bgt t0, t1, parse_digit_done          ; if character > '9', done parsing number

                           li a2, 10
                           li a3, 0
                           call mul_64                           ; value *= 10
                           bnez a2, parse_err_num_overflow       ; check for errors

                           subi a2, t0, '0'                      ; convert character to integer
                           call add_64                           ; value += digit
                           bnez a2, parse_err_num_overflow       ; check for errors

                           addi s0, s0, 1                        ; move to next character
                           j parse_digit_loop

parse_digit_done           mul t0, s4, 12                        ; offset * 12
                           add t0, t0, s3                        ; point to base of new operand
                           sw zero, 0[t0]                        ; push operand type to output stack
                           sw a0, 4[t0]                          ; push value lower to output stack
                           sw a1, 8[t0]                          ; push value upper to output stack
                           addi s4, s4, 1                        ; increment output stack top

                           j parse_start

parse_operator_loop        beqz s2, parse_operator_done          ; if operator stack empty, done

                           add t1, s1, s2                        ; parse_operator_loop always called with t0 = current
                           subi t1, t1, 1
                           lbu t1, 0[t1]                         ; t1 = operator on top of stack

_compare_precedence        mv a0, t1
                           call get_precedence
                           beqz a0, parse_err_invalid            ; if invalid operator, error
                           mv a1, a0                             ; a1 = top precedence
                           mv a0, t0
                           call get_precedence                   ; a0 = current precedence
                           beqz a0, parse_err_invalid            ; if invalid operator, error

                           blt a1, a0, parse_operator_done       ; if: top precedence < current precedence, done
_pop_operator              subi s2, s2, 1                        ; else: pop operator stack
                           mul t2, s4, 12                        ; offset * 12
                           add t2, t2, s3
                           sw t1, 8[t2]                          ; push operator to output stack
                           sw zero, 4[t2]                        ; padding
                           li t1, OPERATOR_TYPE
                           sw t1, 0[t2]
                           addi s4, s4, 1                        ; increment output stack top
                           j parse_operator_loop

parse_operator_done        mv a0, t0
                           call get_precedence                   ; reuse get_precedence to check operator validity
                           beqz a0, parse_err_invalid            ; if invalid operator, error

_push_operator             add t1, s1, s2
                           sb t0, 0[t1]                          ; push operator to operator stack
                           addi s2, s2, 1                        ; increment operator stack top

                           addi s0, s0, 1                        ; move to next character
                           j parse_start

parse_err_invalid          li a2, ERR_INTERNAL
                           j parse_end

parse_err_num_overflow     li a2, ERR_OVERFLOW
                           j parse_end

parse_err_success          li a2, ERR_SUCCESS
                           j parse_pop_all_check


parse_pop_all_operators    subi s2, s2, 1                        ; pop operator stack
                           add t0, s1, s2
                           lbu t0, 0[t0]                         ; t0 = operator

                           mul t1, s4, 12                        ; offset * 12
                           add t1, t1, s3
                           sw t0, 8[t1]                          ; push operator to output stack
                           sw zero, 4[t1]                        ; padding
                           li t0, OPERATOR_TYPE
                           sw t0, 0[t1]
                           addi s4, s4, 1                        ; increment output stack top
parse_pop_all_check        bnez s2, parse_pop_all_operators      ; if operator stack not empty, continue popping
                           mv a0, s4                             ; else return output stack head in a0

parse_end                  lw ra, 0[sp]
                           lw s0, 4[sp]
                           lw s1, 8[sp]
                           lw s2, 12[sp]
                           lw s3, 16[sp]
                           lw s4, 20[sp]
                           addi sp, sp, 24
                           ret


; evaluate_rpn
; Purpose: Evaluate the expression in reverse polish notation, and return the result.
; Input: a0 = pointer to operator stack, a1 = pointer to operator stack top, a2 = pointer to output stack, a3 = pointer to output stack top, a4 = stack size
; Output: a0 = result lower, a1 = result upper, a2 = error code
evaluate_rpn:              subi sp, sp, 24
                           sw s4, 20[sp]
                           sw s3, 16[sp]
                           sw s2, 12[sp]
                           sw s1, 8[sp]
                           sw s0, 4[sp]
                           sw ra, 0[sp]

                           mv s0, a0                             ; s0 = pointer to operator stack
                           mv s1, a1                             ; s1 = pointer to operator stack top
                           mv s2, a2                             ; s2 = pointer to output stack
                           mv s3, a3                             ; s3 = pointer to output stack top
                           mv s4, a4                             ; s4 = stack size
                           j eval_loop_start

eval_loop_start            lbu t0, 0[s3]                         ; t0 = output stack top
                           subi t0, t0, 2
                           bltz t0, eval_err_internal            ; stack underflow if < 0
                           sb t0, 0[s3]                          ; pop twice from output stack

                           slli t0, t0, 3                        ; offset * 8
                           add t0, t0, s2                        ; point to base of operands
                           lw a0, 0[t0]                          ; operand 2 lower
                           lw a1, 4[t0]                          ; operand 2 upper
                           lw a2, 8[t0]                          ; operand 1 lower
                           lw a3, 12[t0]                         ; operand 1 upper

                           lbu t0, 0[s1]                         ; t0 = operator stack top
                           subi t0, t0, 1                        ; move operator stack top down
                           bltz t0, eval_err_internal            ; stack underflow if < 0
                           sb t0, 0[s1]                          ; pop operator stack

                           add t0, t0, s0                        ; t0 = pointer to operator
                           lb t0, 0[t0]                          ; t0 = operator

eval_loop_op               li t1, '+'
                           beq t0, t1, eval_loop_add
                           li t1, '-'
                           beq t0, t1, eval_loop_sub
                           li t1, '*'
                           beq t0, t1, eval_loop_mul
                           li t1, '/'
                           beq t0, t1, eval_loop_div
                           j eval_err_internal

eval_loop_add              call add_64
                           bnez a2, evaluate_end
                           j eval_loop_push_result

eval_loop_sub              call sub_64
                           bnez a2, evaluate_end
                           j eval_loop_push_result

eval_loop_mul              call mul_64
                           bnez a2, evaluate_end
                           j eval_loop_push_result

eval_loop_div              call div_64
                           bnez a2, evaluate_end
                           j eval_loop_push_result

eval_loop_push_result      lbu t0, 0[s3]                         ; t0 = output stack top
                           addi t0, t0, 1                        ; push result to output stack
                           bgeu t0, s4, eval_err_internal        ; stack < max, otherwise overflow
                           sb t0, 0[s3]                          ; increment output stack top
                           addi t0, t0, -1                       ; index of new top element
                           slli t0, t0, 3                        ; offset * 8
                           add t0, t0, s2                        ; point to base of operands
                           sw a0, 0[t0]                          ; push result lower to output stack
                           sw a1, 4[t0]                          ; push result upper to output stack
                           j eval_loop_check

eval_loop_check            lbu t0, 0[s3]                         ; t0 = output stack top
                           li t1, 1
                           bgtu t0, t1, eval_loop_start          ; if outputs > 1, continue eval
                           beqz t0, eval_err_internal            ; if no outputs, error
eval_err_success           lw a0, 0[s2]                          ; result lower
                           lw a1, 4[s2]                          ; result upper
                           li a2, ERR_SUCCESS
                           j evaluate_end

eval_err_internal          li a2, ERR_INTERNAL
                           j evaluate_end


parse_err_invalid          li a2, ERR_INTERNAL
                           j parse_end

parse_err_num_overflow     li a2, ERR_OVERFLOW
                           j parse_end

parse_err_success          li a2, ERR_SUCCESS
                           mv a0, s4                             ; a0 = output stack head

parse_end                  lw ra, 0[sp]
                           lw s0, 4[sp]
                           lw s1, 8[sp]
                           lw s2, 12[sp]
                           lw s3, 16[sp]
                           lw s4, 20[sp]
                           addi sp, sp, 24
                           ret


; evaluate_rpn
; Purpose: Evaluate the expression in reverse polish notation, and return the result.
; Input: a0 = pointer to operator stack, a1 = pointer to operator stack top, a2 = pointer to output stack, a3 = pointer to output stack top, a4 = stack size
; Output: a0 = result lower, a1 = result upper, a2 = error code
evaluate_rpn:              subi sp, sp, 24

evaluate_end               lw ra, 0[sp]
                           lw s0, 4[sp]
                           lw s1, 8[sp]
                           lw s2, 12[sp]
                           lw s3, 16[sp]
                           lw s4, 20[sp]
                           addi sp, sp, 24
                           ret



; --- Mathematical Functions ---
; Consistent 64 bit integer signed arithmetic functions, with error handling for overflow and division by zero.
; Input: a0 = operand 1 lower, a1 = operand 1 upper, a2 = operand 2 lower, a3 = operand 2 upper
; Output: a0 = result lower, a1 = result upper, a2 = error code

; add_64
; Purpose: Add two 64 bit integers using carry, with overflow detection.
; Formula: l_res = l_1 + l2, u_res = u_1 + u_2 + carry, carry = 1 if l_res < l_1
; Cost: cheap
add_64:
                           add t0, a0, a2                        ; t0 = lower bits sum
                           sltu t1, t0, a0                       ; t1 = carry from lower bits

                           add t2, a1, a3                        ; t2 = upper bits sum
                           add a1, t2, t1                        ; t2 = upper bits sum + carry

                           sltu a2, a1, t2                       ; a2 = 1 if overflow in upper bits
                           mv a0, t0
                           ret


; sub_64
; Purpose: Subtract two 64 bit integers using borrow, with underflow detection.
; Formula: l_res = l_1 - l2, u_res = u_1 - u_2 - borrow, borrow = 1 if l_1 < l_2
; Cost: cheap
sub_64
                           sub t0, a0, a2                        ; t0 = lower bits difference
                           sltu t1, a0, a2                       ; t1 = 1 if borrow in lower bits

                           sub t2, a1, a3                        ; t2 = upper bits difference
                           sub a1, t2, t1                        ; subtract borrow from upper bits

                           sltu a2, t2, a1                       ; a2 = 1 if overflow in upper bits
                           mv a0, t0
                           ret

; mul_64
; Purpose: Multiply two 64 bit integers, only returns lower 64 bits of result, with overflow detection.
; Formula: l_res = l(l_1 *  and display note on LCD.l_2), u_res = u(l_1 * l_2) + l(u_1 * l_2) + l(l_1 * u_2)
; Cost: very expensive, requires both multiplication and division for overflow detection
mul_64
                           subi sp, sp, 12
                           sw ra, [sp]
                           sw s0, 4[sp]
                           sw s1, 8[sp]

                           mul s0, a0, a2                        ; low 32 bits of l_1 * l_2

                           mulhu s1, a0, a2                      ; high 32 bits of l_1 * l_2
                           mul t1, a1, a2                        ; l(u_1 * l_2), cross product 1
                           mul t2, a0, a3                        ; l(l_1 * u_2), cross product 2

                           add s1, s1, t1                        ; sum upper bits
                           add s1, s1, t2                        ; s1 = upper bits

mul_overflow               mv a0, s0
                           mv a1, s1
                           li a2, 0                              ; ignore overflow for now

                           lw s1, 8[sp]
                           lw s0, 4[sp]
                           lw ra, [sp]
                           addi sp, sp, 12
                           ret



mul_64_overflow

; if int_1 != 0 and res / int1 != int_2, then overflow



; div_64
; Purpose: implements long division for 64 bit integers.
; Returns quotient of operand 1 / operand 2.
; Cost: expensive, requires lots of iterations in worst case
div_64                     or t0, a2, a3                         ; if operand 2 is zero, error
                           beqz t0, div_64_loop

div_64_loop



div_64_by_zero             li a2, ERR_DIV_ZERO
                           ret
