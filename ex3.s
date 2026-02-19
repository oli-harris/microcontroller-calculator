;------------------------------------------------
;                Exercise 3
;                Oliver Harris
;
; Showcases lcd.s utility file
;
; Last modified: 19/02/26
;
;------------------------------------------------

                   j start

BUTTONS_ADDRESS    EQU 0x0001_0001
buttons_prev       defb 0
position           defb 0                    ; position in table (clamped from ... to ...)
                   align

start              la sp, STACK_END
                   li a0, '\f'
                   call write_char
                   li a0, 'X'
                   call write_char

loop               call read_buttons

check_buttons      andi t0, a0, 0b0001
                   bnez t0, btn1_pressed

                   andi t0, a0, 0b0010
                   bnez t0, btn2_pressed

                   andi t0, a0, 0b0100
                   bnez t0, btn3_pressed

                   andi t0, a0, 0b1000
                   bnez t0, btn4_pressed

                   li a1, 20
                   call delay_ms

end                j loop

; read_buttons
; Returns a0 = button with changed value on rising edge
read_buttons:
                   li t0, BUTTONS_ADDRESS
                   la t1, buttons_prev
                   lb t0, [t0]               ; t0 = current value of buttons
                   lb t2, [t1]               ; t2 = previous value of buttons
                   sb t0, [t1]               ; stores current into previous

                   not t2, t2                ; keep only difference in a0
                   and a0, t0, t2
                   ret


btn1_pressed       li a0, '1'
                   call write_char
                   addi t6, t6, 1
                   j loop

btn2_pressed       li a0, '2'
                   call write_char
                   addi t6, t6, 1
                   j loop

btn3_pressed       li a0, '3'
                   call write_char
                   addi t6, t6, 1
                   j loop

btn4_pressed       li a0, '\f'
                   call write_char
                   addi t6, t6, 1
                   j loop





; --- STACK ---
STACK              DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
include utility.s
