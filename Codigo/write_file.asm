%include "linux64.inc"

section .data

filename db "myfile_CREATED.txt",0
text db "Here is some text.",10

section .text
global _start

_start:
; Open the file
    mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall
;write to the file
    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, text
    mov rdx, 18
    syscall
;close the file
    mov rax, SYS_CLOSE
    pop rdi
    syscall

    print text
    exit
