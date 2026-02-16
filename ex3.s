;------------------------------------------------
;                Exercise 3
;                Oliver Harris
;
; Prints ascii characters and commands
;
; Last modified: 16/02/26
;
; Known issues:
;
;------------------------------------------------

                  j start

; --- Main Section ---

start             la sp, STACK_END

                  li a0, 1
                  call write_cmd
                  li a0, 'H'
                  call write_char
                  li a0, 'e'
                  call write_char
                  li a0, 'l'
                  call write_char
                  li a0, 'l'
                  call write_char
                  li a0, 'o'
                  call write_char
                  li a0, ' '
                  call write_char
                  li a0, 'O'
                  call write_char
                  li a0, 'l'
                  call write_char
                  li a0, 'i'
                  call write_char
                  li a0, '!'
                  call write_char

end       j .


; --- FUNCTIONS ---

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
; a1 = boolean data/command
write_data:
                  subi sp, sp, 4              ; store ra onto stack
                  sw ra, [sp]
                  li t2, LCD_ADDRESS

; Set to read ‘control’ with data bus direction as input
; {R/W = 1, RS = 0}
step_1            lb t0, 0x1[t2]
                  ori t0, t0, 0b0000_0001     ; R/W = 1
                  andi t0, t0, 0b1111_1101    ; RS = 0
                  sb t0, 0x1[t2]

; Enable bus (E := 1)
step_2            lb t0, 0x1[t2]              ; re-reads to prevent stale data
                  ori t0, t0, 0b0000_0100     ; E = 1
                  sb t0, 0x1[t2]

; Delay to stretch pulse width
step_2a           li a2, 5                    ; delay >= 20 cycles
                  call delay_loop

; Read LCD status byte
step_3            lb t1, 0x0[t2]

; Disable bus (E := 0)
step_4            andi t0, t0, 0b1111_1011    ; E = 0
                  sb t0, 0x1[t2]

; Added delay to separate enable pulses
step_5            li a2, 12                   ; delay >= 48 cycles
                  call delay_loop

; If bit 7 of status byte was high repeat from step 2
step_6            andi t1, t1, 0b1000_0000
                  bnez t1, step_2

; Set to write ‘data’ with data bus direction as output
; {R/W = 0, RS = 1}
step_7            andi t0, t0, 0b1111_1100    ; R/W, RS = 0
                  andi a1, a1, 1              ; ensure a1 boolean
                  slli a1, a1, 1              ; move to bit 1
                  or t0, t0, a1               ; RS = a1

                  sb t0, 0x1[t2]

; Output desired byte onto data bus
step_8            sb a0, 0x0[t2]

; Enable bus (E := 1)
step_9            ori t0, t0, 0b0000_0100     ; E = 1
                  sb t0, 0x1[t2]

; Delay to stretch pulse width
step_9a           li a2, 5                    ; delay >= 20 cycles
                  call delay_loop

; Disable bus (E := 0)
step_10           andi t0, t0, 0b1111_1011    ; E = 0
                  sb t0, 0x1[t2]

write_data_end    lw ra, [sp]                 ; load ra
                  addi sp, sp, 4
                  ret


; delay_loop
; a2: delay in cycles / 4
delay_loop        subi a2, a2, 1
                  bgez a2, delay_loop
                  ret


; --- STACK ---

STACK             DEFS 128
STACK_END

