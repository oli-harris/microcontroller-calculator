; -------------------------------------------------
;                   Exercise 5
;                  Oliver Harris
;
; Stopwatch with start, stop and reset buttons
; Features: Displays time as HH:MM:SS
;           btn1: reset, btn2: start, btn4: stop
;           (buttons used similar to a casio)
;
; Last modified: 06/03/26
;
; -------------------------------------------------

              include os/init.s
STACK_SIZE    EQU 32


start:
              li s0, 0                      ; time in seconds
              li a0, TIMER_TICKS_PER_SEC    ; init timer to 1s
              li a7, 3
              ecall
              j update_display


poll_loop     li a1, 20
              call delay_ms

              li a7, 4                      ; check if timer has elapsed
              ecall
              bnez a0, increment_time

              j poll_loop


increment_time:
              addi s0, s0, 1

update_display:
              li a0, '\f'                   ; clear screen
              call write_char
              mv a0, s0                     ; write time
              li a1, 4
              call write_hex

              j poll_loop

; --- Includes ---
              include lib/lcd.s
