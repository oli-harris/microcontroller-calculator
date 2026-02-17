;------------------------------------------------
;                LCD Utility Functions
;                Oliver Harris
;
; Allows writing of characters and commands
;
; Last modified: 17/02/26
;
;------------------------------------------------

LCD_ADDRESS       EQU 0x0001_0100

; write_char
; a0 = character to write
write_char:
                  li a1, 1
                  j write_data

; write_cmd
; a0 = command to write
write_cmd:
                  li a1, 0
                  j write_data

; write_data
; a0 = data to write
; a1 = 1 for data, 0 for command
write_data:
                  subi sp, sp, 4              ; store ra
                  sw ra, [sp]
                  li t2, LCD_ADDRESS          ; t2 always LCD_ADDRESS
step_1            lb t0, 0x1[t2]              ; read control
                  ori t0, t0, 0b0000_0001     ; R/W = 1
                  andi t0, t0, 0b1111_1101    ; RS = 0
                  sb t0, 0x1[t2]
step_2            ori t0, t0, 0b0000_0100     ; enable bus (E = 1)
                  sb t0, 0x1[t2]
step_2a           li a2, 5                    ; pulse width delay (>= 20 cycles)
                  call delay_loop
step_3            lb t1, 0x0[t2]              ; read LCD status byte
step_4            andi t0, t0, 0b1111_1011    ; disable bus (E = 0)
                  sb t0, 0x1[t2]
step_5            li a2, 12                   ; seperate pulses (>= 48 cycles)
                  call delay_loop
step_6            andi t1, t1, 0b1000_0000    ; check busy flag (bit 7)
                  bnez t1, step_2             ; loop if busy
step_7            andi t0, t0, 0b1111_1100    ; R/W = 0, RS = 0
                  andi a1, a1, 1              ; enforce input a1 boolean
                  slli a1, a1, 1              ; move to bit 1
                  or t0, t0, a1               ; RS = a1
                  sb t0, 0x1[t2]
step_8            sb a0, 0x0[t2]              ; output data
step_9            ori t0, t0, 0b0000_0100     ; enable bus (E = 1)
                  sb t0, 0x1[t2]
step_9a           li a2, 5                    ; pulse width delay (>=20 cycles)
                  call delay_loop
step_10           andi t0, t0, 0b1111_1011    ; disable bus (E = 0)
                  sb t0, 0x1[t2]
write_data_end    lw ra, [sp]                 ; restore ra
                  addi sp, sp, 4
                  ret

; delay_loop
; a2 = delay in cycles / 4
delay_loop        subi a2, a2, 1
                  bgez a2, delay_loop
                  ret
