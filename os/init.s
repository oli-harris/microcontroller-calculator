; --------------------------------
;    OS Initialisation
;      Oliver Harris
;
;  Last Modified: 02/03/2026
;
;  Privilege: Machine
;  Requires: STACK_SIZE (words), start label
;
; ---------------------------------

; --- CONSTANTS ---
include os_constants.s

; --- USER CODE ---
         j start                  ; comment

; --- USER STACK ---
         ORG USER_BASE_ADDRESS

STACK    DEFS STACK_SIZE
STACK_END


