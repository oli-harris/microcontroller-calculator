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

check_buttons      andi t1, t0, 0b0001
                   bnez t1, btn1_pressed

                   andi t1, t0, 0b0010
                   bnez t1, btn2_pressed

                   andi t1, t0, 0b0100
                   bnez t1, btn3_pressed

                   andi t1, t0, 0b1000
                   bnez t1, btn4_pressed

end                j loop

read_buttons:
                   li t1, BUTTONS_ADDRESS    ; stores new presses into t0
                   lb t1, [t1]               ; t1 = current value of buttons
                   la t2, buttons_prev       ;
                   lb t3, [t2]               ; t3 = previous value of buttons
                   sb t1, [t2]               ; stores current into previous

                   not t2, t2
                   and t0, t1, t2
                   ret


btn1_pressed       li a0, '1'
                   call write_char
                   j loop


btn2_pressed       li a0, '2'
                   call write_char
                   j loop

btn3_pressed       li a0, '3'
                   call write_char
                   j loop

btn4_pressed       li a0, '\f'
                   call write_char
                   j loop





; --- STACK ---

STACK              DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
