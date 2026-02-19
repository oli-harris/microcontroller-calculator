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

BUTTONS_ADDRESS          EQU 0x0001_0001
buttons_prev             defb 0
table_position           defb 0                              ; position in table (clamped from 0 to TABLE_CAPITALS_SIZE)
p_str_answer             defw 0                              ; points to answer string
welcome_message          defb "\fCapitals Trivia!\n...\0"
                         align

start                    la sp, STACK_END
                         la a0, welcome_message
                         call write_string

loop                     call read_buttons

check_buttons            andi t0, a0, 0b0001                 ; Button 1 Pressed
                         bnez t0, display_prev_trivia

                         andi t0, a0, 0b0010                 ; Button 2 Pressed
                         bnez t0, display_next_trivia

                         andi t0, a0, 0b0100                 ; Button 3 Pressed
                         bnez t0, btn3_pressed

                         andi t0, a0, 0b1000                 ; Button 4 Pressed
                         bnez t0, btn4_pressed

end_loop                 li a1, 20
                         call delay_ms

end                      j loop

; --- Functions ---

; read_buttons
; Returns a0 = button with changed value on rising edge
read_buttons:
                         li t0, BUTTONS_ADDRESS
                         la t1, buttons_prev
                         lb t0, [t0]                         ; t0 = current value of buttons
                         lb t2, [t1]                         ; t2 = previous value of buttons
                         sb t0, [t1]                         ; stores current into previous

                         not t2, t2                          ; keep only difference in a0
                         and a0, t0, t2
                         ret


; Previous trivia
display_prev_trivia:
                         la t0, table_position               ; table_pos--
                         lb a0, [t0]
                         subi a0, a0, 1
                         bgez a0, skip_prev_clamp
                         li a0, TABLE_CAPITALS_SIZE
                         subi a0, a0, 1
skip_prev_clamp          sb a0, [t0]
                         j display_question

; Next trivia
display_next_trivia:
                         la t0, table_position               ; table_pos++
                         lb a0, [t0]
                         addi a0, a0, 1
                         li t1, TABLE_CAPITALS_SIZE          ; overflow to 0
                         blt a0, t1, skip_next_clamp
                         mv a0, x0
skip_next_clamp          sb a0, [t0]
                         j display_question


; Display Question
; Input: a0 = position
display_question:
                         la t0, table_capitals
                         slli a0, a0, 3
                         add t0, t0, a0
                         lw a0, [t0]                         ; a0=question string


                         call write_string
                         j end_loop


; Display Answer
display_entire_answer    li a0, '\f'
                         call write_char
                         addi t6, t6, 1
                         j end_loop




; --- STACK ---
STACK                    DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
include utility.s
include data_table.s
