%include "strToInt.asm"
%include "intToStr.asm"
%include "strlen.asm"

global _start

; Reverse Polish Notation Calculator
; by nikachu2012
; Architecture: Linux x86_64

; 楽しちゃダメだから
; by BASIC

section .text
_start:
    push rbp
    mov rbp, rsp

    ; get argc
    cmp QWORD [rbp + 8], 2
    jl errReturn ; argc < 2 なら戻る

    ; write syscall
    mov rax, 1 ; syscall number 1 = write
    mov rdi, 1 ; file desc 1 = stdout
    mov rsi, msg ; msg ptr
    mov rdx, msg_len ; msg length
    syscall
    
    mov rdi, teststr
    mov rsi, teststr_len
    call _strToInt

    mov rdi, 255
    mov rsi, buf
    mov rdx, buf_len
    call _intToStr
    
    ; write syscall
    mov rax, 1 ; syscall number 1 = write
    mov rdi, 1 ; file desc 1 = stdout
    mov rsi, buf ; msg ptr
    mov rdx, buf_len ; msg length
    syscall

    ; write syscall
    mov rax, 1 ; syscall number 1 = write
    mov rdi, 1 ; file desc 1 = stdout
    mov rsi, linefeed ; msg ptr
    mov rdx, 1 ; msg length
    syscall

    ; exit syscall
    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall

    pop rbp
    ret

errReturn:
    ; write syscall
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, argLessMessage ; errMsg
    mov rdx, argLessMessage_len
    syscall

    pop rbp

    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall
    ret


section .bss
buf:
    resb 30
buf_len: equ $ - buf


section .rodata
msg: 
    db "Hello, world!", 0x0A, 0
msg_len: equ $ - msg

linefeed: 
    db 0x0a

teststr:
    db "255", 0
teststr_len: equ $ - teststr - 1

argLessMessage:
    db 'Usage: ./rpncalc "2 5 3 5+++"', 0x0a, 0
argLessMessage_len: equ $ - argLessMessage - 1
