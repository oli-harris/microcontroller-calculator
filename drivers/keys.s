; ---------------------------------------------------------------------------------
;                               Keys Driver
;                               Oliver Harris
;
; Implements a buffer for pressed keys, which can be popped from by an ecall.
; Any button peripheral can call button_pressed and button_not_pressed to
; implement debouncing, auto-repeat, and rollover functionality.
;
; Known limitations: Key counter buffer must be stored sequentially, as
; their pointer values are used to calculate key value.
;
; Last modified: 13/05/26
;
; ---------------------------------------------------------------------------------

; --- Keyboard Ecalls ---

; ecall_get_key
; Purpose: Get least recently pressed key, or -1 if no key
;          (wrapper for key_buffer_pop so agnostic to implementation)
; Output: a0 = -1 for no key, else 0-15
ecall_get_key:
                               subi sp, sp, 4
                               sw ra, [sp]

                               call key_buffer_pop

                               lw ra, [sp]
                               addi sp, sp, 4
                               ret

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
                               j key_buffer_pop_end

key_buffer_pop_empty           li a0, -1
key_buffer_pop_end             ret



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
                               j button_not_pressed_end                ; else, continue (most likely so avoid branching)
button_not_pressed_continue    subi t4, t4, 1
                               sb t4, [a0]
button_not_pressed_end         ret


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



