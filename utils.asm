;---------------------------------------
; Copies strings from [rsi] to [rdi] 
;               until '\0' will be found
;---------------------------------------
copyString:
            cmp byte [rsi], 0
            je .exit
            movsb
            jmp copyString
.exit:
            ret

;---------------------------------------
; Converts base-10 int to base-CL string
; Entry: EAX - number to convert
;        ECX - radix
;        RDI - output string addr
; Destr: RAX, RDI, EDX, R8, R9, R10
;---------------------------------------
itoa:
            xor r9, r9                  ; r9 - strlen

            bsf edx, ecx 
            bsr r8d, ecx
            cmp edx, r8d                ; if ecx has only one non-0 bit
            jne .commonConvert
            
            push cx
            mov cx, r8w
.binaryConvert:
            inc r9

            mov edx, eax                 ; edx - reminder
            shr eax, cl                  ; cl - power
            shl eax, cl
            sub edx, eax
            shr eax, cl

            mov r10, [xlatTable + edx]
            mov [rdi], r10
            inc rdi

            cmp eax, 0
            jne .binaryConvert
            pop cx

            jmp .reverse

.commonConvert:
            inc r9

            xor edx, edx
            div ecx
            
            mov r8, [xlatTable + edx]
            mov [rdi], r8
            inc rdi

            cmp eax, 0
            jne .commonConvert

.reverse:
            push rdi
            sub rdi, r9                 ; start string addr
            call reverseString
            pop rdi

            ret

;---------------------------------------
; Reverses string
; Entry: RDI - string addr
;        R9 - strlen
; Destr: RDI, R8, R9, R10
;---------------------------------------
reverseString:
            mov r8, rdi                 ; rdi - left addr
            add r8, r9                  ; r8 - rigth addr
            dec r8

.swap:
            mov r9b, [rdi]
            mov r10b, [r8]
            mov [rdi], r10b
            mov [r8], r9b

            inc rdi
            dec r8

            cmp rdi, r8
            jl .swap

            ret

section .data

xlatTable:      db "0123456789ABCDEF"