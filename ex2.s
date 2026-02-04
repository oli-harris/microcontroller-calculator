INCLUDE utility.s
INCLUDE ascii.s

; write_char
; a0 = character to write

start    li a0, ASCII_H_UPPER
         call write_char

end       j .


write_char:
; Set to read ‘control’ with data bus direction as input
; {R/W = 1, RS = 0}
step_1

; Enable bus (E := 1)
step_2

; Delay to stretch pulse width
step_2a

; Read LCD status byte
step_3

; Disable bus (E := 0)
step_4

; Added delay to separate enable pulses
step_5

; If bit 7 of status byte was high repeat from step ;2
step_6

; Set to write ‘data’ with data bus direction as output
; {R/W = 0, RS = 1}
step_7

; Output desired byte onto data bus
step_8

; Enable bus (E := 1)
step_9

; Delay to stretch pulse width
step_9a

; Disable bus (E := 0)
step_10
