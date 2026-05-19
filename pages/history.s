; -----------------------------------------------------------------------------
;                              History Page
;                            Oliver Harris
;
; Displays a history page, showing the most recent results ordered by
; most recent first, with the ability to scroll through history pages.
;
; Buttons: SW1: Menu                      SW2: Clear History
;          SW3: Left (no-wrap)            SW4: Right (no-wrap)
;
; Requires: calculator page
;
; Uses: CALC_HISTORY_SIZE, calc_history, calc_history_head, calc_history_count
;
; Last modified: 13/05/26
; -----------------------------------------------------------------------------

; --- Memory ---

history_page            defb 0                                                ; (0 - history size - 1)
                        align

history_buttons         defw history_home
                        defw history_clear
                        defw history_left
history_buttons_end     defw history_right

HISTORY_EMPTY_MSG       DEFB "\fHistory is empty", 0
HISTORY_PAGE_MSG        DEFB "\fHistory (", 0
                        align
; ---  Page ---

; history_init
; Purpose: Initialise history page.
history_init            subi sp, sp, 4
                        sw ra, [sp]

                        la t0, history_page                                   ; set page to 0
                        sb zero, [t0]
                        call history_render                                   ; Initial render

                        lw ra, [sp]
                        addi sp, sp, 4
                        ret

; history_handler
; Purpose: Handle button presses
; Input: a0 = button pressed
history_handler         subi sp, sp, 4
                        sw ra, [sp]

                        subi t0, a0, KEYBOARD_BUTTONS                         ; t0 = index (0-3 expected)
                        li t1, (history_buttons_end - history_buttons) / 4
                        bgtu t0, t1, history_handler_end                      ; If index is out of bounds, return to main loop

                        slli t0, t0, 2
                        la t1, history_buttons
                        add t0, t0, t1                                        ; t0 = address of appropriate handler
                        lw t0, [t0]
                        jalr t0                                               ; Jump to appropriate handler, then continue

history_handler_end     lw ra, [sp]
                        addi sp, sp, 4
                        ret


; history_render
; Purpose: Render history page based on current state and history.
history_render:         subi sp, sp, 4
                        sw ra, [sp]

                        la t0, calc_history_count
                        lbu t0, [t0]                                          ; t0 = count of history entries
                        beqz t0, history_render_empty                         ; If no history, display message

history_render_page     la a0, HISTORY_PAGE_MSG                               ; Top-line: "MSG (page/count)\n"
                        call write_string

                        la t0, history_page
                        lbu t0, [t0]
                        addi a0, t0, 1
                        call write_decimal

                        li a0, '/'
                        call write_char

                        la t0, calc_history_count
                        lbu a0, [t0]
                        call write_decimal

                        li a0, ')'
                        call write_char

                        li a0, '\n'
                        call write_char

                        la t0, calc_history                                   ; Calculate address of page history entry
                        la t1, history_page                                   ; t1 = current page
                        lbu t1, [t1]

                        la t2, calc_history_head                              ; t2 = head of history (most recent entry)
                        lbu t2, [t2]

                        sub t2, t2, t1                                        ; t2 = index of page entry
                        andi t2, t2, CALC_HISTORY_SIZE - 1                    ; wrap index (history size power of 2)

                        slli t2, t2, 3                                        ;  offset =  index * 8
                        add t0, t0, t2                                        ;
                        lw a0, [t0]                                           ; lower entry
                        lw a1, 4[t0]                                          ; upper entry

                        call write_decimal

                        j history_render_end

history_render_empty    la a0, HISTORY_EMPTY_MSG
                        call write_string
                        j history_render_end

history_render_end      lw ra, [sp]
                        addi sp, sp, 4
                        ret


; --- Button Handlers ---

; history_home
; Purpose: dummy, not called
history_home            ret

; history_left
; Purpose: Move left in history, if possible
history_left:
                        la t0, history_page
                        lbu t1, [t0]
                        blez t1, history_left_end                             ; Only move if on history page
                        subi t1, t1, 1
                        sb t1, [t0]
history_left_end        ret


; history_right
; Purpose: Move right in history, if possible
history_right:
                        la t0, history_page
                        lbu t1, [t0]
                        la t2, calc_history_count
                        lbu t2, [t2]
                        subi t2, t2, 1
                        bgeu t1, t2, history_right_end                        ; Only move if not on most recent entry
                        addi t1, t1, 1
                        sb t1, [t0]
history_right_end       ret

; history_clear
; Purpose: Clear history circular array, reset index and count, and return to first page.
; Note: not a secure clear, result still exists in memory.
history_clear:
                        la t0, calc_history_head
                        sb zero, [t0]                                         ; Reset index
                        la t0, calc_history_count
                        sb zero, [t0]                                         ; Reset count

                        la t0, history_page
                        sb zero, [t0]                                         ; Return to first page
                        ret
