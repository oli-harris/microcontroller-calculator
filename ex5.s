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
STACK_SIZE                               EQU 32
; s0 = time in BCD HH_MM_SS (20 bits)

; --- Program Specific Constants ---
LCD_INIT_MESSAGE                         defb "\f--  Stopwatch --\n--  XX:XX:XX  --\b\b\b\b", 0
STOPWATCH_CHARCOUNT                      EQU 8
SEPARATOR_WIDTH                          EQU 1

MASK_DIGIT                               EQU 0xF
MASK_LOWER_DIGIT                         EQU 0xF
MASK_UPPER_DIGIT                         EQU 0xF0
MASK_BOTH_DIGITS                         EQU 0xFF

MASK_SECONDS                             EQU 0x00_00_FF
MASK_SECONDS_INVERT                      EQU 0xFF_FF_00
MASK_MINUTES                             EQU 0x00_FF_00
MASK_MINUTES_INVERT                      EQU 0xFF_00_FF
MASK_HOURS                               EQU 0xFF_00_00
MASK_HOURS_INVERT                        EQU 0x00_FF_FF

MASK_CARRY                               EQU 0x100
MASK_DIGITS_UPDATED                      EQU 0x600

DIGITS_UPDATED_1                         EQU 0x200
DIGITS_UPDATED_2                         EQU 0x400
SET_CARRY                                EQU 0x100

MAP_SEPARATOR_CODE                       EQU 0xF

                                         align

start:
                                         li s0, 0x11_22_33                                         ; Initialise time
                                         li a0, TIMER_TICKS_PER_SEC                                ; Set timer for 1 second
                                         li a7, 3
                                         ecall
                                         la a0, LCD_INIT_MESSAGE                                   ; Initialise LCD with message and time
                                         call write_string
                                         li a0, 8                                                  ; Display all 8 characters of time
                                         call update_display

poll_loop                                li a1, 20
                                         call delay_ms

                                         li a7, 4                                                  ; check if timer has elapsed
                                         ecall
                                         bnez a0, update_stopwatch

                                         j poll_loop


update_stopwatch:
                                         call increment_time
                                         call update_display
                                         j poll_loop


; increment_time
; Purpose: Increment time by n seconds, update display
; Input: None
; Output: a0 = number of digits to update
; Modifies: a0, t0, t1
increment_time:
                                         subi sp, sp, 8
                                         sw ra, [sp]
                                         sw s1, 4[sp]

                                         andi a0, s0, MASK_SECONDS                                 ; Increment current seconds
                                         call increment_base_60

                                         andi t0, a0, MASK_BOTH_DIGITS                             ; s0 -> updated with new seconds
                                         li t1, MASK_SECONDS_INVERT
                                         and s0, s0, t1
                                         or s0, s0, t0
                                         andi s1, a0, MASK_DIGITS_UPDATED                          ; s1 = characters updated
                                         srli s1, s1, 9
                                         andi t0, a0, MASK_CARRY                                   ; t0 = carry
                                         srli t0, t0, 8
                                         beqz t0, increment_time_end                               ; End if no carry

                                         li t0, MASK_MINUTES                                       ; Increment current minutes
                                         and a0, s0, t0
                                         srli a0, a0, 8
                                         call increment_base_60

                                         andi t0, a0, MASK_BOTH_DIGITS                             ; s0 -> updated with new minutes
                                         slli t0, t0, 8
                                         li t1, MASK_MINUTES_INVERT
                                         and s0, s0, t1
                                         or s0, s0, t0
                                         andi t0, a0, MASK_DIGITS_UPDATED                          ; s1 += characters updated
                                         srli t0, t0, 9
                                         add s1, s1, t0
                                         addi s1, s1, SEPARATOR_WIDTH
                                         andi t0, a0, MASK_CARRY                                   ; t0 = carry
                                         srli t0, t0, 8
                                         beqz t0, increment_time_end                               ; No carry

                                         li t0, MASK_HOURS                                         ; Increment hours
                                         and a0, s0, t0
                                         srli a0, a0, 16
                                         call increment_base_24

                                         andi t0, a0, MASK_BOTH_DIGITS                             ; Set hours into s0
                                         slli t0, t0, 16
                                         li t1, MASK_HOURS_INVERT
                                         and s0, s0, t1
                                         or s0, s0, t0
                                         andi t0, a0, MASK_DIGITS_UPDATED                          ; s1 += characters updated
                                         srli t0, t0, 9
                                         add s1, s1, t0
                                         addi s1, s1, SEPARATOR_WIDTH                              ; Continue, ignore carry

increment_time_end                       mv a0, s1                                                 ; a0 = number of digits to update
                                         lw s1, 4[sp]
                                         lw ra, [sp]
                                         addi sp, sp, 8
                                         ret


; increment_base_60
; Purpose: Increment seconds and minutes
; Input: a0 = original value (8 bits)
; Output: a0 = incremented value (8 bits), carry (bit 8), digits updated (bits 9&10)
; Modifies: a0, t0, t1, t2
increment_base_60:
                                         andi t0, a0, MASK_LOWER_DIGIT                             ; t0 = lower digit
                                         andi t1, a0, MASK_UPPER_DIGIT                             ; t1 = upper digit
                                         srli t1, t1, 4
                                         li a0, DIGITS_UPDATED_1                                   ; reset a0, 1 digit updated

                                         addi t0, t0, 1                                            ; increment lower digit
                                         li t2, 10
                                         blt t0, t2, increment_base_60_repack                      ; lower digit < 10

increment_base_60_lower_overflow         li t0, 0                                                  ; reset lower digit
                                         addi t1, t1, 1                                            ; increment upper digit
                                         li a0, DIGITS_UPDATED_2                                   ; 2 digits updated
                                         li t2, 6
                                         blt t1, t2, increment_base_60_repack                      ; upper digit < 6

increment_base_60_upper_overflow         li t1, 0                                                  ; reset upper digit
                                         ori a0, a0, SET_CARRY                                     ; carry = 1

increment_base_60_repack                 slli t1, t1, 4
                                         or a0, a0, t1                                             ; set upper digit
                                         or a0, a0, t0                                             ; set lower digit
                                         ret

; increment_base_24
; Purpose: Increment hours
; Input: a0 = original value (8 bits)
; Output: a0 = incremented value (8 bits), carry (bit 8), digits updated (bits 9&10)
; Modifies a0, t0, t1, t2
increment_base_24:
                                         andi t0, a0, MASK_LOWER_DIGIT                             ; t0 = lower digit
                                         andi t1, a0, MASK_UPPER_DIGIT                             ; t1 = upper digit
                                         srli t1, t1, 4
                                         li a0, DIGITS_UPDATED_1                                   ; reset a0, 1 digit updated

                                         addi t0, t0, 1                                            ; increment lower digit
                                         li t2, 2
                                         bge t1, t2, increment_base_24_upper_2                     ; handle 2X increment


increment_base_24_upper_0or1             li t2, 10
                                         blt t0, t2, increment_base_24_repack                      ; lower digit < 10

increment_base_24_upper_0or1_overflow    li t0, 0                                                  ; reset lower digit
                                         addi t1, t1, 1                                            ; increment upper digit
                                         li a0, DIGITS_UPDATED_2                                   ; 2 digits updated
                                         j increment_base_24_repack

increment_base_24_upper_2                li t2, 4
                                         blt t0, t2, increment_base_24_repack

increment_base_24_upper_2_overflow       li a0, DIGITS_UPDATED_2 | SET_CARRY                       ; 2 digits updated, carry = 1
                                         j increment_base_24_end

increment_base_24_repack                 slli t1, t1, 4
                                         or a0, a0, t1
                                         or a0, a0, t0
increment_base_24_end                    ret



; update_display
; Purpose: Updates digits up to position on the LCD display
; Input: a0 = number of characters to update (from the right, 1-based)
; Uses: s0 = current time in BCD
; Modifies: a0, t0, t1
display_position_map                     defb 0, 1, MAP_SEPARATOR_CODE, 2
                                         defb 3, MAP_SEPARATOR_CODE, 4, 5
                                         align

update_display:
                                         subi sp, sp, 12
                                         sw ra, 0[sp]
                                         sw s1, 4[sp]
                                         sw s2, 8[sp]

                                         mv s1, a0                                                 ; s1 = number of characters to update (saved)
                                         mv s2, a0                                                 ; s2 = characters to update
                                         blez s2, update_display_end                               ; nothing to update

update_display_clear_loop                li a0, '\b'                                               ; Clears required characters
                                         call write_char
                                         subi s2, s2, 1
                                         bgtz s2, update_display_clear_loop

update_display_write_loop                subi s1, s1, 1                                            ; s1 = next character index from right
                                         bltz s1, update_display_end

                                         la t0, display_position_map                               ; Gets type of character and digit position from map
                                         add t0, t0, s1
                                         lbu t0, [t0]                                              ; t0 = digit pos / separator code

                                         li t1, MAP_SEPARATOR_CODE                                 ; branch for separator
                                         beq t0, t1, update_display_separator

update_display_digit                     slli t0, t0, 2
                                         srl a0, s0, t0                                            ; extract and display digit from BCD time
                                         andi a0, a0, MASK_DIGIT
                                         call write_decimal
                                         j update_display_write_loop

update_display_separator                 li a0, ':'                                                ; displays a separator
                                         call write_char
                                         j update_display_write_loop

update_display_end                       lw s2, 8[sp]
                                         lw s1, 4[sp]
                                         lw ra, 0[sp]
                                         addi sp, sp, 12
                                         ret

; --- Includes ---
                                         include lib/lcd.s
