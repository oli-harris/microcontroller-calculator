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

m_init    li t0, MSTATUS_MPP_MACHINE            ; Clear MPP bits in status
          csrc MSTATUS, t0
          la t0, m_handler                      ; Define trap handler
          csrw MTVEC, t0
          la sp, MSTACK_END                     ; Define machine stack pointer (stack grows down)
          csrw MSCRATCH, sp
          la sp, USTACK_END                     ; Switch to user stack pointer (stack grows down)
          la ra, start                          ; Set return to start of program
          csrw MEPC, ra

          call peripheral_reset                 ; Reset peripherals


          li t0, MIE_EXTERNAL                   ; Enable external interrupts
          csrw MIE, t0
          li t0, MSTATUS_MIE                    ; Enable globally machine interrupts
          csrs MSTATUS, t0
          la t0, EXTERNAL_INTERRUPTS            ; Enable specified external interrupts
          li t1, HARDWARE_BASE_ADDRESS
          sw t0, OFFSET_INTERRUPT_ENABLE[t1]

          li t0, 0                              ; Clear registers for user program
          li t1, 0
          mret                                  ; Start program in user mode


peripheral_reset:
          la t0, HARDWARE_BASE_ADDRESS          ; Reset timer status
          li t1, 0
          sw t1, OFFSET_TIMER_STATUS[t0]
          ret


; --- MACHINE INCLUDES ---
          include traps.s


; --- MACHINE STACK
          MSTACK DEFS MSTACK_SIZE
MSTACK_END


; --- USER STACK ---
          ORG USER_BASE_ADDRESS

          USTACK DEFS STACK_SIZE * 4
USTACK_END


; --- USER INCLUDES ---
          include ../lib/delay.s

; --- USER CODE ---
