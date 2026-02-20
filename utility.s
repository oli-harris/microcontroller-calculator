;--------------------------------------------------
;               Reusable Utility Functions
;               Oliver Harris
;
; Implements: delay_ms
;
; Last modified: 19/01/26
;
; Known bugs: delay_ms is inprecise,
;             must only be imported in parent file
;
;--------------------------------------------------

LOOPS_PER_MS    EQU 40_000_000 / 1000 / 4  ; assuming 4 cycles per loop


; delay_ms
; delays programme by specified number of miliseconds
; in : a1 = number of miliseconds
delay_ms      li t0, LOOPS_PER_MS
              mul a2, a1, t0         ; ms -> number of cycles

; delay_loop
; delays program by number of cycles
; in : a2 = number of cycles / 4
delay_loop    subi a2, a2, 1
              bgez a2, delay_loop
              ret
