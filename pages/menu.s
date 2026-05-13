; -----------------------------------------------------------------------------
;                            Menu Page
;                            Oliver Harris
;
; Implements a menu page, which can be navigated with the buttons.
;
; Last modified: 130/05/26
; -----------------------------------------------------------------------------

; --- Menu Page ---

MENU_TABLE             DEFW MENU_MESSAGE
                       DEFW MENU_CALCULATOR
                       DEFW MENU_HISTORY
                       DEFW MENU_PIANO
MENU_TABLE_END         DEFW MENU_DEBUG

MENU_PAGES             EQU (MENU_TABLE_END - MENU_TABLE) / 4 + 1

menu_current_page      DEFB 0

; Menu Strings
WELCOME_MESSAGE        DEFB "\f", 0
KEY_MESSAGE            DEFB "\fKey Pressed: \n", 0
MENU_TITLE             DEFB "\fMain Menu:    \n", 0
MENU_MESSAGE           DEFB "  Select Mode  >", 0
MENU_CALCULATOR        DEFB "<  Calculator  >", 0
MENU_HISTORY           DEFB "<   History    >", 0
MENU_PIANO             DEFB "<    Piano     >", 0
MENU_DEBUG             DEFB "<    Debug      ", 0
                       align

menu_jump_table        defw menu_home
                       defw menu_okay
                       defw menu_left
menu_jump_table_end    defw menu_right



; menu_handler
; Purpose: Handle button presses, then call menu_render to update menu page.
; Input: a0 = button pressed
menu_handler           subi sp, sp, 4
                       sw ra, [sp]

                       subi t0, a0, KEYBOARD_BUTTONS                         ; t0 = index (0-3 expected)
                       li t1, (menu_jump_table_end - menu_jump_table) / 4
                       bgtu t0, t1, menu_handler_end                         ; If index is out of bounds, return to main loop

                       slli t0, t0, 2
                       la t1, menu_jump_table
                       add t0, t0, t1                                        ; t0 = address of appropriate handler
                       lw t0, [t0]
                       jalr t0                                               ; Jump to appropriate handler, then continue

                       call menu_render                                      ; Render menu page after handling button press

menu_handler_end       lw ra, [sp]
                       addi sp, sp, 4
                       ret


; menu_render
; Purpose: Render menu page based on current state and menu page.
menu_render            subi sp, sp, 4
                       sw ra, [sp]

                       la a0, MENU_TITLE
                       call write_string

                       la t0, menu_current_page
                       lb t0, [t0]
                       slli t0, t0, 2                                        ; t0 = current state * 4

                       la t1, MENU_TABLE                                     ; t1 = base address of menu table
                       add t1, t1, t0                                        ; t1 = address of current menu entry
                       lw a0, [t1]                                           ; a0 = address of menu string
                       call write_string

                       lw ra, [sp]
                       addi sp, sp, 4
                       ret




; menu_home
; Purpose: Handler for home button, switches to to menu and resets menu page to 0.
menu_home:
                       la t0, current_state
                       sb zero, [t0]                                         ; Set state to menu
                       la t0, menu_current_page
                       sb zero, [t0]                                         ; Reset menu page to 0
                       ret

; menu_okay
; Purpose: Handler for okay button, selects current menu page and switches to appropriate state.
menu_okay:
                       la t0, menu_current_page
                       lb t0, [t0]                                           ; t0 = current menu page
                       la t1, current_state
                       sb t0, [t1]                                           ; Set state to current menu page
                       ret

; menu_left
; Purpose: Handler for left button, decrements menu page without wrapping.
menu_left:
                       la t0, menu_current_page
                       lb t1, [t0]                                           ; t1 = current menu page
                       blez t1, menu_left_end                                ; If on page 0, don't decrement
                       subi t1, t1, 1                                        ; Move page left
                       sb t1, [t0]
menu_left_end          ret

; menu_right
; Purpose: Handler for right button, increments menu page without wrapping.
menu_right
                       la t0, menu_current_page
                       lb t1, [t0]
                       li t2, MENU_PAGES - 1
                       bgeu t1, t2, menu_right_end                           ; If on last page, don't increment
                       addi t1, t1, 1                                        ; Move page right
                       sb t1, [t0]
menu_right_end         ret
