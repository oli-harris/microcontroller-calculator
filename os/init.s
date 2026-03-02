; --------------------------------------------
;              OS Initialisation
;                Oliver Harris
;
;  Last Modified: 02/03/2026
;
;  Privilege: Machine
;  Requires: STACK_SIZE (bytes), start label
;
; --------------------------------------------

; --- CONSTANTS ---
include os_constants.s


; --- INITIALISATION ---



; --- HANDLE TRAPs ---



; --- USER CODE ---
          j start                  ; comment


; --- MACHINE STACK
MSTACK    DEFS MSTACK_SIZE
MSTACK_END


; --- USER STACK ---
          ORG USER_BASE_ADDRESS

STACK     DEFS STACK_SIZE
STACK_END


