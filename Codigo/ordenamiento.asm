;====================================================================================
;====================================================================================
section .bss
    buffer resb 8192           ; Buffer para  el archivo 
    buffer_bin resb 100
    nombres resq 1024          ; punteros 
    almacenamiento resb 8192    ; para guardar los nombres
    fd resq 1               ; Descriptor de archivo
    total_nombres resq 1      ; contador de nombres
    frec_count resq 10          ; cada elemento es un DWORD para contar estudiantes
    num_buffer resb 16         ; Buffer para convertir números a cadena
;====================================================================================
;====================================================================================
section .data
    filename db "Ruta_datos.txt", 0   ; Archivo de datos
    msg_error db "Error al abrir archivo", 10, 0
    salto_linea db 10, 0 
    ;label_eje db " 10  20  30  40  50  60  70  80  90 100", 10, 0
    espacios db "   "         ; Tres espacios para separar la etiqueta de las columnas
    espacio db " ",0
    histo_char_x db 'X'
    separador db "  ", 0
    label_ejex db "	10  20  30  40  50  60  70  80  90 100",10,0
    label_ejey db "100",10," 95",10," 90",10," 85",10," 80",10," 75",10," 70",10
           db " 65",10," 60",10," 55",10," 50",10," 45",10," 40",10," 35",10
           db " 30",10," 25",10," 20",10," 15",10," 10",10,"  5",10,0
;====================================================================================
;====================================================================================    
section .text
    global _start

_start:
    call _almacenamiento

    call contar_intervalos_notas
    
    call imprimir_frec_count

    call bubble_sort_alfabetico
    
    call imprimir_nombres
    
    call bubble_sort_numerico

    call imprimir_nombres
    
    jmp terminar

terminar:
    mov rax, 60
    mov rdi, 0
    syscall

error:
    mov rdi, msg_error
    jmp terminar
;====================================================================================
;====================================================================================
;==================================================================================
; Lee Ruta_datos.txt y almacena cada línea en el array nombres

_almacenamiento:
    ; Abrir el archivo
    mov rdi, filename
    mov rsi, 0         ; O_RDONLY
    mov rax, 2          ; syscall: open
    syscall
    cmp rax, 0
    jl error
    mov [fd], rax

    ; Lee el archivo en buffer
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 8192
    mov rax, 0       ; syscall: read
    syscall
    cmp rax, 0
    jle fin_lectura

    ; Inicializar punteros 
    
    mov rdi, buffer        ; Puntero a buffer leído
    mov rsi, almacenamiento ; donde se guardan las líneas
    xor rdx, rdx           ; Contador de nombres = 0
    mov rbx, rsi           ; rbx apunta al inicio del primer nombre

leer_nombres:
    cmp byte [rdi], 0          ; si es el fin del archivo
    je fin_lectura
    cmp byte [rdi], 10         ; Si hay salto de línea
    je guardar_nombre
    
    ; Copia la letra actual
    mov al, [rdi]
    mov [rsi], al
    inc rsi
    inc rdi
    
    cmp rsi, almacenamiento + 8192
    jge fin_lectura
    jmp leer_nombres

guardar_nombre:
    cmp rsi, rbx
    je ignorar_nombre
    mov byte [rsi], 0          ; termina la cadena con 0
    mov rax, rbx
    mov [nombres + rdx*8], rax ; guarda la dirección del nombre
    inc rdx
    cmp rdx, 1024
    jge fin_lectura
    inc rsi                  ; pasar el salto de línea
    inc rdi
    mov rbx, rsi
    jmp leer_nombres

ignorar_nombre:
    inc rsi
    inc rdi
    mov rbx, rsi
    jmp leer_nombres

fin_lectura:
    mov [total_nombres], rdx
    
    ;puntero nulo extra para delimitar el arreglo
    
    mov qword [nombres + rdx*8], 0
    mov rdi, [fd]
    mov rax, 3    ; syscall: close
    syscall
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; Extrae la nota de una cadena buscando la secuencia nota:

; rdi = puntero a la cadena (nombre y nota)

; rax = nota 

obtener_nota:
    push rdi
    push rsi
    push rdx
    push rcx
buscar_nota:
    mov al, [rdi]
    cmp al, 0
    je fin_obtener
    mov rsi, rdi
    cmp byte [rsi], 'n'
    jne siguiente_char
    cmp byte [rsi+1], 'o'
    jne siguiente_char
    cmp byte [rsi+2], 't'
    jne siguiente_char
    cmp byte [rsi+3], 'a'
    jne siguiente_char
    cmp byte [rsi+4], ':'
    jne siguiente_char
    add rsi, 5             ; Saltar "nota:"
    xor rax, rax           ; Inicializa
convertir_digitos:
    movzx rcx, byte [rsi]
    cmp rcx, '0'
    jb fin_convertir
    cmp rcx, '9'
    ja fin_convertir
    imul rax, rax, 10
    sub rcx, '0'
    add rax, rcx
    inc rsi
    jmp convertir_digitos
fin_convertir:
    jmp fin_obtener
siguiente_char:
    inc rdi
    jmp buscar_nota
fin_obtener:
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; Compara dos cadenas de string
; rdi = puntero al primer string s1 , rsi = puntero al segundo string s2.
; rax = -1 si s1 < s2, 0 sin son iguales, 1 si s1 > s2

strcmp:
    push rdi
    push rsi
    push rbx
    xor rax, rax
comparar:
    mov al, [rdi]
    mov bl, [rsi]
    cmp al, bl
    jne diferente
    test al, al
    je fin_strcmp
    inc rdi
    inc rsi
    jmp comparar
diferente:
    cmp al, bl
    jl menor
    mov rax, 1
    jmp restaurar_strcmp
menor:
    mov rax, -1
restaurar_strcmp:
    pop rbx
    pop rsi
    pop rdi
    ret
fin_strcmp:
    pop rbx
    pop rsi
    pop rdi
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; Ordena el array nombres usando strcmp.

bubble_sort_alfabetico:
    mov rcx, [total_nombres]
    cmp rcx, 1
    jle fin_bubble_alfabetico
    dec rcx                      ; rcx = total_nombres - 1
ordenar_alfabetico:
    mov rdx, 0
    mov r8, 0                   ; Flag de intercambio
alfabetico_loop:
    cmp rdx, rcx
    jge alfabetico_check
    mov rdi, [nombres + rdx*8]
    mov rsi, [nombres + (rdx+1)*8]
    call strcmp
    cmp rax, 0                ; Si s1 > s2, intercambia
    jle alfabetico_no_swap
    mov rax, [nombres + rdx*8]
    mov rbx, [nombres + (rdx+1)*8]
    mov [nombres + rdx*8], rbx
    mov [nombres + (rdx+1)*8], rax
    mov r8, 1
alfabetico_no_swap:
    inc rdx
    jmp alfabetico_loop
alfabetico_check:
    cmp r8, 1
    je ordenar_alfabetico
fin_bubble_alfabetico:
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; ordena el array de nombres por nota de mayor a menor usando obtener_nota.

bubble_sort_numerico:
    mov r10, [total_nombres]
    cmp r10, 1
    jle fin_bubble_num
    dec r10                      ; r10 = total_nombres - 1
ordenar_num:
    mov rdx, 0
    mov r8, 0                   ; Flag de intercambio
num_loop:
    cmp rdx, r10
    jge num_check
    mov rdi, [nombres + rdx*8]
    call obtener_nota
    mov rbx, rax              ; Nota actual
    mov rdi, [nombres + (rdx+1)*8]
    call obtener_nota
    mov r9, rax               ; Nota del siguiente elemento
    cmp rbx, r9
    jge num_no_swap         ; no intercambia si nota actual >= siguiente 
    ; Intercambiar punteros
    mov rax, [nombres + rdx*8]
    mov rbx, [nombres + (rdx+1)*8]
    mov [nombres + rdx*8], rbx
    mov [nombres + (rdx+1)*8], rax
    mov r8, 1
num_no_swap:
    inc rdx
    jmp num_loop
num_check:
    cmp r8, 1
    je ordenar_num
fin_bubble_num:
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; recorre el arreglo nombres e imprime cada cadena.

imprimir_nombres:
    mov rcx, [total_nombres]
    test rcx, rcx
    jle fin_imprimir
    mov rdx, 0
imprimir_loop:
    mov rsi, [nombres + rdx*8]
    cmp rsi, 0
    je fin_imprimir
    call imprimir_cadena
    inc rdx
    cmp rdx, rcx
    jl imprimir_loop
fin_imprimir:
    ret
;====================================================================================
;====================================================================================
;====================================================================================
; imprime una cadena terminada en 0 usando syscall write.
imprimir_cadena:
    push rdi
    push rsi
    push rdx
    push rax
    mov rdi, 1             
    mov rdx, 0             ; Contador de longitud
contar_longitud:
    cmp byte [rsi + rdx], 0
    je escribir_cadena
    inc rdx
    jmp contar_longitud
escribir_cadena:
    mov rax, 1             ; syscall: write
    syscall
    ; Imprimir salto de línea
    mov rsi, salto_linea
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall
    pop rax
    pop rdx
    pop rsi
    pop rdi
    ret
;====================================================================================
;====================================================================================
;======================================================================================
; recorre el arreglo nombres y cuenta los intervalos de notas.


contar_intervalos_notas:
    xor rdx, rdx          ; rdx = 0
    mov rcx, [total_nombres]
    test rcx, rcx
    jle fin_contar_notas

limpiar_bin_count:
    mov qword [frec_count + rdx*8], 0   
    inc rdx
    cmp rdx, 10
    jl limpiar_bin_count

    xor rdx, rdx    ; Reiniciar rdx para recorrer las líneas

bucle_contar:
    cmp rdx, rcx
    jge fin_contar_notas
    mov rdi, [nombres + rdx*8]
    call obtener_nota       ; La nota queda en rax
    mov r8, rax             ; r8 = nota actual
    
    cmp r8, 10 ; Si nota < 10     
    jl forzar_primer_bin
 
    cmp r8, 100
    jge forzar_ultimo ;Si nota >= 100

    
    dec r8 ; resta 1 para tome la posicion correcta
    mov rax, r8

    mov r10, rdx     ; Guardar el valor actual de rdx en r10 para restaurarlo luego ya que es utilizado en el proceso de división
    
    xor rdx, rdx       ; Limpiar rdx para la división
    mov r9, 10
    div r9             ; rax = (nota-1)/10
    mov r8, rax        ; índice del bin
    mov rdx, r10       ; se restaura rdx (contador)
    jmp incrementar_bin

forzar_ultimo:
    mov r8, 9
    jmp incrementar_bin

forzar_primer_bin:
    mov r8, 0

incrementar_bin:
    ; Incrementar frec_count[r8]
    mov rax, [frec_count + r8*8] 
    add rax, 1
    mov [frec_count + r8*8], rax
    inc rdx
    jmp bucle_contar

fin_contar_notas:
    ret
    
;====================================================================================
;====================================================================================
; Rutina para imprimir el arreglo frec_count de los 10 bins



imprimir_frec_count:
    mov rbx, 0         ; índice del bin de 0 a 9
    mov r10, 10        ; numero total de bins

imprimir_bin_loop:
    
    mov rax, [frec_count + rbx*8] ; Carga el valor del bin actual en rax


    mov r12, 10
    mov rsi, buffer_bin   ; Buffer para almacenar la cadena de caracteres que forman el numero de frecuencias
    call entero_a_ascii ; Convierte el número que está en rax
    
    
    xor r11, r11
recorrido_char_frecuencia:
    cmp byte [buffer_bin + r11], 0
    je escribir_bin
    inc r11
    jmp recorrido_char_frecuencia

escribir_bin:
    mov rax, 1         ; syscall: write
    mov rdi, 1         ; stdout
    mov rsi, buffer_bin
    mov rdx, r11       ; Longitud de la cadena
    syscall

    ; Imprimir salto de línea
    mov rax, 1
    mov rdi, 1
    mov rsi, salto_linea
    mov rdx, 1
    syscall

    inc rbx           ; índice del bin
    cmp rbx, r10
    jl imprimir_bin_loop
    ret

;====================================================================================
;====================================================================================
; Convertir un entero  a cadena ASCII.


entero_a_ascii:
    push rbx
    push rcx
    push rdx

    ; Si el número es 0
    cmp rax, 0
    jne convertir_loop
    mov byte [rsi], ' ' ; para imprimer un espacio en la posicion de su nota
    mov byte [rsi+1], 0
    jmp conversion_fin
	
; Si el número es diferente de 0
convertir_loop:
    xor rcx, rcx         ;contador de dígitos
convertir_digito:
    xor rdx, rdx         ; Limpiar rdx para la división
    div r12              ; Divide rax entre 10; el cociente queda en rax y el residuo en rdx
    add rdx, '0'         ; se le suma 0 para ASCII
    mov [rsi + rcx], dl  ; Guarda el byte menos significatico de rdx en buffer_in
    inc rcx
    cmp rax, 0
    jne convertir_digito

    mov byte [rsi + rcx], 0  ; Terminar la cadena con 0 para posteriormente indentificar cuando se termina el numero       

    ; invertir la cadena 
    mov rbx, 0             ; índice inicial 
    mov rdx, rcx           ; rdx = número de dígitos
    dec rdx                ; rdx = índice del último dígito
invertir_loop:
    cmp rbx, rdx
    jge inversion_fin
    ; Intercambiar [rsi + rbx] y [rsi + rdx]
    mov al, [rsi + rbx]
    mov dl, [rsi + rdx]
    mov [rsi + rbx], dl
    mov [rsi + rdx], al
    inc rbx
    dec rdx
    jmp invertir_loop
inversion_fin:

conversion_fin:
    pop rdx
    pop rcx
    pop rbx
    ret
