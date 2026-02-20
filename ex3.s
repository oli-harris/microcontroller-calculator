;----------------------------------------------------------------------
;                Exercise 3
;                Oliver Harris
;
; Trivia game to guess european capitals
; Features: displays all 52 european countries and capitals
;         : btn1: previous country,        btn3: next country
;         : btn3: view answer (one char),  btn4: view entire answer
;
; Last modified: 20/02/26
;
;------------------------------------------------------------------------

                      j start

LEDS_ADDRESS          EQU 0x0001_0000
BUTTONS_ADDRESS       EQU 0x0001_0001
LEDS_RAINBOW          EQU 0b1111                          ; using half of leds, as too bright
LEDS_RED              EQU 0b0001
LEDS_GREEN            EQU 0b0100

buttons_prev          defb 0
table_position           defb -1                              ; position in table (clamped)
                      align
p_str_answer          defw 0                              ; points to answer string
p_null                defw 0                              ; null pointer
welcome_message       defb "\fCapitals Trivia!\n...\0"
                      align

start                 la sp, STACK_END
                      la a0, welcome_message              ; Startup display
                      call write_string
                      li a0, LEDS_RAINBOW
                      call set_leds

loop                  call read_buttons

check_buttons         andi t0, a0, 0b0001                 ; Button 1 Pressed
                      bnez t0, display_prev_trivia

                      andi t0, a0, 0b0010                 ; Button 2 Pressed
                      bnez t0, display_next_trivia

                      andi t0, a0, 0b0100                 ; Button 3 Pressed
                      bnez t0, display_next_answer

                      andi t0, a0, 0b1000                 ; Button 4 Pressed
                      bnez t0, display_entire_answer

end_loop              li a1, 20
                      call delay_ms

end                   j loop

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
                      li a0, CAPITALS_TABLE_SIZE
                      subi a0, a0, 1
skip_prev_clamp       sb a0, [t0]
                      j display_question


; Next trivia
display_next_trivia:
                      la t0, table_position               ; table_pos++
                      lb a0, [t0]
                      addi a0, a0, 1
                      li t1, CAPITALS_TABLE_SIZE          ; overflow to 0
                      blt a0, t1, skip_next_clamp
                      mv a0, x0
skip_next_clamp       sb a0, [t0]
                      j display_question


; Display Question
; Input: a0 = position
display_question:
                      la t0, capitals_table
                      slli a0, a0, 3
                      add t0, t0, a0
                      lw a0, [t0]                         ; a0=question string

                      lw t1, 4[t0]                        ; store pointer to answer string
                      la t0, p_str_answer
                      sw t1, [t0]

                      call write_string

                      li a0, LEDS_RED                     ; Lights red
                      call set_leds
                      j end_loop


; Display Answer
display_entire_answer:
                      li a0, LEDS_GREEN                   ; Lights green
                      call set_leds

                      la s0, p_str_answer                 ; stores p_str_answer address
                      lw a0, [s0]
                      call write_string

                      la t0, p_null                       ; point to end of string
                      sw t0, [s0]

                      j end_loop


; Display next character from answer
display_next_answer:
                      la s0, p_str_answer                 ; t0 = pointer to char in answer
                      lw s1, [s0]
                      lb a0, [s1]                         ; a0 = char

                      beqz a0, answer_all_printed         ; entire answer printed, skip
                      call write_char

                      addi s1, s1, 1                      ; p_str_answer++
                      sb s1, [s0]
                      j end_loop
answer_all_printed    li a0, LEDS_GREEN                   ; Lights green
                      call set_leds
                      j end_loop

; --- Set Leds ---
; Input: a0 = LED Colour
set_leds:
                      la t0, LEDS_ADDRESS
                      sb a0, [t0]
                      ret


; --- STACK ---
STACK                 DEFS 128
STACK_END


; --- INCLUDES ---
include lcd.s
include utility.s
include capitals_table.s
