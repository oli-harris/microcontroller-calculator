                       include os/init.s
STACK_SIZE             EQU 32
EXTERNAL_INTERRUPTS    EQU INTERRUPT_BUTTON    ; Enable button interrupt (bit 5)

start:
                       j .
