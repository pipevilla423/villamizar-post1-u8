
; post2c.asm - Resta BCD empaquetada con DAS
; Compilar: nasm -f bin post2c.asm -o post2c.com

ORG 100h

section .text

start:
    ; ==========================================
    ; PRUEBA 1: 73 - 28 = 45
    ; ==========================================

    mov al, 73h
    sub al, 28h       ; AL = 4Bh (BCD no valido)
    das               ; AL = 45h (BCD correcto)

    cmp al, 45h
    jne .error1

    mov ah, 09h
    mov dx, msg1
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    jmp .prueba2

.error1:
    mov ah, 09h
    mov dx, msgError1
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; PRUEBA 2: 20 - 01 = 19
    ; ==========================================

.prueba2:
    mov al, 20h
    sub al, 01h       ; AL = 1Fh (BCD no valido)
    das               ; AL = 19h (BCD correcto)

    ; Guardar CF inmediatamente despues de DAS
    setc byte [acarreo]

    cmp al, 19h
    jne .error2

    cmp byte [acarreo], 0
    jne .error2

    mov ah, 09h
    mov dx, msg2
    int 21h
    jmp .fin

.error2:
    mov ah, 09h
    mov dx, msgError2
    int 21h

.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ax, 4C00h
    int 21h

section .data

    acarreo db 0

    msg1      db "DAS OK: 45$"
    msg2      db "DAS OK: 19 CF=0$"

    msgError1 db "Error en resta BCD 73-28$"
    msgError2 db "Error en resta BCD 20-01$"

    crlf      db 0Dh,0Ah,"$"
