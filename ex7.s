; --------------------------------------------------------------------------------------------------------------------
;                               Exercise 7 - Addition Calculator
;                                        Oliver Harris
; Implements a finite state machine to perform 32bit addition calculations and display the result.
; The calculator supports input of digits (0-9), the addition operator (+),
; the AC operator (C) and the equals operator (=).
;
; The calculator operates in four states:
; 1. ENTER_FIRST: The user inputs the first digit.
; 2. Enter_NUMBER: The user inputs any subsequent digits, or can press +, AC or =.
; 3. RESULT: The user can press AC to reset, or = to repeat the last addition operation with the previous result.
; 4. OVERFLOW: Displays error, press AC to reset.
; Transition Conditions: Digit, +, =, AC
;
; Known limitations: only supports 32 bit unsigned integers, and does not handle overflow.
;
; Last Modified: 27/04/2026
; --------------------------------------------------------------------------------------------------------------------
                       include os/init.s
                       include lib/lcd.s


STACK_SIZE             EQU 64
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER | MASK_INTERRUPT_BUTTON

; --- Calculator State ---
S_ENTER_NUMBER         EQU 0
S_ENTER_FIRST          EQU 1
S_RESULT               EQU 2
S_OVERFLOW             EQU 3

calc_total             defw 0                                              ; uint32
calc_current           defw 0                                              ; uint32
calc_state             defb 1
                       align

; --- Key Lookup Table ---
KEY_LOOKUP             defb "*7410852#963C=-+"
                       align
; --- Display Strings ---
DISPLAY_WELCOME        defb "\fCalculator\nPress any key...\0"
                       align
DISPLAY_BEGIN          defb "\fNew Calculation\n...\0"
                       align
DISPLAY_ADD            defb "\n+\0"
                       align
DISPLAY_OVERFLOW       defb "\fOverflow Error!\nPress AC...\0"
                       align


start:                 li a0, DISPLAY_WELCOME                              ; Display Message
                       call write_string

                       li a0, LEDS_ORANGE | (LEDS_ORANGE << 4)             ; LEDS to indicate ready
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_total                                   ; Initialise memory, allowing for reset with button interrupt
                       sw zero, [t0]
                       la t0, calc_current
                       sw zero, [t0]
                       la t0, calc_state
                       li t1, S_ENTER_FIRST
                       sb t1, [t0]


main_loop:             j poll_key
                       j main_loop



poll_key:              li a7, ECALL_GET_KEY
                       ecall

                       bltz a0, main_loop

                       la t0, KEY_LOOKUP
                       add t0, t0, a0
                       lb a0, [t0]

                       j state_machine

; state_machine
; Purpose: jump to appropriate state handler based on current state.
; Input: a0 The character of the key pressed.
state_machine:         la t0, calc_state
                       lb t0, [t0]                                         ; t0 = current state

                       beqz t0, state_enter_number

                       li t1, S_ENTER_FIRST
                       beq t0, t1, state_enter_first

                       li t1, S_RESULT
                       beq t0, t1, state_result

                       li t1, S_OVERFLOW
                       beq t0, t1, state_overflow

                       j .                                                 ; Invalid state

; state_enter_first
; Transitions: digit -> ENTER_NUMBER
state_enter_first:
                       call is_digit
                       bnez a1, transition_enter_first_digit

                       li a0, LEDS_RED                                     ; Not a valid key, LEDS error and return
                       li a7, ECALL_SET_LEDS
                       ecall

                       j main_loop

; transition_enter_first_digit
; Purpose: Set current to digit entered, display current
transition_enter_first_digit:
                       subi s0, a0, '0'                                    ; Convert to digit
                       la t1, calc_current
                       sw s0, [t1]                                         ; Set current to the first digit

                       li a0, '\f'
                       call write_char                                     ; Clear screen
                       mv a0, s0
                       call write_decimal                                  ; Display current

                       li a0, LEDS_ORANGE                                  ; LEDS in progress
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       sb zero, [t0]                                       ; state = ENTER_NUMBER
                       j main_loop


; state_enter_number
; Transitions: digit  ->  ENTER_NUMBER
;                +    ->  ENTER_FIRST or OVERFLOW
;                =    ->  RESULT
;                AC   ->  ENTER_FIRST
state_enter_number:
                       call is_digit
                       bgtz a1, transition_enter_number_digit

                       li t0, '+'
                       beq a0, t0, transition_enter_number_plus

                       li t0, '='
                       beq a0, t0, transition_calc_equals

                       li t0, 'C'
                       beq a0, t0, transition_enter_number_ac

                       li a0, LEDS_RED                                     ; Not a valid key, LEDS error and return
                       li a7, ECALL_SET_LEDS
                       ecall

                       j main_loop

; transition_enter_number_digit
; Purpose: current = current * 10 + digit, display current
transition_enter_number_digit:
                       subi a0, a0, '0'                                    ; a0 = digit value
                       la t0, calc_current
                       lw t1, [t0]                                         ; t1 = current
                       li t2, 429496729                                    ; 2 ** 32 // 10 = 429496729

_overflow_check:
                       bltu t1, t2, _continue

                       bgtu t1, t2, transition_overflow_handler            ; current*10 would overflow

                       li t2, 5
                       bgtu a0, t2, transition_overflow_handler            ; current*10 + digit would overflow if digit > 5

_continue              li t2, 10
                       mul t1, t1, t2                                      ; shift current left by 1 dp
                       add t1, t1, a0                                      ; add new digit
                       sw t1, [t0]                                         ; update current

                       call write_decimal                                  ; Display current

                       li a0, LEDS_ORANGE                                  ; LEDS in progress
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       sb zero, [t0]                                       ; state = ENTER_NUMBER
                       j main_loop


; transition_enter_number_plus
; Purpose: total = current + total, current = 0, display '+' on new line
transition_enter_number_plus:
                       la t0, calc_current
                       lw t1, [t0]                                         ; t1 = current
                       sw zero, [t0]                                       ; current = 0

                       la t0, calc_total
                       lw t2, [t0]                                         ; t2 = total
                       add t2, t2, t1                                      ; total += current

                       bltu t2, t1, transition_overflow_handler            ; t2 < t1 iff overflow occurred

                       sw t2, [t0]                                         ; update total

                       li a0, DISPLAY_ADD
                       call write_string

                       li a0, LEDS_ORANGE | (LEDS_ORANGE << 4)             ; LEDS in progress
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       li t1, S_ENTER_FIRST
                       sb t1, [t0]                                         ; state = ENTER_FIRST
                       j main_loop

; transition_enter_number_ac
; Purpose: Reset current, clear screen
transition_enter_number_ac:
                       la t0, calc_current
                       sw zero, [t0]                                       ; current = 0

                       li a0, '\f'                                         ; Clear screen
                       call write_char

                       li a0, LEDS_ORANGE | (LEDS_ORANGE << 4)             ; LEDS in progress
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       li t1, S_ENTER_FIRST
                       sb t1, [t0]                                         ; state = ENTER_FIRST
                       j main_loop


; state_result
; Transitions:   =   ->  RESULT or OVERFLOW
;                AC  ->  ENTER_FIRST
state_result:
                       li t0, '='
                       beq a0, t0, transition_calc_equals

                       li t0, 'C'
                       beq a0, t0, transition_ac_new

                       li a0, LEDS_RED                                     ; Not a valid key, LEDS error and return
                       li a7, ECALL_SET_LEDS
                       ecall

                       j main_loop

; transition_calc_equals
; Purpose: total = total + current, display total
transition_calc_equals:
                       la t0, calc_current
                       lw t0, [t0]                                         ; t0 = current
                       la t1, calc_total
                       lw t2, [t1]                                         ; t2 = total
                       add s0, t2, t0                                      ; total += current

                       bltu s0, t0, transition_overflow_handler            ; s0 < t0 iff overflow occurred
                       sw s0, [t1]                                         ; update total

                       li a0, '\f'                                         ; Clear screen
                       call write_char
                       mv a0, s0                                           ; Display total
                       call write_decimal

                       li a0, LEDS_GREEN                                   ; LEDS success
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       li t1, S_RESULT
                       sb t1, [t0]                                         ; state = RESULT
                       j main_loop

; transition_ac_new
; Purpose: Begin new calculation, reset total and current, display message
transition_ac_new:
                       la t0, calc_total
                       sw zero, [t0]                                       ; total = 0
                       la t0, calc_current
                       sw zero, [t0]                                       ; current = 0

                       la a0, DISPLAY_BEGIN                                ; Clear screen
                       call write_string

                       li a0, LEDS_ORANGE | (LEDS_ORANGE << 4)             ; LEDS in progress
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       li t1, S_ENTER_FIRST
                       sb t1, [t0]                                         ; state = ENTER_FIRST
                       j main_loop

; state_overflow
; Transitions: AC -> ENTER_FIRST
state_overflow:
                       li t0, 'C'
                       beq a0, t0, transition_ac_new

                       j main_loop

; state_overflow_handler
; Purpose: Display error message
transition_overflow_handler:
                       la a0, DISPLAY_OVERFLOW
                       call write_string

                       li a0, LEDS_RED | (LEDS_RED << 4)                   ; LEDS error
                       li a7, ECALL_SET_LEDS
                       ecall

                       la t0, calc_state
                       li t1, S_OVERFLOW
                       sb t1, [t0]                                         ; state = OVERFLOW
                       j main_loop


; --- Helper Functions ---

; is_digit
; Return true if character is a digit.
; Non-ABI conformant.
; Input: a0 = character
; Output: a1 = 1 if a0 is a digit, 0 otherwise
is_digit:              li a1, '0'
                       blt a0, a1, is_digit_false
                       li a1, '9'
                       bgt a0, a1, is_digit_false
is_digit_true          li a1, 1
                       ret
is_digit_false         li a1, 0
                       ret
