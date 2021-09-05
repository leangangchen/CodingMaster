HDDPORT EQU 0X1F0   ;硬盘端口号

section code align=16 vstart=0x7c00 
    mov si, [READSTART] ;起始的扇区序号
    mov cx, [READSTART+0x02]
    mov al, [SECTORNUM] ;要操作的扇区数量   ;注意:一个扇区512字节   
    push ax

    mov ax, [DESTMEN]   ;数据暂存区段地址
    mov dx, [DESTMEN+0x02]
    mov bx, 16
    div bx

    mov ds, ax  ;数据暂存区段地址除于16的值 赋到段寄存器
    xor di,di 
    pop ax
    ;read the first sector
    call ReadHDD
  ;对加载到内存中的Program程序 段地址及其入口地址进行重定位
    ResetSegment: 
    mov bx, 0x04    ;第一个段地址，在偏移为0x04内存处
    xor cx, cx
    mov cl, [0x10]  ;段的总个数在0x10内存处

  .reset:   ;段地址重定位
    mov ax, [bx]  ;注意：此时ds=0x1000   ;寄存器和ds寄存器是关联的
    mov dx, [bx+2]
    add ax, [cs:DESTMEN]
    adc dx, [cs:DESTMEN+2]
    mov si, 16
    div si 
    mov [bx], ax
    add bx, 4
    loop .reset
    
  ResetEntry: ;入口地址重定位
    mov ax, [0x13]
    mov dx, [0x15]  
    add ax, [cs:DESTMEN]
    adc dx, [cs:DESTMEN+2]
    mov si, 16
    div si
    mov [0x13], ax      
    jmp far [0x11]  ;跳转到的位置不在内存中的BootLoader代码范围(0x7c00~0x7e00),故需要加far

;;================================
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
    or al, 0xe0
    out dx, al

    mov dx, HDDPORT+7   ;告知端口 要读出硬盘数据(0x20)【写入硬盘用0x30】
    mov al, 0x20
    out dx, al 

  .waits: ;判断硬盘是否准备就绪
    in al, dx   ;读出0x1f7端口的数据
    and al, 0x88
    cmp al, 0x08 ;比较指令，不改变al的值，但影响零标志位
    jnz .waits 

    mov dx, HDDPORT
    mov cx, 256     

  .readword:
    in ax, dx
    mov [ds:di], ax
    add di, 2
    ;xor al, STRINGTAIL     ;;是否是结束标志
    ;jz .readhddret  
    ;xor ah, STRINGTAIL
    ;jnz .readword
    loop .readword
    
  .readhddret:
    pop dx
    pop cx
    pop bx
    pop ax    
ret

READSTART dd 1
SECTORNUM db 1
DESTMEN dd 0x10000

End: jmp End
times 510-($-$$) db 0 
                 db 0x55, 0xaa  

