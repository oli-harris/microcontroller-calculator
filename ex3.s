;------------------------------------------------
;                Exercise 3
;                Oliver Harris
;
; Prints ascii characters and commands
;
; Last modified: 16/02/26
;
; Known issues:
;
;------------------------------------------------

start    la sp, STACK_END

         li a0, 1
         call write_cmd
         li a0, 'H'
         call write_char
         li a0, 'e'
         call write_char
         li a0, 'l'
         call write_char
         li a0, 'l'
         call write_char
         li a0, 'o'
         call write_char
         li a0, ' '
         call write_char
         li a0, 'B'
         call write_char
         li a0, 'e'
         call write_char
         li a0, 'e'
         call write_char
         li a0, '!'
         call write_char

end       j .


; --- STACK ---

STACK    DEFS 128
STACK_END

; --- INCLUDES ---
include lcd.s
