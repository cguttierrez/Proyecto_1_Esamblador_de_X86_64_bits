%include "linux64.inc"


section .data
    filename db "Ruta_datos.txt",0
    filename_settings db "Ruta_datos_configurados.txt",0
   
    


section .bss
    text resb 1024
    stack resb 1024
    text_changed resb 1024
    linebegin resb 1024

section .text
    global _start
    _start:
        call _readFile
        break1:
        print text
        call _processList
        break2:
        call _writeFile
        print linebegin
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
            mov rax, SYS_CLOSE
            pop rdi
            syscall
            breakclose:
            ret

_processList:
    mov rsi, text            ; Apunta a la memoria donde esta el texto leido
    mov r9, linebegin        ; Apunta r9 al inicio del buffer linebegin
    mov al,[rsi]
    mov  [r9], al
read_line:
    test al, al              ; and
    jz end_process           ; Si es 0 (fin del texto), salta al final

    ; Un salto de linea, procesa la siguiente linea
    cmp al, 10               ; Compara con salto de línea '\n'
    je next_line             ; Si es salto de línea, pasa al siguiente char
  
skip_char:
    inc rsi
    mov al,[rsi]
    jmp read_line            ; Sigue buscando el primer nombre

next_line:
    inc rsi
    mov al,[rsi]
    inc r9                   ; Avanza en el buffer para no sobrescribir
    mov  [r9], al            ; Guarda el carácter en linebegin
    jmp read_line

end_process:
    mov byte [r9], 0         ; Corrección 2: Añade null byte al final de linebegin
    ret                      ; Fin del procesamiento


_writeFile:
    ; Abre el archivo Ruta_datos_configurados.txt para escribir
    mov rax, SYS_OPEN
    mov rdi, filename_settings      ; Ruta del archivo de salida
    mov rsi, O_CREAT + O_WRONLY + O_TRUNC ; Corrección 4: Usa O_TRUNC para sobrescribir contenido
    mov rdx, 0644                   ; Corrección 4: Formato correcto de permisos
    syscall
    push rax         
    mov rdi, rax
    mov rax, SYS_WRITE   ; Syscall para escribir
    mov rsi, linebegin
    mov rdx, 1024
    syscall

    ;close the file
    mov rax, SYS_CLOSE
    pop rdi
    syscall
    ret
