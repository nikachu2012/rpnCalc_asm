%include "strToInt.asm"
%include "intToStr.asm"
%include "strlen.asm"

; スタックの段数
%define STACK_DAN 4

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

    sub rsp, STACK_DAN*8 ; 4段分のスタックを確保

    ; get argc
    cmp QWORD [rbp + 8], 2
    jl errReturn ; argc < 2 なら戻る

    ; get argv
    mov r8, QWORD [rbp + 16 + 8] ; 第1引数のアドレスをコピー
    mov r9, 0 ; カウンタを0に
    
    mov rdi, r8 ; 数値の最初のアドレスを記憶
    add rdi, r9 ; rdi=r8+r9

    mov r10, 0 ; スタックの最新値を記憶

_start_loop1:
    ; 1文字ごとのループ
    cmp BYTE [rdi + r9], 0 ; ヌル文字
    je _start_exit1 ; ヌル文字なら戻る

    cmp BYTE [rdi + r9], ' ' ; 区切り文字のとき
    je _start_if_isSEP

    cmp BYTE [rdi + r9], '+' ; +のとき
    je _start_if1_isADD

    cmp BYTE [rdi + r9], '+' ; -のとき
    je _start_if1_isADD

    cmp BYTE [rdi + r9], '*' ; *のとき
    je _start_if1_isADD

    cmp BYTE [rdi + r9], '/' ; /のとき
    je _start_if1_isADD

    ; 数値の時
    inc r9
    jmp _start_loop1

_start_if_isSEP:

    ; rdiはすでに入っている
    mov rsi, r9
    call _strToInt

    mov QWORD [rbp + r10], rax ; オペランドの値を積む
    sub r10, 8 ; スタックを上に上げる

    add rdi, r9
    inc rdi ; rdi = rdi+r9+1にする(空白文字の次の文字)
    mov r9, 0 

    jmp _start_loop1

_start_if1_isADD:
    inc r9
    jmp _start_if1_exit
_start_if1_isDEC:
    inc r9
    jmp _start_if1_exit
_start_if1_isMUL:
    inc r9
    jmp _start_if1_exit
_start_if1_isDIV:
    inc r9
    jmp _start_if1_exit
_start_if1_exit:

_start_exit1:
    leave

    ; exit syscall
    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall

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
