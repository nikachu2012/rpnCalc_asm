section .text

; ===============================================================
; rdiレジスタに入っている符号付き64bit値を10進文字列に変換し、bufから始まるメモリに格納する
; 文字列の最後にはNULLが追加される　64ビットを超える入力の動作は不定とする
; bufは最大22バイト使う(負数の符号+2^63の桁数+NULL文字)
;
; 24バイトのスタックを確保します
;
; void intToStr(uint64_t data, char *buf);
; 引数　 : rdi, rsi
; 戻り値 : なし
; 破壊レジスタ: rax, rcx, rdx, r8, r9 (すべてcaller-save)
; ===============================================================
_intToStr:
    push rbp
    mov rbp, rsp
    sub rsp, 8*3 ; スタックを24バイト確保

    mov rax, rdi ; 演算用にdataをコピー
    mov rcx, 10 ; 割るための定数
    mov r8, 0 ; ループカウンタの0クリア

    ; 最初から0のときの処理
    cmp rax, 0
    jl  _intToStr_isNegative
    jne _intToStr_loop1 ; 呼び出し時に0でないとき
    
    mov BYTE [rbp + r8], '0' ; 呼び出し時に0なら'0'を積んで戻る
    dec r8
    jmp _intToStr_exit1

_intToStr_isNegative:
    neg rax ; 正の数に変換
    ; loop1に続く

_intToStr_loop1:
    ; 数値を文字に変換してスタックに積む
    cmp rax, 0
    je _intToStr_exit1 ; raxが0になったら戻る

    mov rdx, 0 ; rdxの0クリア
    idiv rcx ; 10で割って最下位の桁を取り出す
    add rdx, 0x30 ; 余りの数値をASCIIコードにする
    mov BYTE [rbp + r8], dl ; 左の文字からスタックに積む

    dec r8 ; スタックを1バイト戻す
    jmp _intToStr_loop1

_intToStr_exit1:
    ; スタックからバッファに文字列をコピー
    mov r9, 0 ; ループカウンタ
    inc r8
    
    cmp rdi, 0
    jl  _intToStr_addSign ; dataが負の数の時ジャンプ
    
    jmp _intToStr_loop2 ; dataが正の数の時

_intToStr_addSign:
    mov BYTE [rsi + r9], '-' ; -の符号を最初にコピー
    inc r9
    ; loop2に続く

_intToStr_loop2:
    cmp r8, 0
    jg _intToStr_ret ; r8==0なるまでループ

    mov r10b, BYTE [rbp + r8]
    mov BYTE [rsi + r9], r10b ; rbp+1の値をbufにコピー

    inc r8
    inc r9
    jmp _intToStr_loop2

_intToStr_ret:
    mov BYTE [rsi + r9], 0 ; 末尾にヌル文字を追加
    
    leave
    ret
