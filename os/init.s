; --------------------------------------------
;              OS Initialisation
;                Oliver Harris
;
;  Last Modified: 20/03/2026
;
; Define the following in the user program to configure the OS:
;  - STACK_SIZE (words)
;  - EXTERNAL_INTERRUPTS (interrupts to enable)
;  - start (entry point of user code)
;
; --------------------------------------------

; --- CONSTANTS ---
                    include globals.s


; --- INITIALISATION ---
; m_init
; Purpose: Initialize machine, set up stacks, reset peripherals, enable interrupts,
;          jump to user code
;          Clears registers before jumping to user code

m_init              li t0, MSTATUS_MPP_MACHINE            ; Clear MPP bits in status
                    csrc MSTATUS, t0
                    la t0, m_handler                      ; Define trap handler
                    csrw MTVEC, t0
                    la sp, MSTACK_END                     ; Define machine stack pointer (stack grows down)
                    csrw MSCRATCH, sp
                    la sp, USTACK_END                     ; Switch to user stack pointer (stack grows down)

                    call peripheral_init                  ; Initialise peripherals

                    li t0, MIE_EXTERNAL                   ; Enable external interrupts
                    csrw MIE, t0
                    li t0, MSTATUS_MIE                    ; Enable globally machine interrupts
                    csrs MSTATUS, t0
                    la t0, EXTERNAL_INTERRUPTS            ; Enable specified external interrupts
                    li t1, HARDWARE_BASE_ADDRESS
                    sw t0, OFFSET_INTERRUPT_ENABLE[t1]

                    li t0, 0                              ; Clear registers for user program
                    li t1, 0

                    la ra, start                          ; Start program in user mode
                    csrw MEPC, ra
                    mret


; --- PERIPHERAL INITIALISATION ---


peripheral_init:
_init_buzzer        la t0, USER_PERIPHERAL_BASE
                    sw zero, OFFSET_BUZZER[t0]            ; Disable buzzer

                    la t0, HARDWARE_BASE_ADDRESS
                    li t1, PIZO_ENABLE_BITS
                    sw t1, OFFSET_PINMUX[t0]              ; Enable pizo speaker

_init_timer         li t1, TIMER_TICK_MS - 1              ; Set timer modulus
                    sw t1, OFFSET_TIMER_MODULUS[t0]

                    li t1, TIMER_INIT_VALUE               ; Enable timer in free running mode
                    sw t1, OFFSET_TIMER_STATUS[t0]

                    ret



; --- ENABLED ECALLS ---

; Included here for modularity, used by trap.s
ecall_table         defw ecall_lcd_write
                    defw ecall_set_leds
                    defw ecall_get_key
ecall_table_end     defw ecall_play_sound

ECALL_LCD_WRITE     EQU 0
ECALL_SET_LEDS      EQU 1
ECALL_GET_KEY       EQU 2
ECALL_PLAY_SOUND    EQU 3


; --- MACHINE INCLUDES ---
                    include traps.s

                    include ../drivers/timer.s
                    include ../drivers/buttons.s
                    include ../drivers/keyboard.s
                    include ../drivers/keys.s
                    include ../drivers/led.s
                    include ../drivers/lcd.s
                    include ../drivers/buzzer.s



; --- MACHINE STACK
                    MSTACK DEFS MSTACK_SIZE * 4
MSTACK_END


; --- USER STACK ---
                    ORG USER_BASE_ADDRESS

                    USTACK DEFS STACK_SIZE * 4
USTACK_END


; --- USER INCLUDES ---
                    include ../lib/delay.s

; --- USER CODE ---
