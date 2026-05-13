; --------------------------------------------------------------------
;                    16 Digit Keyboard Driver
;                          Oliver Harris
; Scans the 16-digit keyboard, and adds to key buffer via keys.s
;
; Requires: keys.s
;
; Last modified: 13/05/26
; --------------------------------------------------------------------

; keyboard_scanner
; Purpose: Scans each row and column of 16-digit keyboard,
; and calls button_pressed or button_not_pressed
; Modifies: a0, a2, t0-t5
keyboard_scanner:
                         subi sp, sp, 4
                         sw ra, [sp]

                         la t0, HARDWARE_BASE_ADDRESS         ; t0 always base address

                         li t2, KEYBOARD_DIRECTIONS           ; setup keyboard
                         sw t2, OFFSET_PIO_DIRECTION[t0]

                         li t1, 0                             ; t1 = current row
keyboard_rows_loop       li t2, MASK_KEYBOARD_ROWS            ; set all rows inactive
                         sw t2, OFFSET_PIO_CLEAR[t0]

                         li a2, 2
                         call delay_loop

                         li t2, KEYBOARD_ROW_START            ; set current row active
                         sll t2, t2, t1
                         sw t2, OFFSET_PIO_SET[t0]
                         lw t2, OFFSET_PIO_DATA[t0]           ; t2 = buttons pressed in current row
                         srli t2, t2, 12

                         li t3, 0                             ; t3 = current column
keyboard_columns_loop    mv t4, t2
                         srl t4, t4, t3                       ; shift to bit 0
                         andi t4, t4, 1                       ; t4 = button value (0 or 1) for current row and column

                         la a0, KEYBOARD_COUNTERS             ;
                         slli t5, t1, 2                       ;
                         add a0, a0, t5                       ; (a0 += row * 4)
                         add a0, a0, t3                       ; (a0 += column); a0 = pointer to counter for key at (row, column)

                         la ra, keyboard_next_column
                         bnez t4, button_pressed              ; if button value is 1, button pressed
                         j button_not_pressed                 ; else button not pressed (most likely, so avoid branching)

keyboard_next_column     addi t3, t3, 1
                         li t5, KEYBOARD_COLUMNS
                         blt t3, t5, keyboard_columns_loop

keyboard_next_row        addi t1, t1, 1
                         li t2, KEYBOARD_ROWS
                         blt t1, t2, keyboard_rows_loop

keyboard_scanner_end     lw ra, [sp]
                         addi sp, sp, 4
                         ret

