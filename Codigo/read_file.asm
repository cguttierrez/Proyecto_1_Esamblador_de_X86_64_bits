%include "linux64.inc"
section .data
    filename db "Ruta_datos.txt",0
section .bss
    text resb 1024
section .text
    global _start
_start:
;Open the file
    mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall
;read from the file
    push rax
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, text
    mov rdx, 1024
    syscall
;close the file
    mov rax, SYS_CLOSE
    pop rdi
    syscall

    print text
    exit
