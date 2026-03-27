                       include os/init.s
STACK_SIZE             EQU 32
EXTERNAL_INTERRUPTS    EQU MASK_INTERRUPT_TIMER | MASK_INTERRUPT_BUTTON           ; Enable timer and button interrupts (bits 4 and 5)
TIMER_INTERVAL_MS      EQU 2                                                      ; 1 ms


                       PREVKEY DEFB 0
                       align

start:
                       li a0, TIMER_INTERVAL_MS * (TIMER_TICKS_PER_SEC / 1000)
                       li a7, ECALL_TIMER_START
                       ecall

main_loop              j poll_key
                       j main_loop



poll_key:
                       li a7, ECALL_GET_KEY
                       ecall

                       beqz a0, main_loop
                       subi a0, a0, 1                                             ; convert to 0..15 key index

                       la t1, PREVKEY
                       lb t0, [t1]
                       beq a0, t0, main_loop
                       sb a0, [t1]

                       li a1, 1
                       call write_hex

                       j poll_key


; Includes
                       include lib/lcd.s
