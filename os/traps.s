; -----------------------------
;         Trap Handlers
;         Oliver Harris
;
;  Last Modified: 06/03/2026
;
; -----------------------------

; --- HANDLE TRAPS ---
; m_handler
; Purpose: Use jump table to call correct handler for trap cause, then return to user level
; Preserves: ra, sp, s0, s1
m_handler             csrrw sp, MSCRATCH, sp              ; Save user sp, use machine sp
                      subi sp, sp, 12                     ; Push working registers
                      sw s1, 8[sp]
                      sw s0, 4[sp]
                      sw ra, [sp]

                      csrr t0, MCAUSE                     ; t0 = Cause of exception
                      andi t0, t0, 0xF                    ; Guarantee in range
                      la t1, trap_table                   ; t1 = pointer to table
                      slli t0, t0, 2                      ; Multiply cause to word offset
                      add t1, t0, t1                      ; t0 = pointer to index in table
                      lw t1, [t1]
                      jalr t1                             ; Call exception handler

                      csrrw t0, MEPC, t0                  ; Find the trapping instruction PC
                      addi t0, t0, 4                      ; RA + 4 for ecall (temporary)
                      csrrw t0, MEPC, t0                  ; Swap back in
                      lw ra, [sp]                         ; Pop working registers
                      lw s0, 4[sp]
                      lw s1, 8[sp]
                      addi sp, sp, 12
                      csrrw sp, MSCRATCH, sp              ; Save machine sp, use user sp
                      mret                                ; Return to user level


trap_table            defw trap_handler_halt              ;  0 Instruction address misaligned
                      defw trap_handler_halt              ;  1 Instruction access fault
                      defw trap_handler_halt              ;  2 Illegal instruction
                      defw trap_handler_halt              ;  3 Breakpoint
                      defw trap_handler_halt              ;  4 Load address misaligned
                      defw trap_handler_halt              ;  5 Load access fault
                      defw trap_handler_halt              ;  6 Store address misaligned
                      defw trap_handler_halt              ;  7 Store access fault
                      defw trap_handler_ecall             ;  8 Environment call from U-mode
                      defw trap_handler_ecall             ;  9 Environment call from S-mode
                      defw trap_handler_halt              ; 10 Reserved
                      defw trap_handler_halt              ; 11 Environment call from M-mode
                      defw trap_handler_halt              ; 12 Instruction page fault
                      defw trap_handler_halt              ; 13 Load page fault
                      defw trap_handler_halt              ; 14 Reserved for future standard use
                      defw trap_handler_halt              ; 15 Store page fault


; --- Exception Handlers ---

; trap_handler_halt
; Halts program, displays cause in t0
trap_handler_halt     srli t0, t0, 2
                      j .                                 ; halts

; trap_handler_reset
; Re-initialise program (doesn't clear memory/registers)
trap_handler_reset    j m_init


; trap_handler_ecall
; Passes ecall to correct handler
; Input: a0 = function argument, a7 = ecall type
trap_handler_ecall    subi sp, sp, 4
                      sw ra, [sp]

                      li t1, ECALL_MAX
                      bgeu a7, t1, trap_handler_halt      ; halt if unknown ecall, preserves cause
                      la t0, ecall_table
                      slli t1, a7, 2
                      add t0, t0, t1
                      lw t0, [t0]
                      jalr t0

                      lw ra, [sp]
                      addi sp, sp, 4
                      ret


ecall_table           defw ecall_lcd_write                ; 0 = write data char to lcd
                      defw ecall_set_leds                 ; 1 = set LEDs
                      defw ecall_changed_buttons          ; 2 = detect changed buttons
                      defw ecall_timer_init               ; 3 = initialize timer
                      defw ecall_timer_check_increment    ; 4 = check timer compare flag


; --- Include ECALL Handlers ---
                      include ecalls/lcd.s
                      include ecalls/leds.s
                      include ecalls/buttons.s
                      include ecalls/timer.s
