section .text

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
