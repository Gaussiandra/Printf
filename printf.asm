%macro movFromStackTo 1
            add rbx, 8
            mov %1, [rbx]
%endmacro

%macro itoaAndContinue 1
            mov ecx, %1
            call itoa
            jmp parseFormatString
%endmacro

BUFFER_SIZE equ 128

section .text
    global _start

_start:
            cld

            push 'v'
            push 255
            push 15
            push 16
            push 88
            push 123
            push 22334455
            push argStr2
            push argStr1
            push 'c'
            push 'b'
            push 'a'
            push testInput
            call printf
            add esp, 13 * 8

            mov	rax, 60	                ; exit
            mov	rdi, 0                  ; with success
            syscall             

;---------------------------------------
; Printf with cdecl style 
;---------------------------------------
printf:
            mov rsi, [rsp + 8]          ; parsing string addr
            mov rdi, printfBuffer       ; buffer addr
            mov rbx, rsp
            add rbx, 8                  ; arguments stack offset

parseFormatString:
            cmp byte [rsi], 0
            je exit

            cmp byte [rsi], '%'
            jne commonSymbol
            inc rsi
            cmp byte [rsi], '%'
            je commonSymbol
            lodsb
            jmp specJmpTable[(rax - 'b') * 8]

commonSymbol:
            movsb
            jmp parseFormatString

exit:
            mov rsi, printfBuffer
            mov rax, 1                  ; write syscall
            mov rdx, rdi                
            sub rdx, printfBuffer       ; strlen
            mov rdi, 1                  ; output descriptor

            syscall

            ret

binSpec:
            movFromStackTo eax
            itoaAndContinue 2

charSpec:
            movFromStackTo eax
            stosb

            jmp parseFormatString


digitSpec:
            movFromStackTo eax
            itoaAndContinue 10
            
octalSpec:
            movFromStackTo eax
            itoaAndContinue 8

stringSpec:
            push rsi
            movFromStackTo rsi
            call copyString
            pop rsi
            
            jmp parseFormatString

hexSpec:
            movFromStackTo eax
            itoaAndContinue 16

%include 'utils.asm'

section .bss

printfBuffer:   resb BUFFER_SIZE

section .data

testInput:      db "Hello!1 %c%c %c aboba %s %s z %d %d %o-%o %b %x %%%c%k", 10, 0
argStr1:        db "amogus", 0
argStr2:        db "beef2", 0

specJmpTable:   dq binSpec              ; 0
                dq charSpec             ; 1
                dq digitSpec            ; 2
times 'o'-'d'-1 dq parseFormatString    ; 3 - 12
                dq octalSpec            ; 13
times 's'-'o'-1 dq parseFormatString    ; 14 - 16
                dq stringSpec           ; 17
times 'x'-'s'-1 dq parseFormatString    ; 18 - 21
                dq hexSpec              ; 22

xlatTable:      db "0123456789ABCDEF"
