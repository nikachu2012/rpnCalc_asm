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
    jl missingUsageErr ; argc < 2 なら戻る

    ; get argv
    mov r8, QWORD [rbp + 16 + 8] ; 第1引数のアドレスをコピー
    mov r9, 0 ; カウンタを0に
    
    mov rdi, r8 ; オペランド値の最初のアドレスを記憶

    mov r10, 0 ; スタックのオフセットを記憶

_start_loop1:
    ; 1文字ごとのループ
    cmp BYTE [rdi + r9], 0 ; ヌル文字
    je _start_exit1 ; ヌル文字なら戻る

    ; 0x30 <= rdi+r9 <= 0x39
    cmp BYTE [rdi + r9], 0x30-1
    jle _start_if_notNumber    ; 数値でないときにジャンプ
    cmp BYTE [rdi + r9], 0x39
    jg _start_if_notNumber     ; 数値でないときにジャンプ

    ; 数値の時
    inc r9
    jmp _start_loop1

_start_if_notNumber:

    ; 0x30 <= rdi+r9-1 <= 0x39
    cmp BYTE [rdi + r9 - 1], 0x30-1
    jle _start_if_operand     ; 前が数値でないときはスタックに積まずにオペランド処理に進む
    cmp BYTE [rdi + r9 - 1], 0x39
    jg _start_if_operand      ; 前が数値でないときはスタックに積まずにオペランド処理に進む

    ; スタックに値を積む処理
    ; rdiはすでに入っている
    mov rsi, r9
    call _strToInt

    mov QWORD [rbp + r10], rax ; オペランドの値を積む
    sub r10, 8 ; スタックを上に上げる

_start_if_operand:
    add rdi, r9
    inc rdi ; rdi = rdi+r9+1にする(空白文字の次の文字)
    mov r9, 0 

    cmp BYTE [rdi - 1], ' ' ; 区切り文字のとき
    je _start_loop1

    ; スタックを破壊しないかチェック
    cmp r10, -16
    jg _start_stackBreakErr 

    cmp BYTE [rdi - 1], '+' ; +のとき
    je _start_if1_isADD

    cmp BYTE [rdi - 1], '-' ; -のとき
    je _start_if1_isDEC

    cmp BYTE [rdi - 1], '*' ; *のとき
    je _start_if1_isMUL

    cmp BYTE [rdi - 1], '/' ; /のとき
    je _start_if1_isDIV

_start_if1_isADD:
    mov rax, QWORD [rbp + r10 + 8] ; 現在位置から1段下のスタックを取得
    add QWORD [rbp + r10 + 16], rax  ; 2段下と1段下を加算

    add r10, 8 ; スタックを一段下げる(加算するとオペランドが減るため)

    jmp _start_loop1
_start_if1_isDEC:
    jmp _start_loop1
_start_if1_isMUL:
    jmp _start_loop1
_start_if1_isDIV:
    jmp _start_loop1
_start_if1_exit:
    jmp _start_loop1

_start_exit1:
    ; スタック最上段をを出力
    mov rdi, QWORD [rbp + r10 + 8] ; 最上段のスタックを取得
    mov rsi, buf
    mov rdx, buf_len
    call _intToStr

    ; write syscall
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, buf ; errMsg
    mov rdx, buf_len
    syscall

    leave ; rsp<-rbp, pop rbp

    ; exit syscall
    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall

    ret

_start_stackBreakErr:
    ; write syscall
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, stackErrMsg ; エラーメッセージ
    mov rdx, stackErrMsg_len
    syscall

    jmp errReturn

missingUsageErr:
    ; write syscall
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, argLessMessage ; errMsg
    mov rdx, argLessMessage_len
    syscall ; ArgLessMessageを出力

    jmp errReturn
    
errReturn:
    ; エラー終了
    leave  ; rsp<-rbp, pop rbp

    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 1 ; return code
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


stackErrMsg:
    db 'Missing operand', 0x0a, 0
stackErrMsg_len: equ $ - stackErrMsg - 1
