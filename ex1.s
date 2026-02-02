RAINBOW         EQU 0b1111
RED             EQU 0b0001
RED_AMBER       EQU 0b0011
AMBER           EQU 0b0010
GREEN           EQU 0b0100
BLUE            EQU 0b1000 

BASE_ADDRESS    EQU 0x0001_0000

                li t0, BASE_ADDRESS ; base address always stored at t0

start:
    li a0, RAINBOW
    li a1, BLUE
    call load_both
    call start



; load_both
; sets lights to specified values
; in : a0 = Left LEDs
; in : a1 = Right LEDs
load_both:
    slli a1, a1, 4
    or a1, a1, a0
    
    sb a1, 0[t0] 
    

