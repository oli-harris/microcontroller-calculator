;--------------------------------------------------
;               Reusable Utility Functions
;               Oliver Harris
;
; Implements: delay_ms
;
; Last modified: 04/01/26
;
; Known bugs: delay_ms is inprecise
;
;--------------------------------------------------

LOOPS_PER_MS    EQU 40_000_000 / 1000 / 4  ; assuming 4 cycles per loop


; delay_ms
; delays programme by specified number of miliseconds
; in : a0 = number of miliseconds
delay_ms      li t1, LOOPS_PER_MS
              mul a0, a0, t1         ; ms -> number of cycles
              tail delay_loop

; delay_loop
; delays program by number of cycles
; in : a0 = number of cycles / 4
delay_loop    subi a0, a0, 1
              bgez a0, delay_loop
              ret
