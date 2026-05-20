; --------------------------------------------------------------------
;                            Buzzer Driver
;                            Oliver Harris
;
; Implements a driver for the buzzer, which can be used to play
; a note for a given time in milliseconds.
;
; Hardware notes: buzzer supports 50 notes from the chromatic scale:
; with notes numbered from 1 (C4 246.63Hz) to 49 (C8 4186.01Hz),
; with 0 used to disable the buzzer.
;
; Last modified: 20/05/26
; --------------------------------------------------------------------

buzzer_remaining        defh 0                                ; 16-bit counter (up to 32767ms) for remaining time to play current note, -1 if no note is playing
                        align

; --- Buzzer Ecalls ---

; ecall_play_sound
; Purpose: Play a sound on the buzzer
; Input: a0
;        (0 to disable buzzer)
;        bits 0-5: note (1-50)
;        bits 6-15: padding
;        bits 16-31: duration in ms (required)


ecall_play_sound:

                        bnez a0, play_sound

stop_buzzer             la t0, buzzer_remaining
                        li t1, -1
                        sh t1, [t0]                           ; Set remaining time to -1 (stopped)
                        li t1, 0                              ; Disable buzzer, ignores note
                        j write_sound

play_sound              srli t1, a0, BUZZER_DURATION_SHIFT    ; Shift duration down
                        la t0, buzzer_remaining
                        sh t1, [t0]                           ; Store duration

                        andi t1, a0, BUZZER_NOTE_MASK         ; t1 = note
                        slli t1, t1, 1                        ; Set note (bits 1-6)
                        ori t1, t1, 1                         ; Set enable bit

write_sound             li t0, USER_PERIPHERAL_BASE
                        sb t1, OFFSET_BUZZER[t0]
                        ret


; buzzer_tick
; Purpose: To be called every millisecond to update buzzer state
; Decrements the remaining time for the current note, and disables the buzzer if time runs out
; Modifies: t0, t1
buzzer_tick:
                        la t0, buzzer_remaining
                        lh t1, [t0]                           ; Load remaining time
                        bgez t1, buzzer_tick_continue
                        j buzzer_tick_end                     ; functions should only have one return point

buzzer_tick_continue    subi t1, t1, 1                        ; remaining time -= 1 ms
                        sh t1, [t0]                           ; Store updated remaining time
                        bltz t1, buzzer_disable               ; If remaining time < 0, disable buzzer
                        j buzzer_tick_end

buzzer_disable          la t0, USER_PERIPHERAL_BASE           ; remaining time is -1
                        sb zero, OFFSET_BUZZER[t0]            ; Disable buzzer by writing 0 to it
                        j buzzer_tick_end

buzzer_tick_end         ret

