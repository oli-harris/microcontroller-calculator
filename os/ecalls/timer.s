;-------------------------------------------------------
;                      Timer
;                   Oliver Harris
;
; Purpose: Timer ecall implementations
; Improvements: Could implement one-shot and reloadable
;               (not yet needed)
;
; Last modified: 06/03/26
;
;-------------------------------------------------------

; ecall_timer_start
; Purpose: Enable timer and initialize to free running mode
; Input: a0: timer ticks until increment
; Output: None
; Modifies: t0, t1
ecall_timer_start:
                        la t0, HARDWARE_BASE_ADDRESS

                        subi t1, a0, 1                       ; Modulus is limit - 1
                        sw t1, OFFSET_TIMER_MODULUS[t0]

                        li t1, TIMER_INIT_FREE_RUNNING       ; Enable timer in free running mode (no interrupts)
                        sw t1, OFFSET_TIMER_STATUS[t0]

                        ret


; ecall_timer_stop
; Purpose: Disable timer, preserve current count
; Input: a0 = 1 to reset timer count, 0 to preserve count
; Output: None
; Modifies: t0, t1
ecall_timer_stop:
                        la t0, HARDWARE_BASE_ADDRESS

                        li t1, TIMER_ENABLE_FLAG             ; Set enable to 0
                        sw t1, OFFSET_TIMER_CLEAR[t0]

                        beqz a0, ecall_timer_stop_end        ; Return and preserve count
                        sw zero, OFFSET_TIMER_COUNTER[t0]    ; Set counter to 0

ecall_timer_stop_end    ret


; ecall_timer_check_increment
; Purpose: Check if timer compare flag is set, and resets it
; Input: None
; Output: a0: 1 if flag is set, 0 otherwise (bit 0)
; Modifies: t0, t1, a0
ecall_timer_check_increment:
                        la t0, HARDWARE_BASE_ADDRESS
                        lw t1, OFFSET_TIMER_STATUS[t0]       ; read timer bit 31 -> a0
                        srli a0, t1, TIMER_COMPARE_FLAG
                        li t1, TIMER_TERMINAL_COUNT_CLR      ; always clear terminal count flag
                        sw t1, OFFSET_TIMER_CLEAR[t0]
                        ret
