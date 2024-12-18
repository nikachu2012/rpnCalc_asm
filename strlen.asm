section .text

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
