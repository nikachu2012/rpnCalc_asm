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

; ===============================================================
; bufに指定したアドレスから始まる長さlengthの10進文字列を数値に変換します
; 64ビットを超える入力の動作は不定です

; uint64_t strToInt(char *buf, uint64_t length);
; 引数　 : rdi, rsi
; 戻り値 : rax
; 破壊レジスタ: rcx, rdx (すべてcaller-save)
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

; ===============================================================
; rdiレジスタに入っている64bit値を10進文字列に変換し、bufからbuf+buflenまでのメモリに格納する
; 文字列の最後にはNULLが追加される　64ビットを超える入力の動作は不定とする
;
; 最大22バイトのスタックを使用します
;
; void intToStr(uint64_t data, char *buf, char *buflen);
; 引数　 : rdi, rsi, rdx
; 戻り値 : なし
; 破壊レジスタ: rax, rcx, rdx, r8 (すべてcaller-save)
; ===============================================================
_intToStr:
    push rbp
    mov rbp, rsp

    mov rax, rdi ; 演算用にdataをコピー
    mov rcx, 10 ; 割るための定数

    ; 最初から0のときの処理
    cmp rax, 0
    jne _intToStr_loop1 ; 呼び出し時に0でないとき
    
    mov BYTE [rbp], 0x30 ; 呼び出し時に0なら'0'を積んで戻る
    dec rbp
    jmp _intToStr_exit1

_intToStr_loop1:
    ; 数値を文字に変換してスタックに積む
    cmp rax, 0
    je _intToStr_exit1 ; raxが0になったら戻る

    mov rdx, 0 ; rdxの0クリア
    idiv rcx ; 10で割って最下位の桁を取り出す
    add rdx, 0x30 ; 余りの数値をASCIIコードにする
    mov BYTE [rbp], dl ; 左の文字からスタックに積む

    dec rbp ; スタックを1バイト戻す
    jmp _intToStr_loop1

_intToStr_exit1:
    ; スタックからバッファに文字列をコピー
    mov r8, 0 ; ループカウンタの0クリア
    inc rbp

_intToStr_loop2:
    cmp rsp, rbp
    jl _intToStr_ret ; rsp<rbpになるまでループ

    mov r10b, BYTE [rbp]
    mov BYTE [rsi + r8], r10b ; rbp+1の値をbufにコピー

    inc rbp
    inc r8
    jmp _intToStr_loop2

_intToStr_ret:
    mov BYTE [rsi + r8], 0 ; 末尾にヌル文字を追加
    
    pop rbp
    ret

; ===============================================================
; ポインタbufから始まる文字列の長さを返します。長さにヌル文字の分は含まれません
;
; |a|b|c|d|e|\0|
; |<-返り値->|
;
; uint64_t strlen(char *buf);
; 引数　 : rdi
; 戻り値 : rax
; 破壊レジスタ: なし
; ===============================================================
_strlen:
    push rbp
    mov rbp, rsp
    mov rax, 0 ; カウンタの0クリア

_strlen_loop1:
    cmp BYTE [rdi + rax], 0
    je _strlen_ret ; rax文字目がヌル文字なら

    inc rax
    jmp _strlen_loop1

_strlen_ret:
    ; raxを戻り値として戻る
    pop rbp
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
