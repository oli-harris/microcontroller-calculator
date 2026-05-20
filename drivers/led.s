; ------------------------------------------------
;                    LED Driver
;                   Oliver Harris
;
; Basic ecall to set LEDs colour.
; (this header takes more lines then the code) 
;
; Last modified: 08/05/26
; ------------------------------------------------

; ecall_set_leds
; Purpose: Set LEDs according to input
; Input: a0 = LED Colour (8 bits)
; Output: None
; Modifies: t0
ecall_set_leds:
    la t0, HARDWARE_BASE_ADDRESS
    sb a0, OFFSET_LED[t0]
    ret
