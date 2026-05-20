; --------------------------------------------------------
;               Driver for 4 on-board buttons
;                      Oliver Harris
;
; Scans the buttons, and adds to buffer via keys.s
; Also implements interrupt handler, if enabled
;
; Requires: keys.s
;
; Last modified: 13/05/26
; --------------------------------------------------------

; button_scanner
; Purpose: Scans 4 buttons, and adds to key buffer with debounce functionality
; Loop unrolled for efficiency
; Input: None
; Output: None
; Note: uses return address to store next instruction, to avoid branching and save instructions
; Modifies: a0, a2, t0, t1, t2
button_scanner:
                      subi sp, sp, 4
                      sw ra, [sp]

                      li t0, HARDWARE_BASE_ADDRESS
                      lb t0, OFFSET_BUTTONS[t0]       ; t0 = current value of buttons

                      la t2, BUTTONS_COUNTERS

button_scanner_1      la ra, button_scanner_2
                      addi a0, t2, 0                  ; a0 = pointer to counter for button 1
                      andi t1, t0, MASK_BUTTON_1      ; mask button 1
                      beqz t1, button_not_pressed
                      j button_pressed

button_scanner_2      la ra, button_scanner_3
                      addi a0, t2, 1                  ; a0 = pointer to counter for button 2
                      andi t1, t0, MASK_BUTTON_2      ; mask button 2
                      beqz t1, button_not_pressed
                      j button_pressed

button_scanner_3      la ra, button_scanner_4
                      addi a0, t2, 2                  ; a0 = pointer to counter for button 3
                      andi t1, t0, MASK_BUTTON_3      ; mask button 3
                      beqz t1, button_not_pressed
                      j button_pressed

button_scanner_4      la ra, button_scanner_end
                      addi a0, t2, 3                  ; a0 = pointer to counter for button 4
                      andi t1, t0, MASK_BUTTON_4      ; mask button 4
                      beqz t1, button_not_pressed
                      j button_pressed


button_scanner_end    lw ra, [sp]
                      addi sp, sp, 4
                      ret




; interrupt_button
; Note: Debug to reset entire program.
interrupt_button:
                      j .

