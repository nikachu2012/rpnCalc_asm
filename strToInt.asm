section .text

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
