; --------------------------------------------
;              OS Initialisation
;                Oliver Harris
;
;  Last Modified: 02/03/2026
;
;  Requires: STACK_SIZE (bytes), start label
;
; --------------------------------------------

; --- CONSTANTS ---
          include os_globals.s


; --- INITIALISATION ---
m_init    li t0, 0x0000_1800       ; Load MPP mask - bits 12 & 11
          csrc MSTATUS, t0         ; Clear MPP bits in status
          la t0, m_handler         ; Define trap handler
          csrw MTVEC, t0           ;
          la sp, MSTACK_END        ; Define machine stack pointer (stack grows down)
          csrw MSCRATCH, sp        ;
          la sp, USTACK_END        ; Switch to user stack pointer (stack grows down)
          la ra, start             ; Set return to start of program
          csrw MEPC, ra            ;
          mret                     ; Start program in user mode

; --- MACHINE INCLUDES ---
          include traps.s


; --- MACHINE STACK
MSTACK    DEFS MSTACK_SIZE
MSTACK_END


; --- USER STACK ---
          ORG USER_BASE_ADDRESS

USTACK    DEFS STACK_SIZE
USTACK_END


; --- USER INCLUDES ---
include ../lib/delay.s
