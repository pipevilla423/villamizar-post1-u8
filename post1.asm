
; post1.asm - Copia optimizada con REP MOVSW
; Compilar: nasm -f bin post1.asm -o post1.com

ORG 100h

section .data
  origen  db "HOLA, MUNDO!",0
  destino db 13 dup(0)
  msgCop  db "Copiado: $"
  crlf    db 0Dh,0Ah,"$"

section .text
start:
  ; Preparar ES = DS
  mov ax, ds
  mov es, ax

  ; Preparar origen y destino
  mov si, origen
  mov di, destino
  mov cx, 13
  cld

  ; Copiar pares de bytes con REP MOVSW
  mov ax, cx
  shr cx, 1           ; CX = 6 palabras de 2 bytes
  rep movsw           ; Copia 12 bytes

  ; Copiar el byte sobrante si la longitud es impar
  and ax, 1
  jz .fin
  movsb               ; Copia el byte 13

.fin:
  ; Cambiar el terminador nulo por '$'
  ; para mostrar la cadena con INT 21h / AH=09h
  mov byte [destino + 12], '$'

  ; Mostrar mensaje
  mov ah, 09h
  mov dx, msgCop
  int 21h

  ; Mostrar cadena copiada
  mov ah, 09h
  mov dx, destino
  int 21h

  ; Salto de linea
  mov ah, 09h
  mov dx, crlf
  int 21h

  ; Terminar programa
  mov ax, 4C00h
  int 21h
