; --------------------------------------------------------------------------
;                      Interrupt Handlers
;                        Oliver Harris
;
; A collection of interrupt handlers, including the timer interrupt
; which can be linked to a user-defined function.
;
; Last Modified: 21/04/26
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

                            la t0, HARDWARE_BASE_ADDRESS           ; clear terminal count flag
                            li t1, TIMER_TERMINAL_COUNT_CLR
                            sw t1, OFFSET_TIMER_CLEAR[t0]

                            call keyboard_scanner                  ; call desired functions

                            lw ra, [sp]
                            addi sp, sp, 4
                            ret

; interrupt_button
; Note: Stub handler
interrupt_button:
                            ret


; --- Keyboard ---

; FIFO Queue to store pressed keys, implemented as a leave one empty circular buffer
KEYS_BUFFER                 DEFS 16                                ; each key is 1 byte
                            DEFB 0, 0                              ; head (pop), tail (push)
KEYS_BUFFER_SIZE            EQU 16
KEYS_BUFFER_HEAD_OFFSET     EQU 16
KEYS_BUFFER_TAIL_OFFSET     EQU 17
                            align


; key_buffer_push
; Purpose: Push to tail of queue, discard if buffer is full
; Input: a0 = key to push (0-15)
; Output: Modifies: t3, t4, t5, t6
; Preserves: t3, t4 (to preserve keyboard_scanner state)
key_buffer_push:
                            subi sp, sp, 8
                            sw t4, 4[sp]
                            sw t3, [sp]

                            la t3, KEYS_BUFFER                     ; t3 always base address of keys buffer
                            lbu t4, KEYS_BUFFER_HEAD_OFFSET[t3]    ; t4 = head index (unsigned)
                            lbu t5, KEYS_BUFFER_TAIL_OFFSET[t3]    ; t5 = tail index (unsigned)
                            addi t6, t5, 1
                            andi t6, t6, KEYS_BUFFER_SIZE - 1      ; t6 = (tail + 1) % KEYS_BUFFER_SIZE

                            beq t4, t6, key_buffer_push_end        ; if head == next tail: discard; buffer is full

                            add t4, t3, t5
                            sb a0, [t4]                            ; else push key to buffer
                            sb t6, KEYS_BUFFER_TAIL_OFFSET[t3]     ; update tail index

key_buffer_push_end         lw t3, [sp]
                            lw t4, 4[sp]
                            addi sp, sp, 8
                            ret

; key_buffer_pop
; Purpose: Pop from head of queue
; Output: a0 = Head of queue, or -1 if queue is empty
key_buffer_pop:
                            la t0, KEYS_BUFFER                     ; t0 always base address of keys buffer
                            lbu t1, KEYS_BUFFER_HEAD_OFFSET[t0]    ; t1 = head index (unsigned)
                            lbu t2, KEYS_BUFFER_TAIL_OFFSET[t0]

                            beq t1, t2, key_buffer_pop_empty       ; if head == tail: return -1

                            add t2, t0, t1                         ; else return head key
                            lb a0, [t2]

                            addi t1, t1, 1                         ; head = (head + 1) % KEYS_BUFFER_SIZE
                            andi t1, t1, KEYS_BUFFER_SIZE - 1
                            sb t1, KEYS_BUFFER_HEAD_OFFSET[t0]
                            ret

key_buffer_pop_empty        li a0, -1
                            ret




; 1D saturating counter array,
; key = row * 4 + column
KEY_COUNTERS                DEFS 16                                ; each key is 1 byte
KEYS_MAX                    EQU 5
                            align


; keyboard_scanner
; Purpose: Scans keyboard, updates counters, appends pressed key to keys buffer
; Modifies: a0, a2, t0-t6
keyboard_scanner:
                            subi sp, sp, 4
                            sw ra, [sp]

                            la t0, HARDWARE_BASE_ADDRESS           ; t0 always base address

                            li t2, KEYBOARD_DIRECTIONS             ; setup keyboard
                            sw t2, OFFSET_PIO_DIRECTION[t0]

                            li t1, 0                               ; t1 = current row
keyboard_rows_loop          li t2, MASK_KEYBOARD_ROWS              ; set all rows inactive
                            sw t2, OFFSET_PIO_CLEAR[t0]

                            li a2, 2
                            call delay_loop

                            li t2, KEYBOARD_ROW_START              ; set current row active
                            sll t2, t2, t1
                            sw t2, OFFSET_PIO_SET[t0]
                            lw t2, OFFSET_PIO_DATA[t0]             ; t2 = buttons pressed in current row
                            srli t2, t2, 12

                            li t3, 0                               ; t3 = current column
keyboard_columns_loop       mv t4, t2                              ; t4 = button value at (row, column)
                            srl t4, t4, t3
                            andi t4, t4, 1

                            la t5, KEY_COUNTERS                    ; t5 = pointer to current key counter
                            slli t6, t1, 2                         ;    = key_counters + row*4 + col
                            add t5, t5, t6
                            add t5, t5, t3

                            bnez t4, button_pressed

button_not_pressed          lb t4, [t5]
                            blez t4, button_next                   ; if counter > 0 continue
                            subi t4, t4, 1                         ; else decrement counter
                            sb t4, [t5]
                            j button_next

button_pressed              lb t4, [t5]
                            li t6, KEYS_MAX
                            bgt t4, t6, button_next                ; if counter > max continue
button_pressed_increment    addi t4, t4, 1                         ; else increment counter
                            sb t4, [t5]
                            bne t4, t6, button_next                ; if counter != max continue
button_pressed_max          la t6, KEY_COUNTERS                    ; else if counter == max, add key to buffer
                            sub a0, t5, t6                         ; a0 = key
                            call key_buffer_push

button_next                 addi t3, t3, 1
                            li t6, KEYBOARD_COLUMNS
                            blt t3, t6, keyboard_columns_loop

keyboard_columns_exit       addi t1, t1, 1                         ; next row
                            li t2, KEYBOARD_ROWS
                            blt t1, t2, keyboard_rows_loop

keyboard_rows_exit          lw ra, [sp]
                            addi sp, sp, 4
                            ret
