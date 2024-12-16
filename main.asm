global _start

; Reverse Polish Notation Calculator
; by nikachu2012
; Architecture: Linux x86_64

; 楽しちゃダメだから
; by BASIC

section .text
_start:

    ; write syscall
    mov rax, 1 ; syscall number 1 = write
    mov rdi, 1 ; file desc 1 = stdout
    mov rsi, msg ; msg ptr
    mov rdx, msg_len ; msg length
    syscall
    
    ; exit syscall
    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall

; ; ===============================================================
; ; bufに指定したアドレスから始まる長さlengthの10進文字列を数値に変換します
; ; 64ビットを超える入力の動作は不定です

; ; uint64_t strToDecimal(char *buf, uint64_t length);
; ; 引数　 : rdi, rsi
; ; 戻り値 : rax
; ; 破壊レジスタ: rdi, rsi, rax
; ; ===============================================================
; _strToDecimal:
;     xor rax, rax ; raxのゼロクリア
;     xor r10, r10 ; r10のゼロクリア
    
;     sub 


section .rodata
msg: 
    db "Hello, world!", 0x0A, 0
msg_len: equ $ - msg

teststr:
    db "12345", 0
teststr_len: equ $ - teststr
