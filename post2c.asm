
; post2c.asm - MUL/DIV: calculadora de digitos
; NASM 16 bits - DOSBox
ORG 100h

section .text

start:
    ; Leer operando A
    mov ah, 09h
    mov dx, pA
    int 21h

    mov ah, 01h
    int 21h
    sub al, 30h
    mov [operandoA], al

    ; Leer operando B
    mov ah, 09h
    mov dx, pB
    int 21h

    mov ah, 01h
    int 21h
    sub al, 30h
    mov [operandoB], al

    ; Leer operador
    mov ah, 09h
    mov dx, mensajeOperacion
    int 21h

    mov ah, 01h
    int 21h
    mov [operador], al

    ; Seleccionar operacion
    cmp al, '*'
    je .multiplicar

    cmp al, '/'
    je .dividir

    jmp .fin

.multiplicar:
    mov al, [operandoA]
    mul byte [operandoB]

    push ax

    mov ah, 09h
    mov dx, mensajeResultado
    int 21h

    pop ax
    call imprimirAX
    jmp .fin

.dividir:
    cmp byte [operandoB], 0
    je .divisionCero

    mov al, [operandoA]
    xor ah, ah
    div byte [operandoB]

    ; AL contiene el cociente
    xor ah, ah
    push ax

    mov ah, 09h
    mov dx, mensajeResultado
    int 21h

    pop ax
    call imprimirAX
    jmp .fin

.divisionCero:
    mov ah, 09h
    mov dx, msgErr
    int 21h

.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ax, 4C00h
    int 21h

; Subrutina: imprimir AX como numero decimal
imprimirAX:
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

.divide:
    xor dx, dx
    div bx
    push dx
    inc cx

    test ax, ax
    jnz .divide

.popDigit:
    pop dx
    add dl, 30h

    push cx
    mov ah, 02h
    int 21h
    pop cx

    loop .popDigit

    pop dx
    pop cx
    pop bx
    ret

section .data

    pA        db "Primer operando (0-9): $"
    pB        db 0Dh,0Ah,"Segundo operando (0-9): $"
    mensajeOperacion       db 0Dh,0Ah,"Operacion (* o /): $"
    mensajeResultado      db 0Dh,0Ah,"Resultado: $"
    msgErr    db 0Dh,0Ah,"Division por cero.$"
    crlf      db 0Dh,0Ah,"$"

    operandoA db 0
    operandoB db 0
    operador  db 0
