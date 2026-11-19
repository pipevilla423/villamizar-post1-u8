
; post1c.asm - Busqueda con REPNE SCASB
ORG 100h

section .text
start:
    mov ax, ds
    mov es, ax

    mov di, cadena
    mov al, 'z'
    mov cx, longCad
    cld

    repne scasb
    jne noHallado

    ; Posicion base 0
    mov bx, di
    sub bx, cadena
    dec bx

    mov ah, 09h
    mov dx, msgHall
    int 21h

    ; Mostrar posicion decimal (0 a 99)
    mov ax, bx
    mov bl, 10
    div bl

    mov bx, ax

    cmp bl, 0
    je unidades

    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h

unidades:
    mov dl, bh
    add dl, '0'
    mov ah, 02h
    int 21h

    jmp saltoLinea

noHallado:
    mov ah, 09h
    mov dx, msgNoH
    int 21h

saltoLinea:
    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ax, 4C00h
    int 21h

section .data
    cadena db "Arquitectura de Computadores",0
    longCad equ $ - cadena - 1
    msgHall db "Hallado en posicion: $"
    msgNoH db "No encontrado.$"
    crlf db 0Dh,0Ah,"$"
