                   li t1, BUTTONS_ADDRESS
start              lb t0, [t1]
                   j start

BUTTONS_ADDRESS    EQU 0x0001_0001
