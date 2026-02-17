;------------------------------------------------
;                Tests for lcd
;                Oliver Harris
;
; Last modified: 17/02/26
;
;------------------------------------------------
         la sp, STACK_END

; --- TESTS ---

; write_clear_screen
; OUTPUT: Sam
; write_clear_screen    li a0, '\f'
;                       call write_char
;                       li a0, 'B'
;                       call write_char
;                       li a0, 'o'
;                       call write_char
;                       li a0, 'B'
;                       call write_char
;                       li a0, '\f'
;                       call write_char
;                       li a0, 'S'
;                       call write_char
;                       li a0, 'a'
;                       call write_char
;                       li a0, 'm'
;                       call write_char


; --- END TESTS ---

j .

; --- STACK ---

STACK    DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
