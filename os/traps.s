; -----------------------------
;         Trap Handlers
;         Oliver Harris
;  Designed to be modular and extensible, with most traps not handled by default.
;  Interrupts are handled asynchronously and preserve all registers,
;  while exceptions are handled synchronously and do not preserve a registers
;  (allows returning values from e calls)
;
;  Last Modified: 28/03/2026
;
; -----------------------------

; --- HANDLE TRAPS ---
; m_handler
; Purpose: Handles interrupts (async) and exceptions (sync).
; Preserves: all registers for interrupts, but not a registers for exceptions
m_handler                        csrrw sp, MSCRATCH, sp                    ; Save user sp, use machine sp
                                 subi sp, sp, 16                           ; Push working registers
                                 sw t2, 12[sp]
                                 sw t1, 8[sp]
                                 sw t0, 4[sp]
                                 sw ra, [sp]

                                 csrr t0, MCAUSE                           ; t0 = Cause of exception
                                 bgez t0, exceptions_handler               ; branch if MSB bit clear

interrupt_handler                subi sp, sp, 24                           ; Push minimal working registers
                                 sw a2, 20[sp]
                                 sw a0, 16[sp]
                                 sw t6, 12[sp]
                                 sw t5, 8[sp]
                                 sw t4, 4[sp]
                                 sw t3, [sp]

                                 andi t0, t0, 0xF                          ; Clear upper bits
                                 li t1, 11
                                 bgtu t0, t1, trap_handler_halt            ; branch if invalid cause
                                 la t1, interrupt_table                    ; t1 = pointer to table
                                 slli t0, t0, 2                            ; Multiply cause to word offset
                                 add t0, t0, t1                            ; t0 = pointer to index in table
                                 lw t0, [t0]
                                 jalr t0                                   ; Call interrupt handler

                                 lw t3, [sp]                               ; Pop working registers
                                 lw t4, 4[sp]
                                 lw t5, 8[sp]
                                 lw t6, 12[sp]
                                 lw a0, 16[sp]
                                 lw a2, 20[sp]
                                 addi sp, sp, 24
                                 j m_handler_end

exceptions_handler               andi t0, t0, 0xF                          ; Guarantee in range
                                 la t1, exception_table                    ; t1 = pointer to table
                                 slli t0, t0, 2                            ; Multiply cause to word offset
                                 add t0, t0, t1                            ; t0 = pointer to index in table
                                 lw t0, [t0]
                                 jalr t0                                   ; Call exception handler

                                 csrrw t0, MEPC, t0                        ; Find the trapping instruction PC
                                 addi t0, t0, 4                            ; RA + 4 for ecall (temporary)
                                 csrrw t0, MEPC, t0                        ; Swap back in

m_handler_end                    lw ra, [sp]                               ; Pop working registers
                                 lw t0, 4[sp]
                                 lw t1, 8[sp]
                                 lw t2, 12[sp]
                                 addi sp, sp, 16
                                 csrrw sp, MSCRATCH, sp                    ; Save machine sp, use user sp
                                 mret                                      ; Return to user level

interrupt_table                  defw trap_handler_ignore                  ; 0 User software interrupt
                                 defw trap_handler_ignore                  ; 1 Supervisor software interrupt
                                 defw trap_handler_ignore                  ; 2
                                 defw trap_handler_ignore                  ; 3 Machine software interrupt
                                 defw trap_handler_ignore                  ; 4 User timer interrupt
                                 defw trap_handler_ignore                  ; 5 Supervisor timer interrupt
                                 defw trap_handler_ignore                  ; 6
                                 defw trap_handler_ignore                  ; 7 Machine timer interrupt
                                 defw trap_handler_ignore                  ; 8 User external interrupt
                                 defw trap_handler_ignore                  ; 9 Supervisor external interrupt
                                 defw trap_handler_ignore                  ; 10
                                 defw trap_handler_ex_interrupt            ; 11 Machine external interrupt

exception_table                  defw trap_handler_halt                    ;  0 Instruction address misaligned
                                 defw trap_handler_halt                    ;  1 Instruction access fault
                                 defw trap_handler_halt                    ;  2 Illegal instruction
                                 defw trap_handler_halt                    ;  3 Breakpoint
                                 defw trap_handler_halt                    ;  4 Load address misaligned
                                 defw trap_handler_halt                    ;  5 Load access fault
                                 defw trap_handler_halt                    ;  6 Store address misaligned
                                 defw trap_handler_halt                    ;  7 Store access fault
                                 defw trap_handler_ecall                   ;  8 Environment call from U-mode
                                 defw trap_handler_ecall                   ;  9 Environment call from S-mode
                                 defw trap_handler_halt                    ; 10
                                 defw trap_handler_halt                    ; 11 Environment call from M-mode
                                 defw trap_handler_halt                    ; 12 Instruction page fault
                                 defw trap_handler_halt                    ; 13 Load page fault
                                 defw trap_handler_halt                    ; 14
                                 defw trap_handler_halt                    ; 15 Store page fault

; --- Interrupt Handlers -- -

; trap_handler_ignore
; Purpose: Default handler, does nothing and returns to user program
trap_handler_ignore              j m_handler_end                           ; used as breakpoint for debugging


; trap_handler_ex_debug
; Purpose: Debug handler for external interrupts, displays interrupt controller state
trap_handler_ex_debug            li t1, HARDWARE_BASE_ADDRESS
                                 lw a0, OFFSET_INTERRUPT_INPUT[t1]
                                 lw a1, OFFSET_INTERRUPT_ENABLE[t1]
                                 lw a2, OFFSET_INTERRUPT_REQUESTS[t1]
                                 lw a3, OFFSET_INTERRUPT_MODE[t1]
                                 lw a4, OFFSET_INTERRUPT_EDGE_CLEAR[t1]
                                 lw a5, OFFSET_INTERRUPT_OUTPUT[t1]
                                 j .


; trap_handler_external_interrupt
; Purpose: simple handler for only timer interrupt
trap_handler_ex_interrupt        subi sp, sp, 4
                                 sw ra, [sp]
                                 li t1, HARDWARE_BASE_ADDRESS
                                 lw t0, OFFSET_INTERRUPT_REQUESTS[t1]      ; t0 = pending interrupts

                                 li t1, MASK_INTERRUPT_TIMER               ; Skip other interrupts
                                 and t1, t1, t0
                                 beqz t1, trap_handler_ex_interrupt_end

                                 la t0, interrupt_timer                    ; Call timer interrupt handler
                                 jalr t0

trap_handler_ex_interrupt_end    lw ra, [sp]
                                 addi sp, sp, 4
                                 ret


; --- Exception Handlers ---

; trap_handler_halt
; Purpose: Halts program, displays mcause, mstatus, mepc for debugging
trap_handler_halt                csrr t0, MCAUSE                           ; display debug info
                                 csrr t1, MSTATUS
                                 csrr t2, MEPC
                                 j .                                       ; halts

; trap_handler_reset
; Purpose: Re-initialise program (doesn't clear memory/registers)
trap_handler_reset               j m_init

; trap_handler_ecall
; Purpose: Passes user ecall to correct handler
; Input: a0 = function argument, a7 = ecall type
; Modifies: t0, t1
trap_handler_ecall               subi sp, sp, 4
                                 sw ra, [sp]

                                 li t1, ECALL_MAX
                                 bgeu a7, t1, trap_handler_halt            ; halt if unknown ecall, preserves cause
                                 la t0, ecall_table
                                 slli t1, a7, 2
                                 add t0, t0, t1
                                 lw t0, [t0]
                                 jalr t0

                                 lw ra, [sp]
                                 addi sp, sp, 4
                                 ret


ecall_table                      defw ecall_lcd_write                      ; 0 = write data char to lcd
                                 defw ecall_set_leds                       ; 1 = set LEDs
                                 defw ecall_changed_buttons                ; 2 = detect changed buttons
                                 defw ecall_timer_start                    ; 3 = start timer
                                 defw ecall_timer_stop                     ; 4 = stop timer
                                 defw ecall_timer_check_increment          ; 5 = check timer compare flag
                                 defw ecall_get_key                        ; 6 = get key from keys buffer


; --- Includes ---
                                 include ecalls.s
                                 include interrupts.s
