
; post1e.asm - LODSB + STOSB: copia con transformacion a mayusculas
; Compilar: nasm -f bin post1e.asm -o post1e.com

ORG 100h

section .text
start:
    ; Preparar ES = DS
    mov ax, ds
    mov es, ax

    ; Preparar origen, destino y longitud
    mov si, origen
    mov di, destino
    mov cx, 13
    cld

.bucle:
    lodsb               ; AL = [DS:SI], SI avanza automaticamente

    cmp al, 'a'
    jb .escribir         ; Si es menor que 'a', no transformar

    cmp al, 'z'
    ja .escribir         ; Si es mayor que 'z', no transformar

    sub al, 20h          ; Convertir minuscula a mayuscula

.escribir:
    stosb               ; Guardar AL en [ES:DI], DI avanza
    loop .bucle

    ; El terminador nulo se cambia por '$' para imprimir
    mov byte [destino + 12], '$'

    ; Mostrar mensaje
    mov ah, 09h
    mov dx, msgCop
    int 21h

    ; Mostrar cadena transformada
    mov ah, 09h
    mov dx, destino
    int 21h

    ; Salto de linea
    mov ah, 09h
    mov dx, crlf
    int 21h

    ; Finalizar programa
    mov ax, 4C00h
    int 21h

section .data
    origen  db "hola, mundo!",0
    destino db 13 dup(0)
    msgCop  db "Transformado: $"
    crlf    db 0Dh,0Ah,"$"
