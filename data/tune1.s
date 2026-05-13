; These doubles correspond to note pitch and duration                           
; Pitch is specified by notes of a major scale with "1" being the root -  
 "8" is therefore an octave above.  Pitch "0" is a rest	; pitch &FF is EOF.     
; Duration is nominally in tenths of seconds.                                   

tune1           DCB      8, 7
                DCB      0, 1
                DCB      8, 8
                DCB      9, 8
                DCB      7, 12
                DCB      8, 4
                DCB      9, 8

                DCB     10, 7
                DCB      0, 1
                DCB     10, 8
                DCB     11, 8
                DCB     10, 12
                DCB      9, 4
                DCB      8, 8

                DCB      9, 8
                DCB      8, 8
                DCB      7, 8
                DCB      8, 16

                DCB     &FF
