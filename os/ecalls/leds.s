;-------------------------------------------------------
;                      Set LEDS
;                   Oliver Harris
;
; Purpose: Enables/disables LEDs according to input
; Input: a0 = LED Colour (8 bits)
; Output: None
; Modifies: t0
;
; Last modified: 03/03/26
;
;-------------------------------------------------------

ecall_set_leds:
    la t0, HARDWARE_BASE_ADDRESS
    andi a0, a0, 0xFF               ; enforce input a0 is 8 bits
    sb a0, OFFSET_LED[t0]
    ret
