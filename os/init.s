; --------------------------------------------
;              OS Initialisation
;                Oliver Harris
;
;  Last Modified: 20/03/2026
;
;  Requires: STACK_SIZE (words)
;            EXTERNAL_INTERRUPTS (bits to enable)
;            start label
;
; --------------------------------------------

; --- CONSTANTS ---
          include os_globals.s


; --- INITIALISATION ---
m_init    li t0, MSTATUS_MPP_MACHINE            ; Clear MPP bits in status
          csrc MSTATUS, t0
          la t0, m_handler                      ; Define trap handler
          csrw MTVEC, t0
          la sp, MSTACK_END                     ; Define machine stack pointer (stack grows down)
          csrw MSCRATCH, sp
          la sp, USTACK_END                     ; Switch to user stack pointer (stack grows down)
          la ra, start                          ; Set return to start of program
          csrw MEPC, ra

          li t0, MIE_EXTERNAL                   ; Enable external interrupts
          csrw MIE, t0
          li t0, MSTATUS_MIE                    ; Enable globally machine interrupts
          csrs MSTATUS, t0
          la t1, EXTERNAL_INTERRUPTS            ; Enable specified external interrupts
          li t0, HARDWARE_BASE_ADDRESS
          sw t1, OFFSET_INTERRUPT_ENABLE[t0]

          mret                                  ; Start program in user mode

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
