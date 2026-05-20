; ------------------------------------------------------------------------------------------------
;                                      Timer Driver
;                                      Oliver Harris
;
; Handles interrupts, and calls functions at 1ms or 5ms intervals. 
; Extendible to call functions at other intervals.
;
;
; Note: ideally this would call timer_tick, to separate interrupt handling and functionality,
; However this is unnecessary overhead, so the functionality is included in the driver instead.
; Last modified: 20/05/26
;
; ------------------------------------------------------------------------------------------------

; --- Timer Counters ---
timer_count_5ms        defb 5
                       align


; --- Timer Interrupts ---
; interrupt_timer
; Purpose: Handles timer interrupt, configurable to call routines at given intervals
; Input: None
; Output: None
; Modifies: t0, t1
interrupt_timer:
                       subi sp, sp, 4
                       sw ra, [sp]

                       la t0, HARDWARE_BASE_ADDRESS       ; clear terminal count flag
                       li t1, TIMER_TERMINAL_COUNT_CLR
                       sw t1, OFFSET_TIMER_CLEAR[t0]

timer_1ms              call buzzer_tick

                       la t0, timer_count_5ms             ; 5ms_timer--
                       lb t1, [t0]
                       subi t1, t1, 1
                       sb t1, [t0]

                       bnez t1, interrupt_timer_end       ; if timer not expired, return
                       li t1, 5                           ; else reset timer and call functions
                       sb t1, [t0]

timer_5ms              call keyboard_scanner
                       call button_scanner

interrupt_timer_end    lw ra, [sp]
                       addi sp, sp, 4
                       ret



