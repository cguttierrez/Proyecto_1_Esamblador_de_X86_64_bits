%macro print_salto 0
    mov rax, 1         ; Llamada al sistema write
    mov rdi, 1         ; Descriptor de archivo: salida 
    mov rsi, salto_linea ; Dirección
    mov rdx, 1         ; Longitud: 1 byte
    syscall            
%endmacro


%macro print_totalnombres 0
    mov rax, 1          ; Llamada al sistema write
    mov rdi, 1          ; Descriptor de archivo: salida 
    mov rsi, total_nombres     ; Dirección 
    mov rdx, 2        ; Longitud: 1 byte
    syscall            
%endmacro


%macro print_espacio 0
    mov rax, 1          ; Llamada al sistema write
    mov rdi, 1          ; Descriptor de archivo: salida 
    mov rsi, espacio     ; Dirección 
    mov rdx, 1          ; Longitud: 1 byte
    syscall            
%endmacro

%macro print_espacios 0
    mov rax, 1          ; Llamada al sistema write
    mov rdi, 1          ; Descriptor de archivo: salida 
    mov rsi, espacios     ; Dirección 
    mov rdx, 4          ; Longitud: 3 byte
    syscall           
%endmacro


%macro print_titulo_nota 0
    mov rax, 1                  ; Llamada al sistema write
    mov rdi, 1                  ; Descriptor de archivo: salida estándar
    mov rsi, titulo_nota_sort   ; Dirección del título "Ordenamiento por nota"
    mov rdx, 47   ; Longitud del título
    syscall                     ; Ejecutar llamada al sistema
%endmacro

%macro print_titulo_alfabetico 0
    mov rax, 1                  ; Llamada al sistema write
    mov rdi, 1                  ; Descriptor de archivo: salida estándar
    mov rsi, titulo_alfabetico_sort ; Dirección del título "Ordenamiento por orden alfabético"
    mov rdx, 55 ; Longitud del título
    syscall                     ; Ejecutar llamada al sistema
%endmacro

%macro set_color 1
    mov rax, 1        ; syscall: sys_write
    mov rdi, 1        ; file descriptor: stdout
    mov rsi, color_%1 ; Dirección del código ANSI del color
    mov rdx, color_%1_len ; Longitud del código ANSI
    syscall
%endmacro




%macro print_titulo_histograma 0
    mov rax, 1                  ; Llamada al sistema write
    mov rdi, 1                  ; Descriptor de archivo: salida estándar
    mov rsi, titulo_histograma ; Dirección del título "Ordenamiento por orden alfabético"
    mov rdx, 10 ; Longitud del título
    syscall                     ; Ejecutar llamada al sistema
%endmacro
