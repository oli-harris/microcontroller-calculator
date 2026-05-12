; --------------------------------------------------------------------------
;                      Interrupt Handlers
;                        Oliver Harris
;
; A collection of interrupt handlers, including the timer interrupt
; which can be linked to a user-defined function.
;
; Last Modified: 08/05/26
;
; --------------------------------------------------------------------------

timer_5ms                      defb 5
                               align
; interrupt_timer
; Purpose: Handles timer interrupt, configurable to call routines at given intervals
; Input: None
; Output: None
; Modifies: t0, t1
interrupt_timer:
                               subi sp, sp, 4
                               sw ra, [sp]

                               la t0, HARDWARE_BASE_ADDRESS            ; clear terminal count flag
                               li t1, TIMER_TERMINAL_COUNT_CLR
                               sw t1, OFFSET_TIMER_CLEAR[t0]

                               la t0, timer_5ms                        ; 5ms_timer--
                               lb t1, [t0]
                               subi t1, t1, 1
                               sb t1, [t0]

                               bnez t1, interrupt_timer_end            ; if timer not expired, return
                               li t1, 5                                ; else reset timer and call functions
                               sb t1, [t0]
                               call keyboard_scanner
                               call button_scanner

interrupt_timer_end            lw ra, [sp]
                               addi sp, sp, 4
                               ret

; interrupt_button
; Note: Debug to reset entire program.
interrupt_button:
                               j .


; --- Keys Buffer ---

; FIFO Queue to store pressed keys, implemented as a leave one empty circular buffer
KEYS_BUFFER                    DEFS 16                                 ; each key is 1 byte
                               DEFB 0, 0                               ; head (pop), tail (push)
KEYS_BUFFER_SIZE               EQU 16
KEYS_BUFFER_HEAD_OFFSET        EQU 16
KEYS_BUFFER_TAIL_OFFSET        EQU 17
                               align


; key_buffer_push
; Purpose: Push to tail of queue, discard if buffer is full
; Input: a0 = key to push (0-15)
; Output: None
; Modifies: t5, t6 (not used after call, so no need to preserve)
; Preserves: t3, t4
key_buffer_push:
                               subi sp, sp, 8
                               sw t4, 4[sp]
                               sw t3, [sp]

                               la t3, KEYS_BUFFER                      ; t3 always base address of keys buffer
                               lbu t4, KEYS_BUFFER_HEAD_OFFSET[t3]     ; t4 = head index (unsigned)
                               lbu t5, KEYS_BUFFER_TAIL_OFFSET[t3]     ; t5 = tail index (unsigned)
                               addi t6, t5, 1
                               andi t6, t6, KEYS_BUFFER_SIZE - 1       ; t6 = (tail + 1) % KEYS_BUFFER_SIZE

                               beq t4, t6, key_buffer_push_end         ; if head == next tail: discard; buffer is full

                               add t4, t3, t5
                               sb a0, [t4]                             ; else push key to buffer
                               sb t6, KEYS_BUFFER_TAIL_OFFSET[t3]      ; update tail index

key_buffer_push_end            lw t3, [sp]
                               lw t4, 4[sp]
                               addi sp, sp, 8
                               ret

; key_buffer_pop
; Purpose: Pop from head of queue
; Output: a0 = Head of queue, or -1 if queue is empty
; Modifies: t0, t1, t2
key_buffer_pop:
                               la t0, KEYS_BUFFER                      ; t0 always base address of keys buffer
                               lbu t1, KEYS_BUFFER_HEAD_OFFSET[t0]     ; t1 = head index (unsigned)
                               lbu t2, KEYS_BUFFER_TAIL_OFFSET[t0]

                               beq t1, t2, key_buffer_pop_empty        ; if head == tail: return -1

                               add t2, t0, t1                          ; else return head key
                               lb a0, [t2]

                               addi t1, t1, 1                          ; head = (head + 1) % KEYS_BUFFER_SIZE
                               andi t1, t1, KEYS_BUFFER_SIZE - 1
                               sb t1, KEYS_BUFFER_HEAD_OFFSET[t0]
                               ret

key_buffer_pop_empty           li a0, -1
                               ret


; --- Scanners ---

; button_scanner
; Purpose: Scans 4 buttons, and adds to key buffer with debounce functionality
; Loop unrolled for efficiency
button_scanner:
                               subi sp, sp, 4
                               sw ra, [sp]

                               li t0, HARDWARE_BASE_ADDRESS
                               lb t0, OFFSET_BUTTONS[t0]               ; t0 = current value of buttons

                               la t2, BUTTONS_COUNTERS

button_scanner_1               la ra, button_scanner_2
                               addi a0, t2, 0                          ; a0 = pointer to counter for button 1
                               andi t1, t0, MASK_BUTTON_1              ; mask button 1
                               beqz t1, button_not_pressed
                               j button_pressed

button_scanner_2               la ra, button_scanner_3
                               addi a0, t2, 1                          ; a0 = pointer to counter for button 2
                               andi t1, t0, MASK_BUTTON_2              ; mask button 2
                               beqz t1, button_not_pressed
                               j button_pressed

button_scanner_3               la ra, button_scanner_4
                               addi a0, t2, 2                          ; a0 = pointer to counter for button 3
                               andi t1, t0, MASK_BUTTON_3              ; mask button 3
                               beqz t1, button_not_pressed
                               j button_pressed

button_scanner_4               la ra, button_scanner_end
                               addi a0, t2, 3                          ; a0 = pointer to counter for button 4
                               andi t1, t0, MASK_BUTTON_4              ; mask button 4
                               beqz t1, button_not_pressed
                               j button_pressed


button_scanner_end             lw ra, [sp]
                               addi sp, sp, 4
                               ret



; keyboard_scanner
; Purpose: Scans 16-digit keyboard, and adds to key buffer with debounce and auto-repeat functionality
; Modifies: a0, a2, t0-t5
keyboard_scanner:
                               subi sp, sp, 4
                               sw ra, [sp]

                               la t0, HARDWARE_BASE_ADDRESS            ; t0 always base address

                               li t2, KEYBOARD_DIRECTIONS              ; setup keyboard
                               sw t2, OFFSET_PIO_DIRECTION[t0]

                               li t1, 0                                ; t1 = current row
keyboard_rows_loop             li t2, MASK_KEYBOARD_ROWS               ; set all rows inactive
                               sw t2, OFFSET_PIO_CLEAR[t0]

                               li a2, 2
                               call delay_loop

                               li t2, KEYBOARD_ROW_START               ; set current row active
                               sll t2, t2, t1
                               sw t2, OFFSET_PIO_SET[t0]
                               lw t2, OFFSET_PIO_DATA[t0]              ; t2 = buttons pressed in current row
                               srli t2, t2, 12

                               li t3, 0                                ; t3 = current column
keyboard_columns_loop          mv t4, t2
                               srl t4, t4, t3                          ; shift to bit 0
                               andi t4, t4, 1                          ; t4 = button value (0 or 1) for current row and column

                               la a0, KEYBOARD_COUNTERS                ;
                               slli t5, t1, 2                          ;
                               add a0, a0, t5                          ; (a0 += row * 4)
                               add a0, a0, t3                          ; (a0 += column); a0 = pointer to counter for key at (row, column)

                               la ra, keyboard_next_column
                               bnez t4, button_pressed                 ; if button value is 1, button pressed
                               j button_not_pressed                    ; else button not pressed (most likely, so avoid branching)

keyboard_next_column           addi t3, t3, 1
                               li t5, KEYBOARD_COLUMNS
                               blt t3, t5, keyboard_columns_loop

keyboard_next_row              addi t1, t1, 1
                               li t2, KEYBOARD_ROWS
                               blt t1, t2, keyboard_rows_loop

keyboard_scanner_end           lw ra, [sp]
                               addi sp, sp, 4
                               ret



; --- Debounce Logic ---

; Data structure for 1D saturating counter array
; (key = row * 4 + column)
KEYBOARD_COUNTERS              DEFS 16                                 ; each key is 1 byte
BUTTONS_COUNTERS               DEFS 4                                  ; each button is 1 byte

KEY_LAST_PRESSED               DEFB -1                                 ; for repeat functionality
KEYS_TRIGGER                   EQU 2
KEYS_REPEAT                    EQU 100
KEYS_REPEAT_RESET              EQU 60
                               align


; button_not_pressed
; Purpose: Counter = max(0, counter - 1), slowly decrements counter when button not pressed
; Input: a0 = pointer to counter for key at (row, column)
; Modifies: t4
button_not_pressed             lb t4, [a0]                             ; t4 = counter for key at (row, column)
                               bgtz t4, button_not_pressed_continue    ; if counter > 0 decrement counter
                               ret                                     ; else, continue (most likely so avoid branching)
button_not_pressed_continue    subi t4, t4, 1
                               sb t4, [a0]
                               ret


; button_pressed
; Purpose: Counter++, triggers button press and auto-repeats key with rollover.
; Input: a0 = pointer to counter for key at (row, column)
; Modifies: t4, t5, a0, t6 (by calling key_buffer_push)
button_pressed                 lb t4, [a0]                             ; increment counter
                               addi t4, t4, 1
                               sb t4, [a0]

                               li t5, KEYS_TRIGGER
                               blt t4, t5, button_pressed_end          ; if counter < trigger, continue
                               beq t4, t5, button_pressed_first        ; else if counter == trigger, button pressed

                               li t5, KEYS_REPEAT
                               bne t4, t5, button_pressed_end          ; if counter != repeat, continue

button_pressed_repeat          li t5, KEYS_REPEAT_RESET                ; else if counter == repeat, reset counter
                               sb t5, [a0]

                               la t5, KEY_LAST_PRESSED                 ; check rollover
                               lb t5, [t5]
                               la t4, KEYBOARD_COUNTERS
                               sub t4, a0, t4                          ; t4 = key
                               bne t5, t4, button_pressed_end          ; if not last pressed key, continue
                               j button_pressed_push                   ; else trigger button press

button_pressed_first           la t5, KEY_LAST_PRESSED                 ; set last_pressed = key
                               la t4, KEYBOARD_COUNTERS
                               sub t4, a0, t4                          ; t4 = key
                               sb t4, [t5]

button_pressed_push            la t5, KEYBOARD_COUNTERS                ; get key value as index from base counter pointer
                               sub a0, a0, t5                          ; a0 = key

                               j key_buffer_push                       ; push key to buffer, then returns
button_pressed_end             ret



