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
STACK_SIZE                     EQU 32
; s0 = time in BCD HH_MM_SS (20 bits)

; --- Constants ---
LCD_INIT_MESSAGE               defb "\f--  Stopwatch --\n--  00:00:00  --\b\b\b\b", 0
STOPWATCH_CHARCOUNT            EQU 8
                               align

start:
                               li s0, 0x00_00_08                                         ; time in seconds
                               li a0, TIMER_TICKS_PER_SEC                                ; init timer to 1s
                               li a7, 3
                               ecall
                               la a0, LCD_INIT_MESSAGE
                               call write_string

poll_loop                      li a1, 20
                               call delay_ms

                               li a7, 4                                                  ; check if timer has elapsed
                               ecall
                               bnez a0, increment_time

                               j poll_loop


; increment_time
; Purpose: Increment time by n seconds, update display
; Input: a0 = increment in seconds
;        (requires s0 = current time in seconds)
; Output: (s0 = updated time in second
increment_time:
                               subi sp, sp, 4
                               sw ra, [sp]

                               andi a0, s0, 0xFF                                         ; extract seconds
                               call increment_60
                               li t0, 0xFF_FF_00
                               and s0, s0, t0                                            ; clear seconds
                               andi t2, a0, 0xFF                                         ; ignore carry/metadata bits
                               or s0, s0, t2                                             ; set seconds

                               andi t0, a0, 0x100                                        ; t0 = carry
                               srli t0, t0, 8
                               andi t1, a0, 0x600                                        ; t1 = digits updated
                               srli t1, t1, 9

                               mv a0, t1
                               call update_display

                               lw ra, [sp]
                               addi sp, sp, 4
                               ret


; increment_base_60
; Purpose: Increment seconds and minutes
; Input: a0 = original value (8 bits)
; Output: a0 = incremented value (8 bits), carry (bit 8), digits updated (bits 9&10)
increment_60:
                               andi t0, a0, 0xF                                          ; a0 = lower digit
                               andi t1, a0, 0xF0                                         ; t1 = upper digit
                               srli t1, t1, 4
                               li a0, 0x200                                              ; reset a0, 1 digit updated

                               addi t0, t0, 1                                            ; increment lower digit
                               li t2, 10
                               blt t0, t2, increment_60_repack                           ; lower digit < 10

increment_60_lower_overflow    li t0, 0                                                  ; reset lower digit
                               addi t1, t1, 1                                            ; increment upper digit
                               li a0, 0x400                                              ; 2 digits updated
                               li t2, 6
                               blt t1, t2, increment_60_repack                           ; upper digit < 6

increment_60_upper_overflow    li t1, 0                                                  ; reset upper digit
                               ori a0, a0, 0x100                                         ; carry = 1

increment_60_repack            slli t1, t1, 4
                               or a0, a0, t1                                             ; set upper digit
                               or a0, a0, t0                                             ; set lower digit
                               ret





; increment_base_24
; Purpose: Increment hours
; Input: a0 = original value (4 bits)
; Output: a0 = incremented value (4 bits), carry (bit 4)
increment_base_24:
                               ret


; update_display
; Purpose: Updates digits up to position on the LCD display
; Input: a0 = number of characters to update (from the right, 1-based)
; Uses: s0 = current time in BCD
; Modifies: a0, t0
update_display:
                               subi sp, sp, 12
                               sw ra, 0[sp]
                               sw s1, 4[sp]
                               sw s2, 8[sp]

                               mv s1, a0                                                 ; s1 = number of characters to update (saved)
                               mv s2, a0                                                 ; s2 = characters to update
                               blez s2, update_display_end                               ; nothing to update

update_display_clear_loop      li a0, '\b'                                               ; write s2 backspaces
                               call write_char
                               subi s2, s2, 1
                               bgtz s2, update_display_clear_loop

update_display_write_loop      subi s1, s1, 1                                            ; s1 = character index from right (0-based)
                               bltz s1, update_display_end
                               li t0, 2
                               beq s2, t0, update_display_separator
                               li t0, 5
                               beq s2, t0, update_display_separator

update_display_digit           slli t0, s1, 2
                               srl a0, s0, t0                                            ; extract nibble from BCD time
                               andi a0, a0, 0xF
                               call write_decimal
                               j update_display_write_loop

update_display_separator       li a0, ':'
                               call write_char
                               j update_display_write_loop

update_display_end             lw s2, 8[sp]
                               lw s1, 4[sp]
                               lw ra, 0[sp]
                               addi sp, sp, 12
                               ret


; --- Includes ---
                               include lib/lcd.s
