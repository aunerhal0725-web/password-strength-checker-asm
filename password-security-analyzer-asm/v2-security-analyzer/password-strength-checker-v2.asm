.MODEL SMALL
.STACK 100h

.DATA

    max_len     DB  20
    act_len     DB  0
    password    DB  21 DUP('$')

    msg_title   DB  0Dh, 0Ah
                DB  'Password Security Analyzer', 0Dh, 0Ah
                DB  '===========================', 0Dh, 0Ah, '$'

    msg_prompt  DB  'Enter a password to test: $'

    msg_length  DB  0Dh, 0Ah
                DB  'Length: $'

    msg_base    DB  0Dh, 0Ah
                DB  'Base Score: $'

    msg_out_of  DB  '/7', 0Dh, 0Ah, '$'


    msg_analysis DB 0Dh, 0Ah
                 DB 'Character Analysis:', 0Dh, 0Ah, '$'

    msg_lower   DB  '  Lowercase : $'
    msg_upper   DB '  Uppercase : $'
    msg_digit   DB '  Digit     : $'
    msg_special DB '  Special   : $'


    msg_security DB  0Dh, 0Ah
                 DB 'Security Checks:', 0Dh, 0Ah, '$'

    msg_repeat   DB '  Repeated pattern  : $'
    msg_sequence DB '  Sequential pattern: $'
    msg_common   DB '  Common password    : $'


    msg_entropy DB 0Dh, 0Ah
                DB 'Estimated Entropy: $'

    msg_bits    DB ' bits', 0Dh, 0Ah, '$'


    msg_yes     DB 'YES', 0Dh, 0Ah, '$'
    msg_no      DB 'NO', 0Dh, 0Ah, '$'

    msg_very_weak DB 0Dh, 0Ah
                  DB 'Strength: VERY WEAK (Very Unsafe)', 0Dh, 0Ah, '$'

    msg_weak    DB 0Dh, 0Ah
                DB 'Strength: WEAK (Unsafe)', 0Dh, 0Ah, '$'

    msg_mod     DB 0Dh, 0Ah
                DB 'Strength: MODERATE (Acceptable)', 0Dh, 0Ah, '$'

    msg_strong  DB 0Dh, 0Ah
                DB 'Strength: STRONG (Excellent!)', 0Dh, 0Ah, '$'


    ; Flags stored in one byte.
    LOWER_BIT       EQU 01h
    UPPER_BIT       EQU 02h
    DIGIT_BIT       EQU 04h
    SPECIAL_BIT     EQU 08h
    REPEAT_BIT      EQU 10h
    SEQ_BIT         EQU 20h
    COMMON_BIT      EQU 40h

    VARIETY_BITS    EQU 0Fh
    PATTERN_BITS    EQU 30h


    flags           DB  0
    base_score      DB  0
    final_tier      DB  0
    entropy         DW  0


    ; Small list for demonstration.
    common1 DB 'password', 0
    common2 DB '123456', 0
    common3 DB '12345678', 0
    common4 DB 'qwerty', 0
    common5 DB 'admin', 0
    common6 DB 'welcome', 0
    common7 DB 'letmein', 0
    common8 DB 'password123', 0

    common_table DW OFFSET common1
                 DW OFFSET common2
                 DW OFFSET common3
                 DW OFFSET common4
                 DW OFFSET common5
                 DW OFFSET common6
                 DW OFFSET common7
                 DW OFFSET common8


    ; log2(character-set size) * 10
    entropy_table DW 0
                   DW 47
                   DW 47
                   DW 57
                   DW 33
                   DW 52
                   DW 52
                   DW 60
                   DW 50
                   DW 59
                   DW 59
                   DW 65
                   DW 54
                   DW 61
                   DW 61
                   DW 66


.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX

    ; CMPSB uses ES:DI.
    PUSH DS
    POP ES

    LEA DX, msg_title
    MOV AH, 09h
    INT 21h

    LEA DX, msg_prompt
    MOV AH, 09h
    INT 21h

    ; Read password using DOS buffered input.
    LEA DX, max_len
    MOV AH, 0Ah
    INT 21h

    MOV flags, 0
    MOV base_score, 0
    MOV final_tier, 0
    MOV entropy, 0

    CMP act_len, 0
    JE CALCULATE_BASE

    MOV CH, 0
    MOV CL, act_len
    MOV SI, 0


CLASSIFY_LOOP:

    MOV AL, password[SI]

    CMP AL, 'A'
    JB CHECK_LOWER

    CMP AL, 'Z'
    JA CHECK_LOWER

    OR flags, UPPER_BIT
    JMP CLASSIFY_NEXT


CHECK_LOWER:

    CMP AL, 'a'
    JB CHECK_DIGIT

    CMP AL, 'z'
    JA CHECK_DIGIT

    OR flags, LOWER_BIT
    JMP CLASSIFY_NEXT


CHECK_DIGIT:

    CMP AL, '0'
    JB CHECK_SPECIAL

    CMP AL, '9'
    JA CHECK_SPECIAL

    OR flags, DIGIT_BIT
    JMP CLASSIFY_NEXT


CHECK_SPECIAL:

    CMP AL, 21h
    JB CLASSIFY_NEXT

    CMP AL, 7Eh
    JA CLASSIFY_NEXT

    OR flags, SPECIAL_BIT


CLASSIFY_NEXT:

    INC SI
    LOOP CLASSIFY_LOOP

    CALL CHECK_REPEATED
    CALL CHECK_SEQUENTIAL
    CALL CHECK_COMMON_PASSWORD

    CALL CALCULATE_ENTROPY


CALCULATE_BASE:

    MOV AL, 0

    ; Length contributes up to 3 points.
    CMP act_len, 8
    JB CHECK_LENGTH_12

    INC AL


CHECK_LENGTH_12:

    CMP act_len, 12
    JB CHECK_LENGTH_16

    INC AL


CHECK_LENGTH_16:

    CMP act_len, 16
    JB CHECK_CHARACTER_VARIETY

    INC AL


CHECK_CHARACTER_VARIETY:

    TEST flags, LOWER_BIT
    JZ NO_LOWER

    INC AL


NO_LOWER:

    TEST flags, UPPER_BIT
    JZ NO_UPPER

    INC AL


NO_UPPER:

    TEST flags, DIGIT_BIT
    JZ NO_DIGIT

    INC AL


NO_DIGIT:

    TEST flags, SPECIAL_BIT
    JZ NO_SPECIAL

    INC AL


NO_SPECIAL:

    MOV base_score, AL

    CMP AL, 2
    JBE BASE_VERY_WEAK

    CMP AL, 4
    JBE BASE_WEAK

    CMP AL, 6
    JBE BASE_MODERATE

    MOV final_tier, 3
    JMP APPLY_OVERRIDES


BASE_VERY_WEAK:

    MOV final_tier, 0
    JMP APPLY_OVERRIDES


BASE_WEAK:

    MOV final_tier, 1
    JMP APPLY_OVERRIDES


BASE_MODERATE:

    MOV final_tier, 2


; Common passwords override everything else.
APPLY_OVERRIDES:

    TEST flags, COMMON_BIT
    JZ CHECK_PATTERN_OVERRIDE

    MOV final_tier, 1
    JMP PRINT_RESULTS


; Patterns reduce the strength by one tier.
CHECK_PATTERN_OVERRIDE:

    TEST flags, PATTERN_BITS
    JZ PRINT_RESULTS

    CMP final_tier, 0
    JE PRINT_RESULTS

    DEC final_tier


PRINT_RESULTS:

    LEA DX, msg_length
    MOV AH, 09h
    INT 21h

    MOV AL, act_len
    XOR AH, AH
    CALL PRINT_DECIMAL


    LEA DX, msg_analysis
    MOV AH, 09h
    INT 21h


    LEA DX, msg_lower
    MOV AH, 09h
    INT 21h

    TEST flags, LOWER_BIT
    JZ PRINT_LOWER_NO

    LEA DX, msg_yes
    JMP PRINT_LOWER_RESULT

PRINT_LOWER_NO:

    LEA DX, msg_no

PRINT_LOWER_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_upper
    MOV AH, 09h
    INT 21h

    TEST flags, UPPER_BIT
    JZ PRINT_UPPER_NO

    LEA DX, msg_yes
    JMP PRINT_UPPER_RESULT

PRINT_UPPER_NO:

    LEA DX, msg_no

PRINT_UPPER_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_digit
    MOV AH, 09h
    INT 21h

    TEST flags, DIGIT_BIT
    JZ PRINT_DIGIT_NO

    LEA DX, msg_yes
    JMP PRINT_DIGIT_RESULT

PRINT_DIGIT_NO:

    LEA DX, msg_no

PRINT_DIGIT_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_special
    MOV AH, 09h
    INT 21h

    TEST flags, SPECIAL_BIT
    JZ PRINT_SPECIAL_NO

    LEA DX, msg_yes
    JMP PRINT_SPECIAL_RESULT

PRINT_SPECIAL_NO:

    LEA DX, msg_no

PRINT_SPECIAL_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_security
    MOV AH, 09h
    INT 21h


    LEA DX, msg_repeat
    MOV AH, 09h
    INT 21h

    TEST flags, REPEAT_BIT
    JZ PRINT_REPEAT_NO

    LEA DX, msg_yes
    JMP PRINT_REPEAT_RESULT

PRINT_REPEAT_NO:

    LEA DX, msg_no

PRINT_REPEAT_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_sequence
    MOV AH, 09h
    INT 21h

    TEST flags, SEQ_BIT
    JZ PRINT_SEQ_NO

    LEA DX, msg_yes
    JMP PRINT_SEQ_RESULT

PRINT_SEQ_NO:

    LEA DX, msg_no

PRINT_SEQ_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_common
    MOV AH, 09h
    INT 21h

    TEST flags, COMMON_BIT
    JZ PRINT_COMMON_NO

    LEA DX, msg_yes
    JMP PRINT_COMMON_RESULT

PRINT_COMMON_NO:

    LEA DX, msg_no

PRINT_COMMON_RESULT:

    MOV AH, 09h
    INT 21h


    LEA DX, msg_entropy
    MOV AH, 09h
    INT 21h

    MOV AX, entropy
    CALL PRINT_DECIMAL

    LEA DX, msg_bits
    MOV AH, 09h
    INT 21h


    LEA DX, msg_base
    MOV AH, 09h
    INT 21h

    MOV AL, base_score
    XOR AH, AH
    CALL PRINT_DECIMAL

    LEA DX, msg_out_of
    MOV AH, 09h
    INT 21h


    CMP final_tier, 0
    JE PRINT_VERY_WEAK

    CMP final_tier, 1
    JE PRINT_WEAK

    CMP final_tier, 2
    JE PRINT_MODERATE

    JMP PRINT_STRONG


PRINT_VERY_WEAK:

    LEA DX, msg_very_weak
    JMP PRINT_FINAL


PRINT_WEAK:

    LEA DX, msg_weak
    JMP PRINT_FINAL


PRINT_MODERATE:

    LEA DX, msg_mod
    JMP PRINT_FINAL


PRINT_STRONG:

    LEA DX, msg_strong


PRINT_FINAL:

    MOV AH, 09h
    INT 21h

    MOV AH, 4Ch
    INT 21h

MAIN ENDP



; Detect 3 or more consecutive identical characters.
CHECK_REPEATED PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP act_len, 3
    JB REPEAT_DONE

    MOV SI, 0
    MOV AL, password[SI]
    MOV BL, 1

    INC SI

    MOV CH, 0
    MOV CL, act_len
    DEC CX


REPEAT_LOOP:

    MOV DL, password[SI]

    CMP DL, AL
    JNE NEW_REPEAT_SEQUENCE

    INC BL

    CMP BL, 3
    JB CONTINUE_REPEAT

    OR flags, REPEAT_BIT
    JMP REPEAT_DONE


NEW_REPEAT_SEQUENCE:

    MOV AL, DL
    MOV BL, 1


CONTINUE_REPEAT:

    INC SI
    LOOP REPEAT_LOOP


REPEAT_DONE:

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

CHECK_REPEATED ENDP



; Detect ascending or descending sequences of 3+ characters.
CHECK_SEQUENTIAL PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP act_len, 3
    JB SEQ_DONE

    MOV SI, 0


SEQ_LOOP:

    MOV AL, password[SI]
    MOV BL, password[SI+1]
    MOV DL, password[SI+2]

    ; Ascending sequence.
    MOV AH, BL
    SUB AH, AL

    CMP AH, 1
    JNE CHECK_DESCENDING

    MOV AH, DL
    SUB AH, BL

    CMP AH, 1
    JE SEQ_FOUND


CHECK_DESCENDING:

    ; Descending sequence.
    MOV AH, AL
    SUB AH, BL

    CMP AH, 1
    JNE SEQ_NEXT

    MOV AH, BL
    SUB AH, DL

    CMP AH, 1
    JE SEQ_FOUND


SEQ_NEXT:

    INC SI

    MOV AL, act_len
    XOR AH, AH

    SUB AX, 2

    CMP SI, AX
    JB SEQ_LOOP


SEQ_DONE:

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET


SEQ_FOUND:

    OR flags, SEQ_BIT

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

CHECK_SEQUENTIAL ENDP



; Compare the password with the common-password list.
CHECK_COMMON_PASSWORD PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP act_len, 0
    JE COMMON_DONE

    LEA SI, common_table
    MOV CX, 8


COMMON_TABLE_LOOP:

    MOV BX, [SI]

    PUSH CX
    PUSH SI

    CALL COMPARE_COMMON

    POP SI
    POP CX

    JC COMMON_FOUND

    ADD SI, 2

    LOOP COMMON_TABLE_LOOP

    JMP COMMON_DONE


COMMON_FOUND:

    OR flags, COMMON_BIT


COMMON_DONE:

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

CHECK_COMMON_PASSWORD ENDP



; BX points to a null-terminated common password.
; CF = 1 if it matches, otherwise CF = 0.
COMPARE_COMMON PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV DI, BX
    XOR CX, CX


COMMON_LENGTH_LOOP:

    CMP BYTE PTR [DI], 0
    JE COMMON_LENGTH_DONE

    INC CX
    INC DI

    JMP COMMON_LENGTH_LOOP


COMMON_LENGTH_DONE:

    MOV AL, act_len
    XOR AH, AH

    CMP AX, CX
    JNE COMMON_NO_MATCH

    LEA SI, password
    MOV DI, BX

    CLD
    REPE CMPSB

    JNE COMMON_NO_MATCH


COMMON_MATCH:

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    STC
    RET


COMMON_NO_MATCH:

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    CLC
    RET

COMPARE_COMMON ENDP



; Entropy = password length * log2(character-set size).
CALCULATE_ENTROPY PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP act_len, 0
    JE ENTROPY_ZERO

    MOV AL, flags
    AND AL, VARIETY_BITS
    XOR AH, AH

    SHL AX, 1
    MOV SI, AX

    MOV BX, entropy_table[SI]

    MOV AL, act_len
    XOR AH, AH

    MUL BX

    MOV BX, 10
    DIV BX

    MOV entropy, AX

    JMP ENTROPY_DONE


ENTROPY_ZERO:

    MOV entropy, 0


ENTROPY_DONE:

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

CALCULATE_ENTROPY ENDP



; Print the unsigned value in AX.
PRINT_DECIMAL PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE DECIMAL_NOT_ZERO

    MOV DL, '0'
    MOV AH, 02h
    INT 21h

    JMP DECIMAL_DONE


DECIMAL_NOT_ZERO:

    XOR CX, CX
    MOV BX, 10


DECIMAL_DIVIDE:

    XOR DX, DX
    DIV BX

    PUSH DX
    INC CX

    CMP AX, 0
    JNE DECIMAL_DIVIDE


DECIMAL_PRINT:

    POP DX

    ADD DL, '0'

    MOV AH, 02h
    INT 21h

    LOOP DECIMAL_PRINT


DECIMAL_DONE:

    POP DX
    POP CX
    POP BX
    POP AX

    RET

PRINT_DECIMAL ENDP


END MAIN