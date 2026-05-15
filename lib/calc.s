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

ERR_SUCCESS               EQU 0
ERR_DIV_ZERO              EQU 1
ERR_INVALID_CHAR          EQU 2
ERR_OVERFLOW              EQU 3  
ERR_INTERNAL              EQU 4  ; unexpected internal error, ie. stack overflow 


; --- Library Functions ---

; shunting_yard
; Purpose: Parse the input buffer, and convert to two stacks: one for operators, and one for operands. 
; Implements a modified version of the shunting yard algorithm, without parentheses.
; Input: a0 = pointer to input buffer, a1 = pointer to operator stack, a2 = pointer to operator stack top, a3 = pointer to output stack, a4 = pointer to output stack top
; Output: a0 = error code
shunting_yard:
                          subi sp, sp, 24
                          sw s4, 20[sp]
                          sw s3, 16[sp]
                          sw s2, 12[sp]  
                          sw s1, 8[sp]   
                          sw s0, 4[sp]   
                          sw ra, 0[sp]  

                          mv s0, a0  ; s0 = pointer to input buffer
                          mv s1, a1  ; s1 = pointer to operator stack
                          mv s2, a2  ; s2 = pointer to operator stack top
                          mv s3, a3  ; s3 = pointer to output stack
                          mv s4, a4  ; s4 = pointer to output stack top
 
parse_start               lw t0, 0[s0] ; t0 = char
                          beqz t0, parse_success  ; if null terminator, done parsing

                          li t1, '0'
                          blt t0, t1, parse_operator  ; if character < '0', not a digit
                          li t1, '9'
                          bgt t0, t1, parse_operator  ; if character > '9', not a digit

parse_digit                 li a0, 0 ; a0 = value lower
                            li a1, 0 ; a1 = value upper

parse_digit_loop            lw t0, 0[s0]   ; t0 = character
                            addi s0, s0, 1 ; move to next character

                            li t1, '0'
                            blt t0, t1, parse_digit_done  ; if character < '0', done parsing number
                            li t1, '9'
                            bgt t0, t1, parse_digit_done  ; if character > '9', done parsing number

                            li a2, 10
                            li a3, 0
                            call mul_64          ; value *= 10
                            bnez a2, parse_overflow   ; check for errors

                            subi a2, t0, '0'     ; convert character to integer
                            call add_64          ; value += digit
                            bnez a2, parse_overflow   ; check for errors

                            j parse_digit_loop

parse_digit_done           sw a0, 0[s3]       ; push value lower to output stack
                           sw a1, 4[s3]       ; push value upper to output stack
                           lb t0, 0[s4] 
                           addi t0, t0, 1  
                           bge t0, 255, stack_overflow  ; stack < 255, otherwise overflow
                           sb t0, 0[s4]       ; increment output stack top
                           addi s3, s3, 8     ; move output stack pointer up

                           j parse_start

parse_operator              li t1, '+'
                            beq t0, t1, parse_op_push
                            li t1, '-'
                            beq t0, t1, parse_op_push
                            li t1, '*'
                            beq t0, t1, parse_op_push
                            li t1, '/'
                            beq t0, t1, parse_op_push
    
parse_err_invalid           li a0, ERR_INVALID_CHAR
                            j parse_end

parse_op_push               sb t0, 0[s1]    ; push operator to operator stack
                            lbu t0, 0[s2]  
                            addi t0, t0, 1
                            bge t0, 255, stack_overflow  ; stack < 255, otherwise overflow
                            sw t0, 0[s2]   ; increment operator stack top
                            addi s1, s1, 1 ; move operator stack pointer up

                            addi s0, s0, 1 ; move to next character
                            j parse_start

parse_err_stack_overflow    li a0, ERR_INTERNAL
                            j parse_end

parse_err_num_overflow      li a0, ERR_OVERFLOW
                            j parse_end


parse_err_success         li a0, ERR_SUCCESS
parse_end                 lw ra, 0[sp]  
                          lw s0, 4[sp]   
                          lw s1, 8[sp]   
                          lw s2, 12[sp]  
                          lw s3, 16[sp]
                          lw s4, 20[sp]
                          addi sp, sp, 24
                          ret


; evaluate_rpn
; Purpose: Evaluate the expression in reverse polish notation, and return the result.
; Input: a0 = pointer to operator stack, a1 = pointer to output stack
; Output: a0 = result lower, a1 = result upper, a2 = error code
evaluate_rpn:


; --- Mathematical Functions ---
; Consistent 64 bit integer arithmetic functions, with error handling for overflow and division by zero.
; Input: a0 = operand 1 lower, a1 = operand 1 upper, a2 = operand 2 lower, a3 = operand 2 upper
; Output: a0 = result lower, a1 = result upper, a2 = error code

; add_64


; sub_64

; mul_64

; div_64



