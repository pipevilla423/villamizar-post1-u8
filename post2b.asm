
; post2b.asm - Suma BCD empaquetada con DAA
; Compilar: nasm -f bin post2b.asm -o post2b.com

ORG 100h

section .text
start:
    ; ==========================================
    ; PRUEBA 1: 47 + 38 = 85
    ; ==========================================

    mov al, [bcd1]
    add al, [bcd2]      ; 47h + 38h = 7Fh
    daa                 ; Ajuste BCD: AL = 85h
    mov [resultado], al

    mov ah, 09h
    mov dx, msg
    int 21h

    mov al, [resultado]
    call imprimirBCD

    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; PRUEBA 2: 99 + 01 = 100
    ; Resultado BCD: 00h con CF = 1
    ; ==========================================

    mov al, 99h
    add al, 01h
    daa

    ; Guardar resultado y acarreo antes de
    ; llamar a las funciones de DOS
    mov [resultado], al
    setc byte [acarreo]

    mov ah, 09h
    mov dx, msg2
    int 21h

    mov al, [resultado]
    call imprimirBCD

    mov ah, 09h
    mov dx, msgCF
    int 21h

    mov dl, [acarreo]
    add dl, '0'
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ax, 4C00h
    int 21h

; ==========================================
; SUBRUTINA: IMPRIMIR BCD EMPAQUETADO
; Entrada: AL = byte BCD
; ==========================================

imprimirBCD:
    push ax
    push bx
    push dx

    mov bl, al

    ; Imprimir decenas
    shr al, 4
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    ; Imprimir unidades
    mov al, bl
    and al, 0Fh
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    pop dx
    pop bx
    pop ax
    ret

section .data
    bcd1      db 47h
    bcd2      db 38h
    resultado db 0
    acarreo   db 0

    msg       db "BCD suma: $"
    msg2      db "BCD 99 + 01: $"
    msgCF     db " CF=$"
    crlf      db 0Dh,0Ah,"$"
