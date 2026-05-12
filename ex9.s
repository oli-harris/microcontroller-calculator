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


; --- Menu Table ---
MENU_TABLE             DEFW MENU_MESSAGE
                       DEFW MENU_CALCULATOR
                       DEFW MENU_HISTORY
                       DEFW MENU_PIANO
MENU_TABLE_END         DEFW MENU_DEBUG


MENU_TITLE             DEFB "\fMain Menu:    \n", 0
MENU_MESSAGE           DEFB "Select Mode    >", 0
MENU_CALCULATOR        DEFB "<  Calculator  >", 0
MENU_HISTORY           DEFB "<   History    >", 0
MENU_PIANO             DEFB "<    Piano     >", 0
MENU_DEBUG             DEFB "<    Debug      ", 0
                       align

; --- Main Loop Logic ---

start

main_loop              la t0, current_state
                       lb t0, [t0]

                       la ra, state_switch_end

state_switch           beqz t0, menu_render

state_switch_end       j .
                       j main_loop



menu_render            subi sp, sp, 4
                       sw ra, [sp]
                       la a0, MENU_TITLE
                       call write_string

                       la t0, current_state
                       lb t0, [t0]
                       slli t0, t0, 2                  ; t0 = current state * 4

                       la t1, MENU_TABLE               ; t1 = base address of menu table
                       add t1, t1, t0                  ; t1 = address of current menu entry
                       lw a0, [t1]                     ; a0 = address of menu string
                       call write_string

                       lw ra, [sp]
                       addi sp, sp, 4
                       ret








