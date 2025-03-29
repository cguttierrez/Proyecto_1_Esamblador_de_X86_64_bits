# Bitácora del Proyecto

---

## Historial de Actividades

### Viernes, [01/03/25]
- **Tareas realizadas:**
  - Se estableció el objetivo del proyecto, por lo que se empez'o a familiarizar con con lenguaje ensamblador x86
  
- **Problemas encontrados:**
  - NA

---

### Sabado, [02/03/25]
- **Tareas realizadas:**
  - Se empezo a ver la forma de leer y escribir un archivo de texto en x86, estudiandolo en los ejemplos del manual para x86

- **Problemas encontrados:**
  - NA

---

### [Domingo]
- **Tareas realizadas:**
  - Se empezo a estudiar las posibles formas de resolver el problema, por lo que investiaron algunos algoritmos para su posible resolucion.

- **Problemas encontrados:**
  - NA

---                                                                                                                                                                                        
 ### [Martes]
 - **Tareas realizadas:**
 - Se selecciono el algoritmo mergesort para la organizacion en orden alfabetico de los nombres y el orden de las notas.
 - Se realizo un diagrama para comprender el algoritmo.
 - ![Image](https://github.com/user-attachments/assets/2477c53d-6106-42bb-89d2-365f58b93f0d)
 - Se inicio con las pruebas en codigo
 
 - **Problemas encontrados:**
 - NA

---

### Miercoles, [19/03/25]
 - **Tareas realizadas:**
 - Se descartó utilizar el merge sort, y en su lugar se optó por el bubble sort aunque este fuese menos eficiente, razón implementación en código
 - ![Image](https://github.com/user-attachments/assets/d4afbb13-6b1a-4422-95c6-342d6ae53281)
 - **Problemas encontrados:**
 - Encontrar la manera adecuada para almacenar los nombres y procesarlo con el bubble sort, en el caso de el ordenamiento por iniciales de los nombres y para el caso de los nombres

---

### Viernes, [21/03/25]
 - **Tareas realizadas:**
 - Se encontró una manera factible para el almacenamiento de los nombres y que facilita su implementación en el ordenamiento, la cual toma cada caracter lo lee proveniente de un buffer con todo el contenido del archivo ruta_datos.txt
 - posteriormente se guarda cada caracter de cada nombre en "almacenamiento" y alfinalizar cada uno se termina en 0, para que se pueda indicar posteriormente donde termina cada nombre también se almacena la direccion de cada inicial de los en "nombres".
```assembly
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
    mov [nombres + rdx*8], rax ; guarda la dirección de la inicial del nombre
    inc rdx
    cmp rdx, 1024
    jge fin_lectura
    inc rsi                  ; pasar el salto de línea
    inc rdi
    mov rbx, rsi             ;apunta hacia el siguiente inicial del siguiente nombre
    jmp leer_nombres
```
- para extrar la nota de cada persona, primero se realiza la busqueda de la palabra "nota:" una vez se encuentra se toman los caracteres después de esta palabra hasta encontrar un 0.
- Luego se convierte cada digito de ascii a decimal
Ejemplo:
rax = 0 * 10 = 0
1' (0x31)(49) - '0' (0x30)(48) = 1
rax = 0 + 1 = 1
Avanza al siguiente carácter ('2')
rax = 1 * 10 = 10
2' (0x32) - '0' (0x30) = 2
rax = 10 + 2 = 12
```assembly
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
```


 ---


 ### Sabado, [22/03/25]

- **Tareas realizadas:**
- aplicación del ordenamiento alfabético, funciona de tal manera que un caracter inicial almacenado en nombres en la posicion n con el de la posicion n+1, esto se da en el ciclo alfabetico_loop en cual recorre el ciclo según la cantidad de nombres guardados en el registro rcx y lo compara con la iteracion actual.
- cada inicial es comparada para devolver cual es mayor, esto se hace de la siguiente manera(llamada como strcmp):
```assembly
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
```
- En esta parte se hace lo mencionado en los primeros 2 puntos, cuando se hace la llamada strcmp se optiene cual nombre es mayor
- Si el caracter en rdi(n) es mayor al de rsi(n+1), se genera un swap en en nombres el cual intercambia la direcciones que apuntan cada caracter.
- si es igual o el primero es menor al segundo no pruduce swap
- este termina hasta que ya no existan intercambios al recorrer por todos los nombres,  por lo que termina hasta que r8 sea 0 porque ya no habría nada que intercambiar
```assembly
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
alfa_check:
    cmp r8, 1
    je ordenar_alfabetico
```

 ---


### Domingo, [23/03/25]
- **Tareas realizadas:**

- se realizó el ordenamiento con base a las notas siguiendo la lógica del ordenamiento por orden alfabético aplicando el bubble sort, para esto hace un llamado al código get_nota para obtener la nota de un nombre, por lo tanto hace un recorrido según la dirección de rdi, obtiene la nota y la almcena en rbx(n). Para la siguiente nota hace lo mismo pero una dirección después(n+1).
- compara cada nota y si la primera es menor genera swap, si es igual o mayor no genera swap

```assembly
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
```

---


### Lunes, [24/03/25]

- **Tareas realizadas:**
- se intentó generar un histograma, generando rangos y frecuencias de las notas cada 10 unidades
- nuevamente se hace uso de la función obtener_nota para procesarla:
```assembly
 xor rdx, rdx    ;  rdx indice
bucle_contar:
    cmp rdx, rcx
    jge fin_contar_notas  ; Si rdx >= total_nombres
    mov rdi, [nombres + rdx*8]
    call obtener_nota       ; La nota queda en rax
    mov r8, rax             ; r8 = nota actual
```
- se procesa para caracterizarla según su frecuencia, segun el bin(intervalo) bin=(nota−1)/10, además en x86 en una div  RAX contiene el dividendo y rdx contine la parte alta de la división RAX contiene la parte baja (los primeros 64 bits) y RDX contiene la parte alta (los segundos 64 bits).
```assembly
cmp r8, 10
    jl forzar_primer_bin  ; Si nota < 10

    cmp r8, 100
    jge forzar_ultimo  ; Si nota >= 100

    dec r8  ; Ajuste: Resta 1 para que tome la posicion correcta
    mov rax, r8
    mov r10, rdx  ; Guardamos rdx para restaurarlo luego
    xor rdx, rdx  ; Limpiar rdx para la división, esto se hace porque rdx contine la parte alta de la división por eso su valor anterior se almacena en r10 para luego restaurarlo
    mov r9, 10
    div r9  ; rax = (nota-1)/10
    mov r8, rax  ; r8 = índice del bin
    mov rdx, r10  ; Restaurar rdx
    jmp incrementar_bin
```
- se incrementa el bin(intervalo) correspondiente, esto se hace según su dirección
```assembly
incrementar_bin:
    mov eax, [frec_count + r8*4]  ; Cargar el valor actual
    add eax, 1                    ; Incrementarlo
    mov [frec_count + r8*4], eax   ; Guardar el nuevo valor
    inc rdx                        ; Avanzar al siguiente nombre
    jmp bucle_contar
```
- **Problemas detectados:**
- se generan x erroneas y más de las que deberían de existir

 ### Viernes, [28/03/25]
- **Tareas realizadas:**
- Se desarrolló un código para poder imprimir en la consola la frecuencia de datos en cada bin, de tal manera que de forma iterativa se leen los valores  en frenc_count y los convierte en ascii.
- Una vez almacenada correctamente cada numero de frecuencia es impreso, de forma que cada frecuencia se imprime una vez recorricdo todos los caracteres que forman el numero de de una frecuencia es decir hasta encontrar un 0 en buffer_bin.

```assembly
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

```

- En esta parte se hace la conversión a ascii:este descompone cada digito y le suma 0 para convertirlo a ascii, estos se almacenan de manera inversa por lo que hay que invertirlo para tener el numero correcto:
- por ejemplo: 45/10= 4 y su residuo es igual a 5, por lo que a 5 se le suma "0"(48) para pasarlo a ascii. Luego se almacena el residuo, nuevamente se hace el mismo proceso y se obtiene     un residuo por lo que se alamacena en buffer_bin el 5 en ascii, viendo se de esta manera buffer_bin="5,4,0" por lo que se invierte.
- la inversión se realiza intercambiando extremos de posición hasta que la posiciones se crucen, en ese momento termina el inversor.
```assembly
convertir_loop:
    xor rcx, rcx         ; contador de dígitos
convertir_digito:
    xor rdx, rdx         ; Limpiar rdx para la división
    div r12              ; Divide rax entre 10; el cociente queda en rax y el residuo en rdx
    add rdx, '0'         ; se le suma 0 para ASCII
    mov [rsi + rcx], dl  ; Guarda el byte menos significatico de rdx en buffer_in
    inc rcx
    cmp rax, 0
    jne convertir_digito

    mov byte [rsi + rcx], 0  ; Terminar la cadena con 0 para posteriormente indentificar cuando se termina el numero

    ;invertir la cadena
    mov rbx, 0             ; índice inicial 
    mov rdx, rcx           ; rdx = número de dígitos
    dec rdx                ; rdx = índice del último dígito
invertir_loop:
    cmp rbx, rdx
    jge inversion_fin

    ; Intercambio

    mov al, [rsi + rbx]
    mov dl, [rsi + rdx]
    mov [rsi + rbx], dl
    mov [rsi + rdx], al
    inc rbx
    dec rdx
    jmp invertir_loop

```
