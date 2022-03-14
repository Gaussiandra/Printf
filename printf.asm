%macro movFromStackTo 1
            add rbp, 8
            mov %1, [rbp]
%endmacro

%macro itoaAndContinue 1
            mov ecx, %1
            call itoa
            jmp parseFormatString
%endmacro

WRITE_SYSCALL equ 1
OUTPUT_DESC   equ 1
BUFFER_SIZE   equ 128

section .text
    global myPrintf

myPrintf:
            cld

            pop rax                     ; ret addr
            
            ; push first six args
            push r9
            push r8
            push rcx
            push rdx
            push rsi
            push rdi

            ; push callee-used registers
            push rsp
            push rbp
            push rbx
            push r12
            push r13
            push r14
            push r15
            
            mov r15, rax
            mov rbp, rsp
            add rbp, 7 * 8              ; points to args
            call printf

            ; pop callee-used registers
            mov rax, r15
            pop r15
            pop r14
            pop r13
            pop r12
            pop rbx
            pop rbp
            pop rsp

            ; pop callee-used registers
            pop rdi
            pop rsi
            pop rdx
            pop rcx
            pop r8
            pop r9

            push rax
            ret         

printf:
            mov rsi, [rbp]              ; parsing string addr
            mov rdi, printfBuffer       ; buffer addr

parseFormatString:
            xor rax, rax

            cmp byte [rsi], 0
            je exit

            cmp byte [rsi], '%'
            jne commonSymbol
            inc rsi
            cmp byte [rsi], '%'         ; %% case
            je commonSymbol
            lodsb
            jmp specJmpTable[(rax - 'b') * 8]

commonSymbol:
            movsb
            jmp parseFormatString

exit:
            mov rsi, printfBuffer
            mov rax, WRITE_SYSCALL      ; write syscall
            mov rdx, rdi                
            sub rdx, printfBuffer       ; strlen
            mov rdi, OUTPUT_DESC        ; output descriptor

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

specJmpTable:   dq binSpec              ; 0
                dq charSpec             ; 1
                dq digitSpec            ; 2
times 'o'-'d'-1 dq parseFormatString    ; 3 - 12
                dq octalSpec            ; 13
times 's'-'o'-1 dq parseFormatString    ; 14 - 16
                dq stringSpec           ; 17
times 'x'-'s'-1 dq parseFormatString    ; 18 - 21
                dq hexSpec              ; 22