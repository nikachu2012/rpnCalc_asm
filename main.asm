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
    
    mov rdi, teststr
    mov rsi, teststr_len
    call _strToInt

    ; exit syscall
    mov rax, 60 ; syscall number 1 = exit
    mov rdi, 0 ; return code
    syscall

    ret

; ===============================================================
; bufに指定したアドレスから始まる長さlengthの10進文字列を数値に変換します
; 64ビットを超える入力の動作は不定です

; uint64_t strToInt(char *buf, uint64_t length);
; 引数　 : rdi, rsi
; 戻り値 : rax
; 破壊レジスタ: rax, rdi, rsi, rcx, rdx (すべてcaller-save)
; ===============================================================
_strToInt:
    mov rax, 0 ; 結果レジスタの0クリア
    mov rcx, 0 ; ループ回数カウンタの0クリア
    mov rdx, 0 ; 一時レジスタの0クリア

_strToInt_loop1:
    cmp rcx, rsi 
    je _strToInt_ret ; i == lengthならretに飛ぶ
    
    mov dl, BYTE [rdi + rcx] ; buf[rcx]から1文字分コピー
    sub dl, 0x30 ; ASCIIコードから１桁の数値に変換

    imul rax, 10 ; raxを10倍して１桁左シフト
    add rax, rdx ; 最下位に値をいれる
    inc rcx ; ループカウンタを加算

    jmp _strToInt_loop1
_strToInt_ret:
    ret

section .rodata
msg: 
    db "Hello, world!", 0x0A, 0
msg_len: equ $ - msg

teststr:
    db "255", 0
teststr_len: equ $ - teststr - 1
