# Proyecto_1_Esamblador_de_X86_64_bits
EL4314 – Arquitectura de Computadras Primer Semestre 2025 Proyecto #1: Esamblador de X86_64 bits

## Referencias.
[1] Evingtone, "Assembly BUBBLE SORT using Nasm," GitHub, 2021. [Online]. Available: https://gist.github.com/Evin-Ngoa/3431161e46b2125cbecac5eb10e9a5be.

# Descripción del Diseño de Software

## 1. Lectura y Almacenamiento de Nombres
### Lógica Utilizada:
El programa lee nombres desde un archivo y los almacena en memoria. Para ello:
1. Se recorre el archivo caracter por caracter.
2. Si el carácter es un salto de línea (`10` en ASCII), se considera el fin de un nombre.
3. Se almacena la dirección del primer carácter de cada nombre en un arreglo llamado `nombres`.
4. Se termina cada nombre con un byte `0` para indicar el final de la cadena.

**Registros utilizados:**
- `rdi`: Apunta al buffer que contiene el archivo.
- `rsi`: Apunta a la posición de almacenamiento del nombre actual.
- `rbx`: Mantiene la referencia a la dirección inicial del nombre en `almacenamiento`.
- `rdx`: Lleva la cuenta de nombres leídos.

```assembly
leer_nombres:
    cmp byte [rdi], 0          ; Si es fin del archivo
    je fin_lectura
    cmp byte [rdi], 10         ; Si hay salto de línea
    je guardar_nombre

    mov al, [rdi]
    mov [rsi], al
    inc rsi
    inc rdi

    cmp rsi, almacenamiento + 8192
    jge fin_lectura
    jmp leer_nombres
```
- **Diagrama de flujo del funcionamiento**

![Image](https://github.com/user-attachments/assets/9ea4f43b-6f22-4e4d-94e6-5390fd2a42d3)
## 2. Extracción de Notas
### Lógica Utilizada:
El programa busca la palabra clave `nota:` en el archivo y extrae los números que la siguen. Luego, convierte los dígitos ASCII en un valor numérico.

**Registros utilizados:**
- `rdi`: Apunta al texto en búsqueda de "nota:".
- `rsi`: Se usa como cursor dentro de la palabra "nota:".
- `rax`: Almacena la nota convertida a entero.
- `rcx`: Contiene cada dígito convertido.

```assembly
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
```
- **Diagrama de flujo del funcionamiento**
  ![Image](https://github.com/user-attachments/assets/efe4a09d-64d2-42fc-8c13-d401ad904e0f)
## 3. Ordenamiento Alfabético (Bubble Sort)
### Lógica Utilizada:
El algoritmo de ordenamiento burbuja compara cada par de nombres consecutivos usando una función llamada `strcmp` la cual obtiene un 1 si la comparación es mayor, -1 si es menor y 0 si son iguales. Si el primero es mayor, intercambia las posiciones en el arreglo `nombres`.

**Registros utilizados:**
- `rdi`: Apunta al primer nombre.
- `rsi`: Apunta al segundo nombre.
- `rdx`: Recorre la lista de nombres.
- `rcx`: Contiene la cantidad total de nombres.
- `r8`: Bandera para saber si hubo intercambio.

```assembly
alfabetico_loop:
    cmp rdx, rcx
    jge alfabetico_check
    mov rdi, [nombres + rdx*8]
    mov rsi, [nombres + (rdx+1)*8]
    call strcmp
    cmp rax, 0
    jle alfabetico_no_swap

    ; Intercambio
    mov rax, [nombres + rdx*8]
    mov rbx, [nombres + (rdx+1)*8]
    mov [nombres + rdx*8], rbx
    mov [nombres + (rdx+1)*8], rax
    mov r8, 1
```
- **Diagrama de flujo del funcionamiento**
  
![Image](https://github.com/user-attachments/assets/01dc5d78-59b9-4810-8891-a460ee20ece2)

- **Diagrama de flujo del funcionamiento de la función creada para comparar letras(strcmp)**
  ![Image](https://github.com/user-attachments/assets/c8061624-174f-4331-b7d6-a34bfe99734a)
  
## 4. Ordenamiento por Notas (Bubble Sort)
### Lógica Utilizada:
El algoritmo ordena las notas de mayor a menor. Obtiene las notas con `obtener_nota`, las compara y realiza intercambios según sea necesario.

**Registros utilizados:**
- `rdi`: Apunta a un nombre.
- `rax`: Almacena la nota obtenida.
- `rbx`: Contiene la nota actual.
- `r9`: Contiene la siguiente nota.

```assembly
num_loop:
    mov rdi, [nombres + rdx*8]
    call obtener_nota
    mov rbx, rax
    mov rdi, [nombres + (rdx+1)*8]
    call obtener_nota
    mov r9, rax
    cmp rbx, r9
    jge num_no_swap

    ; Intercambio de punteros
    mov rax, [nombres + rdx*8]
    mov rbx, [nombres + (rdx+1)*8]
    mov [nombres + rdx*8], rbx
    mov [nombres + (rdx+1)*8], rax
```

- **Diagrama de flujo del funcionamiento**
  
![Image](https://github.com/user-attachments/assets/643fbfef-0a73-4784-b8b7-2573df2adfd2)

## 5. Cálculo de Frecuencias para Histograma
### Lógica Utilizada:
Se dividen las notas en bins de 10 unidades cada uno. Se utiliza la división para determinar a qué bin pertenece cada nota y se incrementa el contador correspondiente.

**Registros utilizados:**
- `r8`: Contiene la nota actual.
- `rax`: Se usa para calcular el bin `(nota)/10`.
- `rdx`: Contiene el residuo de la división.
- `r10`: Guarda temporalmente el valor de `rdx` para restaurarlo luego.

```assembly
div r9  ; rax = (nota)/10
mov r8, rax  ; r8 = índice del bin
mov eax, [frec_count + r8*4]  ; Cargar el valor actual
add eax, 1  ; Incrementarlo
mov [frec_count + r8*4], eax  ; Guardar el nuevo valor
```
- **Diagrama de flujo del funcionamiento**

![Image](https://github.com/user-attachments/assets/f5ccd0e1-5524-471e-8bd0-27e6adb0e635)
  
## 6. Impresión de Frecuencias
### Lógica Utilizada:
Se recorre `frec_count`, se convierte cada valor a ASCII y se imprime en la consola.

**Registros utilizados:**
- `rbx`: Recorre los bins.
- `rsi`: Apunta al buffer de conversión.
- `r11`: Contador de caracteres para imprimir.

```assembly
recorrido_char_frecuencia:
    cmp byte [buffer_bin + r11], 0
    je escribir_bin
    inc r11
    jmp recorrido_char_frecuencia
```

- **Diagrama de flujo del funcionamiento**

![Image](https://github.com/user-attachments/assets/57834e00-b26a-418c-96d7-d649c414e7f5)
  
- **Diagrama de flujo del funcionamiento individual de la conversión de un número a ascii**

  ![Image](https://github.com/user-attachments/assets/f71a104b-4837-4e2f-ae85-2e10d3fc0079)
