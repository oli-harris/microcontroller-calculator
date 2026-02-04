;-------------------------------------------------------------------------
;                        ASCII Constant Table
;                        Oliver Harris, Generative AI
;
; A table of 7-bit ASCII compiler constants
; Created using Generative AI by Claude Haiku 4.5
;
; Last modified: 04/01/26
;
; Prompt: Turn the following ASCII table into Risc-V bennett
;         constants, using the prefix ASCII_
;
;--------------------------------------------------------------------------

; Control characters 0x00-0x1F
ASCII_NUL            EQU 0x00
ASCII_SOH            EQU 0x01
ASCII_STX            EQU 0x02
ASCII_ETX            EQU 0x03
ASCII_EOT            EQU 0x04
ASCII_ENQ            EQU 0x05
ASCII_ACK            EQU 0x06
ASCII_BEL            EQU 0x07
ASCII_BS             EQU 0x08
ASCII_HT             EQU 0x09
ASCII_LF             EQU 0x0A
ASCII_VT             EQU 0x0B
ASCII_FF             EQU 0x0C
ASCII_CR             EQU 0x0D
ASCII_SO             EQU 0x0E
ASCII_SI             EQU 0x0F
ASCII_DLE            EQU 0x10
ASCII_DC1            EQU 0x11
ASCII_DC2            EQU 0x12
ASCII_DC3            EQU 0x13
ASCII_DC4            EQU 0x14
ASCII_NAK            EQU 0x15
ASCII_SYN            EQU 0x16
ASCII_ETB            EQU 0x17
ASCII_CAN            EQU 0x18
ASCII_EM             EQU 0x19
ASCII_SUB            EQU 0x1A
ASCII_ESC            EQU 0x1B
ASCII_FS             EQU 0x1C
ASCII_GS             EQU 0x1D
ASCII_RS             EQU 0x1E
ASCII_US             EQU 0x1F

; Printable characters 0x20-0x7E
ASCII_SP             EQU 0x20
ASCII_EXCLAMATION    EQU 0x21
ASCII_QUOTE          EQU 0x22
ASCII_HASH           EQU 0x23
ASCII_DOLLAR         EQU 0x24
ASCII_PERCENT        EQU 0x25
ASCII_AMPERSAND      EQU 0x26
ASCII_APOSTROPHE     EQU 0x27
ASCII_LPAREN         EQU 0x28
ASCII_RPAREN         EQU 0x29
ASCII_ASTERISK       EQU 0x2A
ASCII_PLUS           EQU 0x2B
ASCII_COMMA          EQU 0x2C
ASCII_MINUS          EQU 0x2D
ASCII_DOT            EQU 0x2E
ASCII_SLASH          EQU 0x2F
ASCII_DIGIT_0        EQU 0x30
ASCII_DIGIT_1        EQU 0x31
ASCII_DIGIT_2        EQU 0x32
ASCII_DIGIT_3        EQU 0x33
ASCII_DIGIT_4        EQU 0x34
ASCII_DIGIT_5        EQU 0x35
ASCII_DIGIT_6        EQU 0x36
ASCII_DIGIT_7        EQU 0x37
ASCII_DIGIT_8        EQU 0x38
ASCII_DIGIT_9        EQU 0x39
ASCII_COLON          EQU 0x3A
ASCII_SEMICOLON      EQU 0x3B
ASCII_LT             EQU 0x3C
ASCII_EQUAL          EQU 0x3D
ASCII_GT             EQU 0x3E
ASCII_QUESTION       EQU 0x3F
ASCII_AT             EQU 0x40
ASCII_A_UPPER        EQU 0x41
ASCII_B_UPPER        EQU 0x42
ASCII_C_UPPER        EQU 0x43
ASCII_D_UPPER        EQU 0x44
ASCII_E_UPPER        EQU 0x45
ASCII_F_UPPER        EQU 0x46
ASCII_G_UPPER        EQU 0x47
ASCII_H_UPPER        EQU 0x48
ASCII_I_UPPER        EQU 0x49
ASCII_J_UPPER        EQU 0x4A
ASCII_K_UPPER        EQU 0x4B
ASCII_L_UPPER        EQU 0x4C
ASCII_M_UPPER        EQU 0x4D
ASCII_N_UPPER        EQU 0x4E
ASCII_O_UPPER        EQU 0x4F
ASCII_P_UPPER        EQU 0x50
ASCII_Q_UPPER        EQU 0x51
ASCII_R_UPPER        EQU 0x52
ASCII_S_UPPER        EQU 0x53
ASCII_T_UPPER        EQU 0x54
ASCII_U_UPPER        EQU 0x55
ASCII_V_UPPER        EQU 0x56
ASCII_W_UPPER        EQU 0x57
ASCII_X_UPPER        EQU 0x58
ASCII_Y_UPPER        EQU 0x59
ASCII_Z_UPPER        EQU 0x5A
ASCII_LBRACKET       EQU 0x5B
ASCII_BACKSLASH      EQU 0x5C
ASCII_RBRACKET       EQU 0x5D
ASCII_CARET          EQU 0x5E
ASCII_UNDERSCORE     EQU 0x5F
ASCII_BACKTICK       EQU 0x60
ASCII_A_LOWER        EQU 0x61
ASCII_B_LOWER        EQU 0x62
ASCII_C_LOWER        EQU 0x63
ASCII_D_LOWER        EQU 0x64
ASCII_E_LOWER        EQU 0x65
ASCII_F_LOWER        EQU 0x66
ASCII_G_LOWER        EQU 0x67
ASCII_H_LOWER        EQU 0x68
ASCII_I_LOWER        EQU 0x69
ASCII_J_LOWER        EQU 0x6A
ASCII_K_LOWER        EQU 0x6B
ASCII_L_LOWER        EQU 0x6C
ASCII_M_LOWER        EQU 0x6D
ASCII_N_LOWER        EQU 0x6E
ASCII_O_LOWER        EQU 0x6F
ASCII_P_LOWER        EQU 0x70
ASCII_Q_LOWER        EQU 0x71
ASCII_R_LOWER        EQU 0x72
ASCII_S_LOWER        EQU 0x73
ASCII_T_LOWER        EQU 0x74
ASCII_U_LOWER        EQU 0x75
ASCII_V_LOWER        EQU 0x76
ASCII_W_LOWER        EQU 0x77
ASCII_X_LOWER        EQU 0x78
ASCII_Y_LOWER        EQU 0x79
ASCII_Z_LOWER        EQU 0x7A
ASCII_LBRACE         EQU 0x7B
ASCII_PIPE           EQU 0x7C
ASCII_RBRACE         EQU 0x7D
ASCII_TILDE          EQU 0x7E

; Delete / Rubout
ASCII_DEL            EQU 0x7F
ASCII_RUBOUT         EQU 0x7F
