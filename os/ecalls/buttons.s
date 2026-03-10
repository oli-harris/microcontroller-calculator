;--------------------------------------------
;      Detect Changed Buttons
;             Oliver Harris
;
; Purpose: Reads buttons and detects rising edges
; Input: None
; Output: a0 = button with changed value on rising edge
; Modifies: t0, t1, t2
;
; Last modified: 10/03/26
;
;--------------------------------------------

buttons_prev    defw 0                          ; (4 bits)

ecall_changed_buttons:
                li t0, HARDWARE_BASE_ADDRESS
                la t1, buttons_prev
                lb t0, OFFSET_BUTTONS[t0]       ; t0 = current value of buttons
                lb t2, [t1]                     ; t2 = previous value of buttons
                sb t0, [t1]                     ; stores current into previous

                not t2, t2                      ; Detect edge into a0
                and a0, t0, t2
                ret
