; --------------------------------------------------------------------------------------------------------------------
;        Exercise 7 - Addition Calculator
;                Oliver Harris
; Implements a finite state machine to perform addition calculations and display the result.
; The calculator supports input of digits (0-9), the addition operator (+),
; the AC operator (C) and the equals operator (=).
;
; The calculator operates in three states:
; 1. ENTER_FIRST: The user inputs the first digit.
; 2. Enter_NUMBER: The user inputs any subsequent digits, or can press +, AC or =.
; 3. RESULT: The user can press AC to reset, or = to repeat the last addition operation with the previous result.
; Transition Conditions: Digit, +, =, AC
;
; Known limitations: only supports 32 bit unsigned integers, and does not handle overflow.
;
; Last Modified: 24/06/2024
; --------------------------------------------------------------------------------------------------------------------
                           include os/init.s
STACK_SIZE                 EQU 64
EXTERNAL_INTERRUPTS        EQU MASK_INTERRUPT_TIMER | MASK_INTERRUPT_BUTTON
TIMER_INTERVAL_MS          EQU 2

S_ENTER_NUMBER             EQU 0
S_ENTER_FIRST              EQU 1
S_RESULT                   EQU 2

calc_total                 defw 0
calc_current               defw 0
calc_state                 defb 0


start:                 li a0, TIMER_INTERVAL_MS * (TIMER_TICKS_PER_SEC / 1000)
                           li a7, ECALL_TIMER_START
                           ecall

                           li a0, '\f'
                           call write_char


main_loop:                 j poll_key
                           j main_loop



poll_key:                  li a7, ECALL_GET_KEY
                           ecall

                           bltz a0, main_loop

                           la t0, KEY_LOOKUP
                           add t0, t0, a0
                           lb a0, [t0]

                           j state_machine

; state_machine
; Purpose: jump to appropriate state handler based on current state.
; Input: a0 The character of the key pressed.
state_machine:             la t0, calc_state
                           lb t0, [t0]                                         ; t0 = current state

                           beqz t0, state_enter_first

                           li t1, S_ENTER_NUMBER
                           beq t0, t1, state_enter_number

                           li t1, S_RESULT
                           beq t0, t1, state_result

                           j .                                                 ; Invalid state

; state_enter_first
; Transitions: digit -> ENTER_NUMBER
state_enter_first:
                           call is_digit
                           beqz a1, main_loop                                  ; Return if not a digit

state_enter_first_digit    subi t0, a0, '0'                                    ; Convert to digit
                           la t1, calc_current
                           sw t0, [t1]                                         ; Set current to the first digit

                           li t0, calc_state
                           li t1, S_ENTER_NUMBER
                           sb t1, [t0]                                         ; Transition to state_enter_number
                           j main_loop


; state_enter_number
; Transitions: digit  ->  ENTER_NUMBER
;                +    ->  ENTER_FIRST
;                =    ->  RESULT
;                AC   ->  ENTER_FIRST
state_enter_number:
                           call is_digit
                           bgtz a1, state_enter_number_digit

                           li t0, '+'
                           beq a0, t0, state_enter_number_plus

                           li t0, '='
                           beq a0, t0, state_enter_number_equals

                           li t0, 'C'
                           beq a0, t0, state_enter_number_ac

                           j main_loop                                         ; Return if not a valid key


; state_enter_number_digit
; Transitions:   =   ->  RESULT
;                AC  ->  ENTER_FIRST
state_result:
                           li t0, '='
                           beq a0, t0, state_result_equals

                           li t0, 'C'
                           beq a0, t0, state_result_ac

                           j main_loop                                         ; Return if not a valid key



; --- Helper Functions ---
; is_digit
; Return true if character is a digit.
; Non-ABI conformant.
; Input: a0 = character
; Output: a1 = 1 if a0 is a digit, 0 otherwise
is_digit:                  li a1, '0'
                           blt a0, a1, is_digit_false
                           li a1, '9'
                           bgt a0, a1, is_digit_false
is_digit_true              li a1, 1
                           ret
is_digit_false             li a1, 0
                           ret




KEY_LOOKUP                 defb "*7410852#963C=-+"

; Includes
                           include lib/lcd.s
