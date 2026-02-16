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
; in : a1 = number of miliseconds
delay_ms      li t1, LOOPS_PER_MS
              mul a1, a1, t1         ; ms -> number of cycles
              tail delay_loop

; delay_loop
; delays program by number of cycles
; in : a1 = number of cycles / 4
delay_loop    subi a1, a1, 1
              bgez a1, delay_loop
              ret
