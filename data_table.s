;----------------------------
; Table of Country, Capitals
;       Oliver Harris
;----------------------------

TABLE_CAPITALS_SIZE    EQU 3

table_country1         defb "\fUnited Kingdom\n\0"
table_capital1         defb "London\0"
table_country2         defb "\fFrance\n\0"
table_capital2         defb "Paris\0"
table_country3         defb "\fSpain\n\0"
table_capital3         defb "Madrid\0"
                       align

table_capitals         defw table_country1, table_capital1
                       defw table_country2, table_capital2
                       defw table_country3, table_capital3
