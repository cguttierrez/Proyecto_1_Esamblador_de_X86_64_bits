%include "linux64.inc"

section .data
    filename db "Ruta_datos.txt", 0
    filename_settings db "Ruta_datos_configurados.txt", 0
    newline db 10   ; Carácter de nueva línea

section .bss
    text resb 1024
    stack resq 1000
    count_name resb 1
    text_changed resb 1024
    linebegin resb 1024

section .text
    global _start

_start:
    call _readFile
    call _processList
    call _writeFile
    print count_name

    mov rax, 60
    xor rdi, rdi
    syscall

_readFile: 
    mov rax, SYS_OPEN
    mov rdi, filename
    xor rsi, rsi
    xor rdx, rdx
    syscall
    test rax, rax
    js error_exit   ; Si no se pudo abrir el archivo, salir

    push rax
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, text
    mov rdx, 1023  ; Un byte menos para el null terminator
    syscall

    mov byte [text + rax], 0  ; Marca el fin del texto leído
    pop rdi
    mov rax, SYS_CLOSE
    syscall
    ret
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;contador de personas;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_contador:
    push rsi
    push rdi
    push rax
    push rcx

    lea rsi, [text]
    xor rdi, rdi
    xor rcx, rcx

count_loop:
    cmp byte [rsi], 0
    je count_end

    cmp byte [rsi], 10
    jne increase_count

    inc rcx
    lea rax, [rsi + 1]

    cmp rdi, 999
    jae count_end
    mov [stack + rdi*8], rax
    inc rdi

increase_count:
    inc rsi
    jmp count_loop

count_end:
    mov [count_name], rcx
    pop rcx
    pop rax
    pop rdi
    pop rsi
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;lector de iniciales de nombres;;;;;;;;;;;;;;;;;;
_processList:

read_first_char:
    cmp byte [text], 0;compara txt con cero
    je end_process  ; Si no hay datos en text, salir

    mov rsi, text  ;toma los datos de text y los almacena en el registro rsi
    mov r9, linebegin;apunta linebegin a r9

    mov al, [rsi]; toma el byte en rsi, el primer caracter
    mov [r9], al; toma el primer caracter y lo carga en r9->linebegin

read_line:
    test al, al
    jz end_process

    cmp al, 10
    je next_line

skip_char:
    inc rsi
    mov al, [rsi]
    jmp read_line

next_line:
    inc rsi
    mov al, [rsi]
    inc r9
    mov [r9], al
    jmp read_line

end_process:
    mov byte [r9], 0
    ret

_writeFile:
    mov rax, SYS_OPEN
    mov rdi, filename_settings
    mov rsi, O_CREAT + O_WRONLY + O_TRUNC
    mov rdx, 0644
    syscall
    test rax, rax
    js error_exit

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, linebegin
    movzx rdx, byte [count_name]  ; Longitud real
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall
    ret

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
