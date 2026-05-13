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


STACK_SIZE             EQU 64
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER

; --- Global State ---
STATE_MENU             EQU 0
STATE_CALCULATOR       EQU 1
STATE_HISTORY          EQU 2
STATE_PIANO            EQU 3
STATE_DEBUG            EQU 4

current_state          DEFB STATE_MENU
                       align


; --- Main Loop Logic ---

; start
; Purpose: Initialise program
start:
                       la a0, 0x10                 ; Cheat by simulating menu button press on start
                       la ra, main_loop
                       call menu_handler

; main_loop
; Purpose: Poll keys buffer, and handle in appropriate state.
main_loop:
                       li a7, ECALL_GET_KEY
                       ecall

                       bgez a0, state_switch       ; If a button was pressed, switch state
                       j main_loop                 ; else, keep looping


; state_switch
; Purpose: Switch to appropriate state, and call function
; Input: a0 = button pressed (1-4)
; Calls functions with a0 = button pressed
state_switch           la t0, current_state
                       lb t0, [t0]

                       la ra, state_switch_end
                       beqz t0, menu_handler

state_switch_end       j main_loop



; --- Pages ---
; Each page has a handler, which is called when a button is pressed on that page, and a render.
                       include pages/menu.s
