; ------------------------------------------------------------------------------------------
;                               Exercise 9 - Project
;                                    Oliver Harris
;
; A calculator with modes for BODMAS, history, and debug tests.
;
; Uses four integrated buttons to select mode.
; SW1: Menu           SW2: OK
; SW3: Left           SW4: Right
;
;
;
; Last Modified: 27/04/2026
; ------------------------------------------------------------------------------------------

; --- Library Includes ---
                       include os/init.s
                       include lib/lcd.s


STACK_SIZE             EQU 128
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER

; --- Global State ---
STATE_MENU             EQU 0
STATE_DEBUG            EQU 1
KEY_MENU               EQU 16


current_state          DEFB STATE_MENU
                       align

state_table            defw menu_handler, menu_render
                       defw calc_handler, calc_render
                       defw test_handler, test_render

; --- Main Loop Logic ---

; start
; Purpose: Initialise program
start:
                       call menu_init
                       j main_loop

; main_loop
; Purpose: Poll keys buffer, and handle in appropriate state.
main_loop:
                       li a7, ECALL_GET_KEY
                       ecall
                       bltz a0, main_loop                 ; If no key pressed, continue polling

                       li t0, KEY_MENU
                       beq a0, t0, global_menu_handler    ; Global handlers here

                       call state_handler                 ; Call button handler
                       call state_renderer                ; Call renderer
                       j main_loop

; global_menu_handler
; Purpose: Handle menu button presses, which should work on any page, and return to main
global_menu_handler:
                       call menu_home
                       call state_renderer
                       j main_loop

; state_handler
; Purpose: Call state handler
; Input: a0 = button pressed (1-20 expected)
; Calls functions with a0 = button pressed
state_handler:
                       subi sp, sp, 4
                       sw ra, [sp]

                       la t0, current_state
                       lb t0, [t0]                        ; t0 = current state
                       la ra, state_handler_end           ; return to end of state switch after handling button press
                       la t1, state_table
                       slli t0, t0, 3                     ; t0 = current state * 8
                       add t0, t0, t1                     ; t0 = pointer to table appropriate handler

                       lw t0, [t0]                        ; Handle button press
                       jalr t0

state_handler_end      lw ra, [sp]
                       addi sp, sp, 4
                       ret

; state_renderer
; Purpose: Call state renderer, separate from handler in case state changes after handling button press.
state_renderer:
                       subi sp, sp, 4
                       sw ra, [sp]

                       la t0, current_state
                       lb t0, [t0]                        ; t0 = current state
                       la ra, state_renderer_end          ; return to end of state switch after rendering page
                       la t1, state_table
                       slli t0, t0, 3                     ; t0 = current state * 8
                       add t0, t0, t1                     ; t0 = pointer to table appropriate renderer

                       lw t0, 4[t0]                       ; Render page
                       jalr t0

state_renderer_end     lw ra, [sp]
                       addi sp, sp, 4
                       ret

; --- Pages ---
; Each page has a handler, a renderer, and an initialization function.
                       include pages/menu.s
                       include pages/calculator.s
                       include pages/test.s
