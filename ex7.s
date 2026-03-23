                       include os/init.s
STACK_SIZE             EQU 32
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER                                   ; Enable timer interrupt (bit 4)
TIMER_INTERVAL_MS      EQU 5                                                      ; 5 ms


start:
                       li a0, TIMER_INTERVAL_MS * (TIMER_TICKS_PER_SEC / 1000)
                       li a7, ECALL_TIMER_START
                       ecall

                       j .                                                        ; mail polling
