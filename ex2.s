INCLUDE utility.s
INCLUDE ascii.s

LCD_ADDRESS    EQU 0x0001_0100

; write_char
; a0 = character to write

start          li a0, ASCII_H_UPPER
               call write_char

end       j .


write_char:
; Set to read ‘control’ with data bus direction as input
; {R/W = 1, RS = 0}
step_1         lb t0, 0x1[LCD_ADDRESS]
               ori t0, 0b0000_0001        ; R/W = 1
               andi t0, 0b1111_1101       ; RS = 0
               sb t0, 0x1[LCD_ADDRESS]

; Enable bus (E := 1)
step_2         ori t0, 0b0000_0100        ; E = 1

; Delay to stretch pulse width
step_2a        li a0, 10                  ; delay >= 20 cycles
               call delay

; Read LCD status byte
step_3         lb t1, 0x0[LCD_ADDRESS]

; Disable bus (E := 0)
step_4         andi t0, 0b1111_1011       ; E = 0
               sb t0, 0x1[LCD_ADDRESS]

; Added delay to separate enable pulses
step_5         li a0, 20                  ; delay >= 48 cycles
               call delay

; If bit 7 of status byte was high repeat from step 2
step_6         andi t1, 0b0100_0000
               bnez t1, step_2

; Set to write ‘data’ with data bus direction as output
; {R/W = 0, RS = 1}
step_7         andi t0, 0b1111_1110       ; R/W = 0
               ori t0, 0b0000_0010        ; RS = 1
               sb t0, 0x1[LCD_ADDRESS]

; Output desired byte onto data bus
step_8         sb a0, 0x0[LCD_ADDRESS]

; Enable bus (E := 1)
step_9         ori t0, 0b0000_0100        ; E = 1
               sb t0, 0x1[LCD_ADDRESS]

; Delay to stretch pulse width
step_9a        li a0, 10                  ; delay >= 20 cycles
               call delay

; Disable bus (E := 0)
step_10        andi t0, 0b1111_1011       ; E = 0
               sb t0, 0x1[LCD_ADDRESS]
