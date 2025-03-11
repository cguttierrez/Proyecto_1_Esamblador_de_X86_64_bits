%include "linux64.inc"


section .data
    filename db "Ruta_datos.txt",0
    filename_settings db "Ruta_datos_configurados.txt",0
    newLine db 10


section .bss
    text resb 1024
    stack resb 1024
    text_changed resb 1024


section .text
    global _start
    _start:
        call _readFile
        break1:
        print text
        call _processList
        break2:
        print stack
        call _writeFile
        break3:
        exit
        ;Clear memory
        mov rax, 60
        mov rdi, 0
        syscall

    _readFile: 
        ;Open the file
            mov rax, SYS_OPEN
            mov rdi, filename
            mov rsi, O_RDONLY
            mov rdx, 0
            syscall
            breakreadonly:
        ;read from the file
            push rax
            mov rdi, rax
            mov rax, SYS_READ
            mov rsi, text
            mov rdx, 1024
            syscall
            breaktext:
        ;close the file
            mov rbx, rax
            mov rax, SYS_CLOSE
            pop rdi
            syscall
            breakclose:
            ret

    _processList:
            mov rsi, text
            mov al, [rsi]
        
           
        loop:
            cmp al,10
            je end

            mov rax,1
            mov rdi,1
            mov rdx,1
            syscall

            jne next_char       

        next_char:
            inc rsi
            mov al,[rsi]

            test al,al
            jz end

            jmp loop
            

        end:
            ret

     _writeFile:
        ; Open the file
            mov rax, SYS_OPEN
            mov rdi, filename_settings
            mov rsi, O_CREAT+O_WRONLY
            mov rdx, 0644o
            syscall
        ;write to the file
            push rax
            mov rdi, rax
            mov rax, SYS_WRITE
            mov rsi, stack
            mov rdx, 40
            syscall
        ;close the file
            mov rax, SYS_CLOSE
            pop rdi
            syscall
            ret
