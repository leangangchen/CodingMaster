STRINGTAIL EQU 0X00
SETCHAR EQU 0X07
VIDEOMEM EQU 0XB800
STRINGLEN EQU 0XFFFF 

section code align=16 vstart=0x7c00 ;nasm软件支持这种代码分段的操作
            ;align=n    ;表示以n字节对齐，n=16/32
            ;vstart=addr    ;表示段内的偏移地址的基准地址
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
    loop .printchar ;每运行一次loop，相当于①cx-1; ②判断cx是否等于0，是则不执行跳转，进行下一行指令
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
