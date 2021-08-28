STRINGTAIL EQU 0X00
SETCHAR EQU 0X07
VIDEOMEM EQU 0XB800
STRINGLEN EQU 0XFFFF 

section code align=16 vstart=0x7c00 ;nasm软件支持这种代码分段的操作
        ;align=n    ;表示以n字节对齐，n=16/32
                        ;vstart=addr    ;表示段汇编内 地址的开始点
    mov si, SayHello
    xor di, di  ;相当于清除di
    call PrintString
    mov si, SayByeBye
    call PrintString
    jmp End

PrintString:
    .setup:
    mov ax, VIDEOMEM
    mov es, ax
    
    mov bh, SETCHAR
    mov cx, STRINGLEN
    
    .printchar:
    mov bl, [ds:si] ;取出数据段的数据
    inc si
    mov [es:di], bl ;放到彩色文本内存中
    inc di
    mov [es:di], bh ;文字属性默认黑底白字
    inc di
    xor bl, STRINGTAIL     ;是否是字符串结束   
    jz .return
    loop .printchar
    .return:
    ret 

SayHello    db 'Hi there,I am Coding Master!'
            db STRINGTAIL
SayByeBye   db 'I think you can handle it,bye!'
            db STRINGTAIL

 End: 
 jmp End
 times 510-($-$$)   db 0x00
                    db 0x55, 0xaa
