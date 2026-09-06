.MODEL SMALL
.STACK 100h

.DATA
    ; --- DOS buffered input structure (INT 21h, AH=0Ah) ---
    ; These three fields MUST stay declared in this exact order with no
    ; other variables between them. DOS treats them as one contiguous
    ; block: [max_len][act_len][buffer...]. max_len must be set before
    ; the call; DOS fills act_len and buffer after the user presses Enter.
    max_len     DB  20
    act_len     DB  0
    password    DB  20 DUP('$')
    ; --- end buffered input structure ---

    msg_title   DB  'Password Strength Checker', 0Dh, 0Ah
                DB  '-------------------------', 0Dh, 0Ah, '$'
    msg_prompt  DB  'Enter a password to test: $'

    msg_score   DB  0Dh, 0Ah, 'Score: $'
    msg_out_of  DB  '/5$', 0Dh, 0Ah

    msg_weak    DB  0Dh, 0Ah, 'Strength: WEAK (Very Unsafe) ', 0Dh, 0Ah, '$'
    msg_mod     DB  0Dh, 0Ah, 'Strength: MODERATE (Acceptable) ', 0Dh, 0Ah, '$'
    msg_strong  DB  0Dh, 0Ah, 'Strength: STRONG (Excellent!) ', 0Dh, 0Ah, '$'
    newline     DB  0Dh, 0Ah, '$'

    has_upper   DB  0
    has_lower   DB  0
    has_digit   DB  0
    has_special DB  0
    total_score DB  0

.CODE
MAIN PROC
    MOV  AX, @DATA
    MOV  DS, AX

    LEA  DX, msg_title
    MOV  AH, 09h
    INT  21h

    LEA  DX, msg_prompt
    MOV  AH, 09h
    INT  21h

    LEA  DX, max_len
    MOV  AH, 0Ah
    INT  21h

    MOV  CH, 0
    MOV  CL, act_len
    CMP  CL, 0
    JE   EVALUATE

    MOV  SI, 0

SCAN_LOOP:
    MOV  AL, password[SI]

CHECK_UPPER:
    CMP  AL, 'A'
    JB   CHECK_LOWER
    CMP  AL, 'Z'
    JA   CHECK_LOWER
    MOV  has_upper, 1
    JMP  NEXT_CHAR

CHECK_LOWER:
    CMP  AL, 'a'
    JB   CHECK_DIGIT
    CMP  AL, 'z'
    JA   CHECK_DIGIT
    MOV  has_lower, 1
    JMP  NEXT_CHAR

CHECK_DIGIT:
    CMP  AL, '0'
    JB   CHECK_SPECIAL
    CMP  AL, '9'
    JA   CHECK_SPECIAL
    MOV  has_digit, 1
    JMP  NEXT_CHAR

CHECK_SPECIAL:
    ; Anything printable that isn't a letter or digit counts as a
    ; special/symbol character (e.g. ! @ # $ % ^ & * etc).
    CMP  AL, 21h            ; '!' - first printable symbol
    JB   NEXT_CHAR
    CMP  AL, 7Eh            ; '~' - last printable symbol
    JA   NEXT_CHAR
    MOV  has_special, 1

NEXT_CHAR:
    INC  SI
    LOOP SCAN_LOOP

EVALUATE:
    MOV  AL, 0

    CMP  act_len, 8
    JB   ADD_UPPER
    INC  AL                     ; +1 point for length >= 8

ADD_UPPER:
    ADD  AL, has_upper
ADD_LOWER:
    ADD  AL, has_lower
ADD_DIGIT:
    ADD  AL, has_digit
ADD_SPECIAL:
    ADD  AL, has_special

    MOV  total_score, AL

    LEA  DX, msg_score
    MOV  AH, 09h
    INT  21h

    MOV  DL, total_score
    ADD  DL, '0'                ; safe since max score is 5 (single digit)
    MOV  AH, 02h
    INT  21h

    LEA  DX, msg_out_of
    MOV  AH, 09h
    INT  21h

    CMP  total_score, 2
    JBE  PRINT_WEAK              ; 0-2 points

    CMP  total_score, 3
    JE   PRINT_MOD                ; exactly 3 points

    LEA  DX, msg_strong           ; 4-5 points
    JMP  PRINT_MSG

PRINT_WEAK:
    LEA  DX, msg_weak
    JMP  PRINT_MSG

PRINT_MOD:
    LEA  DX, msg_mod

PRINT_MSG:
    MOV  AH, 09h
    INT  21h

    MOV  AH, 4Ch
    INT  21h
MAIN ENDP
END MAIN
