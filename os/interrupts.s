; --------------------------------------------------------------------------
;                      Interrupt Handlers
;                        Oliver Harris
;
; A collection of interrupt handlers, including the timer interrupt
; which can be linked to a user-defined function.
;
; Last Modified: 23/03/26
;
; --------------------------------------------------------------------------

; interrupt_timer
; Purpose: Handles timer interrupt, calls desired functions
; Input: None
; Output: None
; Modifies: t0, t1
interrupt_timer:
    subi sp, sp, 4
    sw ra, [sp]

    la t0, HARDWARE_BASE_ADDRESS       ; clear terminal count flag
    li t1, TIMER_TERMINAL_COUNT_CLR
    sw t1, OFFSET_TIMER_CLEAR[t0]

    call keyboard_scanner              ; call desired functions

    lw ra, [sp]
    addi sp, sp, 4
    ret

; interrupt_button
; Purpose: Handles button interrupt, for debug
interrupt_button:
    call keyboard_scanner
    ret


keyboard_scanner:
    ret
