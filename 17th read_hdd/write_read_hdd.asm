HDDPORT EQU 0X1F0   ;硬盘端口号
STRINGTAIL EQU 0X00
SETCHAR EQU 0X07
VIDEOMEM EQU 0XB800 
STRINGLEN EQU 0XFFFF 

section code align=16 vstart=0x7c00

mov si, SayHello  
mov bx, [READSTART] ;起始的扇区序号
mov cx, [READSTART+0x02]
mov al, [SECTORNUM] ;要操作的扇区数量   ;注意:一个扇区512字节 
call WriteHDD   

mov si, [READSTART] ;起始的扇区序号
mov cx, [READSTART+0x02]
mov al, [SECTORNUM] ;要操作的扇区数量   ;注意:一个扇区512字节   
push ax

mov ax, [DESTMEN]   ;数据暂存区段地址
mov dx, [DESTMEN+0x02]
mov bx, 16
div bx

mov ds, ax  ;数据暂存区段地址除于16的值 赋到段寄存器
xor di, di 
pop ax

call ReadHDD
xor si, si
call PrintString
jmp End

;;===============================================
WriteHDD:
  push ax
  push bx
  push cx
  push dx   
  
    mov dx, HDDPORT+2   ;告知端口 要操作的扇区数量
    out dx, al

    mov dx, HDDPORT+3   ;告知端口 起始的扇区序号(28bit)
    mov ax, bx  
    out dx, al

    mov dx, HDDPORT+4
    mov al, ah 
    out dx, al

    mov dx, HDDPORT+5
    mov ax, cx
    out dx, al

    mov dx, HDDPORT+6
    mov al, ah 
    and al, 0x0f
    or al, 0xe0     ;bit6=1 LBA  ;bit4=0 主硬盘
    out dx, al

    mov dx, HDDPORT+7   ;告知端口 数据写入硬盘(0x30)【要读出硬盘数据0x20】
    mov al, 0x30    
    out dx, al 
  .write_waits: ;判断硬盘是否准备就绪
    nop
    in al, dx   ;读出0x1f7端口的数据
    and al, 0x88
    cmp al, 0x08 ;比较指令，不改变al的值，但影响零标志位
    jnz .write_waits 

    mov dx, HDDPORT 
    ;mov cx, 256     ;此处没有发挥作用   
  .writeword:
    nop  
    mov ax, [ds:si]
    add si, 2   
    out dx, ax 
    xor al, STRINGTAIL
    jz .writehddret
    xor ah, STRINGTAIL
    jnz .writeword

  .writehddret:  
  pop dx
  pop cx
  pop bx
  pop ax 
ret

ReadHDD:
    push ax
    push bx 
    push cx
    push dx

    mov dx, HDDPORT+2   ;告知端口 要操作的扇区数量
    out dx, al

    mov dx, HDDPORT+3   ;告知端口 起始的扇区序号(28bit)
    mov ax, si 
    out dx, al

    mov dx, HDDPORT+4
    mov al, ah 
    out dx, al
    
    mov dx, HDDPORT+5
    mov ax, cx
    out dx, al
    
    mov dx, HDDPORT+6
    mov al, ah 
    and al, 0x0f
    or al, 0xe0     ;bit6=1 LBA  ;bit4=0 主硬盘
    out dx, al

    mov dx, HDDPORT+7   ;告知端口 要读出硬盘数据(0x20)【数据写入硬盘0x30】
    mov al, 0x20
    out dx, al 
  .read_waits: ;判断硬盘是否准备就绪
    nop
    in al, dx   ;读出0x1f7端口的数据
    and al, 0x88
    cmp al, 0x08 ;比较指令，不改变al的值，但影响零标志位
    jnz .read_waits 

    mov dx, HDDPORT
    ;mov cx, 256     ;此处没有发挥作用

  .readword:
    nop
    in ax, dx
    mov [ds:di], ax
    add di, 2
    xor al, STRINGTAIL     ;;是否是结束标志
    jz .readhddret  
    xor ah, STRINGTAIL
    jnz .readword
    
  .readhddret:
    pop dx
    pop cx
    pop bx
    pop ax    
ret

PrintString:
  .setup:
    push ax
    push bx 
    push cx
    push dx

    mov ax, VIDEOMEM    
    mov es, ax
    xor di, di
    
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
    jz .printret
    loop .printchar ;每运行一次loop，相当于①cx-1; ②判断cx是否等于0，是则不执行跳转，进行下一行指令
  .printret:
    pop dx
    pop cx
    pop bx
    pop ax   
ret 

READSTART dd 10 ;起始的扇区序号   ;占4个字节(double word)
SECTORNUM db 1  ;要操作的扇区数量     ;占1个字节  
DESTMEN dd 0x10000  ;数据暂存区段地址   ;占4个字节

SayHello    db 'Hi there,I am Coding Master!'
            db STRINGTAIL

End: jmp End 
times 510-($-$$)    db 0 
                    db 0x55, 0xaa

SayByeBye   db 'I think you can handle it,bye!'
            db STRINGTAIL    
