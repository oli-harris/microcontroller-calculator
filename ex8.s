                       include os/init.s
                       include lib/lcd.s


STACK_SIZE             EQU 64
EXTERNAL_INTERRUPTS    EQU 0

; Note,  delay
                       FURELISE defb 17, 120
                       defb 16, 120
                       defb 17, 120
                       defb 16, 120
                       defb 17, 120
                       defb 12, 120
                       defb 15, 120
                       defb 13, 120
                       defb 10, 240
                       defb 0, 120
                       defb 8, 120
                       defb 10, 120
                       defb 12, 120
                       defb 13, 240
                       defb 0, 120
                       defb 10, 120
                       defb 12, 120
                       defb 13, 120
                       defb 15, 240
                       defb 0, 120
                       defb 17, 120
                       defb 16, 120
                       defb 17, 120
                       defb 16, 120
                       defb 17, 120
                       defb 12, 120
                       defb 15, 120
                       defb 13, 120
                       defb 10, 360
                       defb 0, 120
                       defb 0, 0

                       align


                       mario defb 15, 120
                       defb 15, 120
                       defb 0, 60
                       defb 15, 120
                       defb 0, 120
                       defb 12, 120
                       defb 15, 240
                       defb 17, 240
                       defb 0, 120
                       defb 8, 240
                       defb 0, 120
                       defb 12, 240
                       defb 10, 240
                       defb 8, 240
                       defb 13, 240
                       defb 15, 240
                       defb 17, 240
                       defb 13, 120
                       defb 15, 120
                       defb 0, 120
                       defb 0, 0

                       align



start:                 la s0, FURELISE

tune_begin             lbu a0, 0[s0]
                       lbu a1, 1[s0]
                       beqz a1, tune_end
                       slli t0, a1, BUZZER_DURATION_SHIFT
                       or a0, a0, t0
                       li a7, ECALL_PLAY_SOUND
                       ecall

                       addi s0, s0, 2
                       j tune_begin

tune_end               j tune_end
