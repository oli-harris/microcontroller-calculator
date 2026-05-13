; --------------------------------------------------------
;                      Buzzer Driver
;                      Oliver Harris
;
; Implements a driver for the buzzer,
; which can be used to play a sound of a given note.
;
; Last modified: 11/05/26
; --------------------------------------------------------`


; --- Buzzer Ecalls ---

; ecall_play_sound
; Purpose: Play a sound on the buzzer
; Input: a0 = note (1-50), or 0 to stop
ecall_play_sound:
               li t0, USER_PERIPHERAL_BASE
               bnez a0, play_sound

stop_buzzer    li t1, 0                       ; Sets disable bit and ignores note
               j write_sound

play_sound     slli t1, a0, 1                 ; Set note (bits 1-6)
               ori t1, t1, 1                  ; Set enable bit

write_sound    sb t1, OFFSET_BUZZER[t0]
               ret
