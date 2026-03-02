;-------------------------------------------
;                 Exercise 4
;  Prints 'Hello World' using system calls
;               Oliver Harris
;
;  Last modified: 02/03/2026
;
; ------------------------------------------

; --- CONSTANTS ---
STACK_SIZE    EQU 256 * 4 ; reserve 256 words

; --- OS ---
include os/init.s

; --- APPLICATION ---
start    j start

; --- LIBRARIES ---


