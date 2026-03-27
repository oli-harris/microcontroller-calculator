; --------------------------------------------------------------------------
;                      Interrupt Handlers
;                        Oliver Harris
;
; A collection of interrupt handlers, including the timer interrupt
; which can be linked to a user-defined function.
;
; Last Modified: 27/03/26
;
; --------------------------------------------------------------------------

; interrupt_timer
; Purpose: Handles timer interrupt, calls desired functions
; Input: None
; Output: None
; Modifies: t0, t1
interrupt_timer:
                            subi sp, sp, 4
                            sw ra, [sp]

                            la t0, HARDWARE_BASE_ADDRESS         ; clear terminal count flag
                            li t1, TIMER_TERMINAL_COUNT_CLR
                            sw t1, OFFSET_TIMER_CLEAR[t0]

                            call keyboard_scanner                ; call desired functions

                            lw ra, [sp]
                            addi sp, sp, 4
                            ret

; interrupt_button
; Purpose: Handles button interrupt, for debug
interrupt_button:
                            call keyboard_scanner
                            ret

KEYS_BUFFER                 DEFS 16                              ; FIFO queue to store pressed keys
KEYS_BUFFER_SIZE            EQU 16


; 1 byte saturating counter for each key
; key = row * 4 + column
KEY_COUNTERS                DEFS 16
KEYS_MAX                    EQU 5
                            align

; keyboard_scanner
; Purpose: Scans keyboard, updates counters, appends pressed key to keys buffer
keyboard_scanner:
                            subi sp, sp, 4
                            sw ra, [sp]

                            la t0, HARDWARE_BASE_ADDRESS         ; t0 always base address

                            li t2, KEYBOARD_DIRECTIONS           ; setup keyboard
                            sw t2, OFFSET_PIO_DIRECTION[t0]

                            li t1, 0                             ; t1 = current row
keyboard_rows_loop          li t2, MASK_KEYBOARD_ROWS            ; set all rows inactive
                            sw t2, OFFSET_PIO_CLEAR[t0]
nop
nop
                            li t2, KEYBOARD_ROW_START            ; set current row active
                            sll t2, t2, t1
                            sw t2, OFFSET_PIO_SET[t0]
nop
nop
                            lw t2, OFFSET_PIO_DATA[t0]           ; t2 = buttons pressed in current row
                            srli t2, t2, 12

                            li t3, 0                             ; t3 = current column
keyboard_columns_loop       mv t4, t2                            ; t4 = button value at (row, column)
                            srl t4, t4, t3
                            andi t4, t4, 1

                            la t5, KEY_COUNTERS                  ; t5 = pointer to current key counter
                            slli t6, t1, 2                       ;    = key_counters + row*4 + col
                            add t5, t5, t6
                            add t5, t5, t3

                            bnez t4, button_pressed

button_not_pressed          lb t4, [t5]
                            blez t4, button_next                 ; if counter > 0 continue
                            subi t4, t4, 1                       ; else decrement counter
                            sb t4, [t5]
                            j button_next

button_pressed              lb t4, [t5]
                            li t6, KEYS_MAX
                            bgt t4, t6, button_next              ; if counter > max continue
button_pressed_increment    addi t4, t4, 1                       ; else increment counter
                            sb t4, [t5]
                            bne t4, t6, button_next              ; if counter != max continue
button_pressed_max          la t6, KEY_COUNTERS                  ; else if counter == max, add key to buffer
                            sub t5, t5, t6                       ; t5 = key
                            addi t5, t5, 1                       ; t5 = key + 1 (to avoid 0)
                            la t6, KEYS_BUFFER
                            sb t5, [t6]                          ; store key in buffer[0]

button_next                 addi t3, t3, 1
                            li t6, KEYBOARD_COLUMNS
                            blt t3, t6, keyboard_columns_loop

keyboard_columns_exit       addi t1, t1, 1                       ; next row
                            li t2, KEYBOARD_ROWS
                            blt t1, t2, keyboard_rows_loop

keyboard_rows_exit          lw ra, [sp]
                            addi sp, sp, 4
                            ret
