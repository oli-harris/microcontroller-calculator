; -----------------------------------------------------------------------------
;                              calc Page
;                               Oliver Harris
;
; Implements the calc page, supporting 64 bit integer calculations up to +-1e15-1, with
; correct ordering of operations, with addition, subtraction, multiplication,
; and division.
;
; Last modified: 13/05/26
; -----------------------------------------------------------------------------

; --- Library Includes ---
                          include ../lib/calc.s

; --- Calc Memory ---
EXPRESSION_BUFFER_SIZE    EQU 64                                ; Size of expression buffer, in bytes
expression_buffer         DEFS 64                               ; Used to store string of current expression being entered by the user

expression_length         DEFB 0                                ; Length of current expression (position of null terminator)
expression_position       DEFB 0                                ; Position of cursor from the right
                          align

calc_result               DEFW 0, 0

; State
calc_state                defb CALC_IDLE
                          align

CALC_IDLE                 EQU 0
CALC_DIGIT                EQU 1
CALC_OPERATOR             EQU 2
CALC_RESULT               EQU 3

                          sw ra, [sp]

                          li a0, '\f'                           ; Clear screen on init
                          call write_char

                          la t0, expression_buffer
                          sb zero, [t0]                         ; Null terminate buffer at start

                          la t0, expression_length
                          sb zero, [t0]                         ; Set expression length to 0

                          lw ra, [sp]
                          addi sp, sp, 4
                          ret

; calc_handler
; Purpose: Handle button presses
; Input: a0 = button pressed
KEY_LOOKUP                defb "*7410852/963@=-+ABCD"
KEY_LOOKUP_END

KEY_LOOKUP_LENGTH         EQU (KEY_LOOKUP_END - KEY_LOOKUP)     ; Number of valid keys
                          align

KEY_DIGIT                 EQU 0
KEY_OPERATOR              EQU 1
KEY_EQUALS                EQU 2
KEY_AC                    EQU 3
KEY_ONBOARD               EQU 4
KEY_INVALID               EQU -1

; --- Page Functions ---

; calc_init
; Purpose: Initialise calculator page.
calc_init                 subi sp, sp, 4
                          sw ra, [sp]

                          li a0, '\f'                           ; Clear screen on init
                          call write_char

                          la t0, expression_buffer
                          sb zero, [t0]                         ; Null terminate buffer at start

                          la t0, expression_length
                          sb zero, [t0]                         ; Set expression length to 0

                          lw ra, [sp]
                          addi sp, sp, 4
                          ret

; calc_handler
; Purpose: Handle button presses
; Input: a0 = button pressed
calc_handler              subi sp, sp, 4
                          sw ra, [sp]

                          call get_key_type                     ; a0 = char of button pressed, a1 = type of button pressed

                          la t0, calc_state
                          lb t0, [t0]                           ; t0 = current state

                          beqz t0, calc_handler_idle

                          li t1, CALC_DIGIT
                          beq t0, t1, calc_handler_digit

                          li t1, CALC_OPERATOR
                          beq t0, t1, calc_handler_operator

                          li t1, CALC_RESULT
                          beq t0, t1, calc_handler_result

calc_handler_end          lw ra, [sp]
                          addi sp, sp, 4
                          ret


; calc_render
; Purpose: Render expression buffer to screen, at the rightmost 16 columns.
; Modifies: t0, t1
calc_render               subi sp, sp, 4
                          sw ra, [sp]

                          li a0, '\f'                           ; Clear screen
                          call write_char

                          la t0, expression_length              ; offset = max(0, length - LCD_COLS)
                          lb t0, [t0]
                          subi t0, t0, LCD_COLS
                          bgez t0, _offset_continue
                          li t0, 0
_offset_continue          la t1, expression_buffer
                          add a0, t1, t0                        ; t1 = address of start of string to display

                          call write_string

                          lw ra, [sp]
                          addi sp, sp, 4
                          ret



; --- States ---

; Idle State
calc_handler_idle:
                          li t0, KEY_DIGIT
                          beq a1, t0, idle_digit

                          j calc_handler_end


; Digit State
; Transitions:
;  - Digit -> CALC_DIGIT
;  - Operator -> CALC_OPERATOR
;  - Result -> CALC_RESULT
;  - Clear -> CALC_IDLE
calc_handler_digit
                          li t0, KEY_DIGIT
                          beq a1, t0, digit_digit

                          li t0, KEY_OPERATOR
                          beq a1, t0, digit_operator

                          li t0, KEY_EQUALS
                          beq a1, t0, digit_equals

                          li t0, KEY_AC
                          beq a1, t0, digit_ac

                          j calc_handler_end


; Operator State
; Transitions:
;  - Digit -> CALC_DIGIT
;  - Clear -> CALC_IDLE
calc_handler_operator     li t0, KEY_DIGIT
                          beq a1, t0, operator_digit

                          li t0, KEY_AC
                          beq a1, t0, operator_ac

                          j calc_handler_end



; Result State
; Transitions:
; - AC -> CALC_IDLE
calc_handler_result       li t0, KEY_AC
                          beq a1, t0, result_ac

                          j calc_handler_end



; --- Transition Handlers ---

; Idle Transitions
; Digit -> CALC_DIGIT
idle_digit:
                          call append_expression

                          la t0, calc_state                     ; Update state
                          li t1, CALC_DIGIT
                          sb t1, [t0]
                          j calc_handler_end

; Digit Transitions
; Digit -> CALC_DIGIT
digit_digit:
                          call append_expression
                          j calc_handler_end                    ; no need to update state


; Operator -> CALC_OPERATOR
digit_operator:
                          call append_expression

                          la t0, calc_state                     ; Update state
                          li t1, CALC_OPERATOR
                          sb t1, [t0]
                          j calc_handler_end

; Equals -> CALC_RESULT
digit_equals              j .                                   ; not implemented

; Clear -> CALC_IDLE
digit_ac                  la t0, expression_buffer
                          sb zero, [t0]                         ; Null terminate buffer at start

                          la t0, expression_length
                          sb zero, [t0]                         ; Set expression length to 0

                          la t0, calc_state                     ; Update state
                          li t1, CALC_IDLE
                          sb t1, [t0]
                          j calc_handler_end


; Operator Transitions
; Digit -> CALC_DIGIT
operator_digit:
                          call append_expression

                          la t0, calc_state                     ; Update state
                          li t1, CALC_DIGIT
                          sb t1, [t0]
                          j calc_handler_end

; Clear -> CALC_IDLE
operator_ac               la t0, expression_buffer
                          sb zero, [t0]                         ; Null terminate buffer at start

                          la t0, expression_length
                          sb zero, [t0]                         ; Set expression length to 0

                          la t0, calc_state                     ; Update state
                          li t1, CALC_IDLE
                          sb t1, [t0]
                          j calc_handler_end

; Result Transitions
; AC -> CALC_IDLE
result_ac                 j .                                   ; not implemented


; --- Helper Functions ---

; append_expression
; Purpose: Appends char to expression buffer, updates length and position
; Input: a0 = char to append
; Modifies: t0, t1, t2
append_expression:
                          la t0, expression_length              ; Guard against buffer overflow
                          lb t1, [t0]                           ; t1 = current expression length
                          li t2, EXPRESSION_BUFFER_SIZE - 1     ; t2 = max expression length
                          bgeu t1, t2, append_expression_end    ; If expression buffer full, do not append

                          la t2, expression_buffer
                          add t2, t2, t1                        ; t2 = address of null terminator
                          sb a0, [t2]                           ; Append char to end of expression
                          sb zero, 1[t2]                        ; Null terminate new end of expression

                          addi t1, t1, 1                        ; Increment expression length
                          sb t1, [t0]                           ; Update expression length
                          la t0, expression_position
                          sb t1, [t0]                           ; Reset position to end of expression

append_expression_end     ret




; get_key
; Input: a0 = digit button pressed
; Output: a0 = button char, a1 = type of button pressed
get_key_type
                          li t0, KEY_LOOKUP_LENGTH
                          bgeu a0, t0, get_key_invalid          ; Button index out of bounds

                          li t0, KEYBOARD_BUTTONS
                          bgeu a0, t0, get_key_onboard          ; On-board button

                          la t0, KEY_LOOKUP
                          add t0, t0, a0
                          lb a0, [t0]                           ; a0 = char of button pressed

                          li t0, '0'
                          blt a0, t0, get_key_operator          ; If char less than '0', must be operator

                          li t0, '9'
                          bgt a0, t0, get_key_special           ; If char greater than '9', must be special key

                          li a1, KEY_DIGIT
                          ret

get_key_special           li t0, '='
                          beq a0, t0, get_key_equals

                          li t0, '@'
                          beq a0, t0, get_key_ac

                          j get_key_invalid                     ; catch all, extra safe

get_key_onboard           la t0, KEY_LOOKUP
                          add t0, t0, a0
                          lb a0, [t0]                           ; a0 = char of button pressed

                          li a1, KEY_ONBOARD
                          ret

get_key_ac                li a1, KEY_AC
                          ret

get_key_equals            li a1, KEY_EQUALS
                          ret

get_key_operator          li a1, KEY_OPERATOR
                          ret

get_key_invalid           li a1, KEY_INVALID
                          ret
