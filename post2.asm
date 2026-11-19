
; post2.asm - Suma con ADC y resta con SBB de 32 bits
; Compilar: nasm -f bin post2.asm -o post2.com

ORG 100h

section .text
start:
    ; ==========================================
    ; PASO 1: SUMA DE 32 BITS CON ADC
    ; A = 0001:FFFF
    ; B = 0001:0001
    ; Esperado = 0003:0000
    ; ==========================================

    mov ax, [aLo]
    mov dx, [aHi]
    mov bx, [bLo]
    mov cx, [bHi]

    add ax, bx
    adc dx, cx

    mov [resLo], ax
    mov [resHi], dx

    cmp ax, 0000h
    jne .errorSuma
    cmp dx, 0003h
    jne .errorSuma

    mov ah, 09h
    mov dx, msgSuma
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    jmp .resta

.errorSuma:
    mov ah, 09h
    mov dx, msgErrSuma
    int 21h

    mov ah, 09h
    mov dx, crlf
    int 21h

    ; ==========================================
    ; PASO 2: RESTA DE 32 BITS CON SBB
    ; A = 0003:0000
    ; B = 0001:0001
    ; Esperado = 0001:FFFF
    ; ==========================================

.resta:
    mov ax, 0000h
    mov dx, 0003h
    mov bx, 0001h
    mov cx, 0001h

    ; Restar partes bajas
    sub ax, bx

    ; Restar partes altas incluyendo el prestamo
    sbb dx, cx

    ; Verificar resultado
    cmp ax, 0FFFFh
    jne .errorResta

    cmp dx, 0001h
    jne .errorResta

    ; Mostrar resultado correcto
    mov ah, 09h
    mov dx, msgResta
    int 21h
    jmp .fin

.errorResta:
    mov ah, 09h
    mov dx, msgErrResta
    int 21h

.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h

    mov ax, 4C00h
    int 21h

section .data
    ; Valores para la suma
    aLo dw 0FFFFh
    aHi dw 0001h
    bLo dw 0001h
    bHi dw 0001h

    ; Resultado de la suma
    resLo dw 0
    resHi dw 0

    ; Mensajes
    msgSuma     db "Suma OK: 0003:0000$"
    msgErrSuma  db "Error en suma.$"
    msgResta    db "Resta OK: 0001:FFFF$"
    msgErrResta db "Error en resta.$"
    crlf        db 0Dh,0Ah,"$"
