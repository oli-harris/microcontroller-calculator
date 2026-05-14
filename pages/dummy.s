; -----------------------------------------------------------------------------
;                              Dummy Page
;                            Oliver Harris
;
; Implements a dummy page, which can be navigated with the buttons.
;
; Last modified: 13/05/26
; -----------------------------------------------------------------------------

; ---  Page ---

; dummy_init
; Purpose: Initialise dummy page.
dummy_init           subi sp, sp, 4
                     sw ra, [sp]


                     lw ra, [sp]
                     addi sp, sp, 4
                     ret

; dummy_handler
; Purpose: Handle button presses, then call dummy_render to update dummy page.
; Input: a0 = button pressed
dummy_handler        subi sp, sp, 4
                     sw ra, [sp]


                     call dummy_render    ; Render dummy page after handling button press

dummy_handler_end    lw ra, [sp]
                     addi sp, sp, 4
                     ret


; dummy_render
; Purpose: Render dummy page based on current state and dummy page.
dummy_render         subi sp, sp, 4
                     sw ra, [sp]


                     lw ra, [sp]
                     addi sp, sp, 4
                     ret



