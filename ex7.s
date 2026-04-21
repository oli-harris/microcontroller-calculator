                       include os/init.s
STACK_SIZE             EQU 64
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER | MASK_INTERRUPT_BUTTON           ; Enable timer and button interrupts (bits 4 and 5)
TIMER_INTERVAL_MS      EQU 2                                                      ; 1 ms

start:
                       li a0, TIMER_INTERVAL_MS * (TIMER_TICKS_PER_SEC / 1000)
                       li a7, ECALL_TIMER_START
                       ecall

                       li a0, '\f'
                       call write_char

main_loop              j poll_key
                       j main_loop



poll_key:
                       li a7, ECALL_GET_KEY
                       ecall

                       bltz a0, main_loop

                       la t0, KEY_LOOKUP
                       add t0, t0, a0
                       lb a0, [t0]
                       call write_char

                       j poll_key

KEY_LOOKUP             defb "*7410852#963\f=-+"

; Includes
                       include lib/lcd.s
