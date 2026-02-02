RAINBOW         EQU 0b1111
RED             EQU 0b0001
RED_AMBER       EQU 0b0011
AMBER           EQU 0b0010
GREEN           EQU 0b0100
BLUE            EQU 0b1000

BASE_ADDRESS    EQU 0x0001_0000
LOOPS_PER_MS    EQU 40_000_000 / 1000 / 4  ; assuming 4 cycles per loop

                li t0, BASE_ADDRESS    ; base address always stored at t0


; State 0
start:
                li a0, RED
                li a1, RED
                call load_both
                li a0, 1000
                call delay_loop

; State 1
                li a0, RED_AMBER
                li a1, RED
                call load_both
                li a0, 1000
                call delay_loop

; State 2
                li a0, GREEN
                li a1, RED
                call load_both
                li a0, 3000
                call delay_loop

; State 3
                li a0, AMBER
                li a1, RED
                call load_both
                li a0, 1000
                call delay_loop

; State 4
                li a0, RED
                li a1, RED
                call load_both
                li a0, 1000
                call delay_loop

; State 5
                li a0, RED
                li a1, RED_AMBER
                call load_both
                li a0, 1000
                call delay_loop

; State 6
                li a0, RED
                li a1, GREEN
                call load_both
                li a0, 3000
                call delay_loop

; State 7
                li a0, RED
                li a1, AMBER
                call load_both
                li a0, 1000
                call delay_loop

                call start


; load_both
; sets lights to specified values
; in : a0 = Left LEDs
; in : a1 = Right LEDs
load_both:
                slli a1, a1, 4         ; right = upper 4 bits of byte
                or a1, a1, a0
                sb a1, 0[t0]
                ret


; delay_loop
; in : a0 = number of miliseconds
delay_loop:
                li t1, LOOPS_PER_MS
                mul a0, a0, t1         ; ms -> number of cycles
loop            subi a0, a0, 1
                bgez a0, loop
                ret
