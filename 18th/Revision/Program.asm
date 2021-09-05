STRINGTAIL EQU 0X00
SETCHAR EQU 0X07
VIDEOMEM EQU 0XB800
STRINGLEN EQU 0XFFFF 
;;***************************************************
section head align=16 vstart=0    
        ProgramLength dd ProgramEnd  ;4b 0x00
    SegmentAddr:
        CodeSeg dd section.code.start   ;4b 0x04
        DataSeg dd section.data.start   ;4b 0x08
        StackSeg dd section.stack.start ;4b 0x0c 
    SegmentNum:
        SegNum db (SegmentNum-SegmentAddr)/4  ;1b 0x10 
    Entry dw CodeStart  ;2b 0x11 ;偏移地址  
          dd section.code.start ;4b 0x13  ;段地址  
header_end:
;;***************************************************
section code align=16 vstart=0
CodeStart:    
    mov ax, [StackSeg]  ;设置到用户程序自己的堆栈
    mov ss, ax
    mov sp, stack_end

    mov ax, [DataSeg]   ;mov ax, [ds:DataSeg]
    mov ds, ax
    mov bx, Hello   
    call  print_string 

    ;;-----------------------------
    mov bx, [es:ProgramLength] ;程序长度 
    mov al, bh 
    call  print_byte_data   
    mov al, bl 
    call  print_byte_data   

    mov bx, [es:CodeSeg] ;代码段段地址 
    mov al, bh 
    call  print_byte_data   
    mov al, bl 
    call  print_byte_data   

    mov bx, [es:DataSeg] ;数据段段地址 
    mov al, bh 
    call  print_byte_data   
    mov al, bl 
    call  print_byte_data 

    mov bx, [es:StackSeg] ;堆栈段段地址 
    mov al, bh 
    call  print_byte_data   
    mov al, bl 
    call  print_byte_data 

    mov ax, [es:DataSeg]    ;;换行
    mov ds, ax
    mov bx, NewLine 
    call  print_string 

jmp $   

;;===================================== 
print_string:    ;;打印字符串   ;传入ds、bx寄存器(存储地址标号)
    mov cl, [bx]
    cmp cl, STRINGTAIL 
    jz .exit_print_string  
    call  print_char
    inc bx 
    jmp print_string
  .exit_print_string:
ret  

;;=====================================
print_char:      ;;打印一个字符  ;传入:cl
    push ax
    push bx
    push cx
    push dx  
    push ds 
    push es 
    ;;-----取当前光标位置
    mov dx, 0x3d4
    mov al, 0x0e
    out dx, al 
    mov dx, 0x3d5
    in al, dx       ;高8位
    mov ah, al  

    mov dx, 0x3d4 
    mov al, 0x0f
    out dx, al 
    mov dx, 0x3d5
    in al, dx       ;低8位
    mov bx, ax      ;BX=代表光标位置的16位数  

  ;;-----对字符进行分类判断
  .char_whether_0x0d:
    cmp cl, 0x0d      ;回车符？
    jnz   .char_whether_0x0a 
    mov ax, bx 
    mov bl, 80 
    div bl 
    mul bl 
    mov bx, ax 
    jmp   .set_cursor 
  .char_whether_0x0a:
    cmp cl, 0x0a      ;换行符？
    jnz   .char_print
    add bx, 80 
    jmp   .roll_screen 

  .char_print:  ;字符打印
    mov ax, VIDEOMEM
    mov es, ax
    ; mov bh, SETCHAR
    ; mov cx, STRINGLEN
    shl bx, 1   ;光标位置*2=字符所在位置
    mov [es:bx], cl   ;打印字符到屏幕

    ;以下将光标位置推进一个字符
    shr bx, 1
    add bx, 1

  .roll_screen: ;屏幕滚动
    cmp bx, 2000      ;光标超出屏幕？滚屏
    jl .set_cursor    ;有符号小于则跳转
    ;;屏幕上的字符整体往上挪动一行
    mov ax, VIDEOMEM  
    mov es, ax
    mov ds, ax
    cld       ;清除方向标志位,即DF=0
    mov si, 0xa0  ;
    mov di, 0x00
    mov cx, 1920
    rep movsw ;rep重复执行后面的串操作指令,CX≠0,则CX--，循环判断
              ;MOVSW字串传送:ES:[DI]<-DS:[SI],SI<-SI+/-2,DI<-DI+/-2,偏移地址增减取决于方向标志位DF，DF=0,偏移地址增大，DF=1,平偏移地址减小
    ;;滚屏后最后一行行首位置
    mov bx, 3840  
    mov cx, 80 
  .clean_last_line:   ;清除屏幕最低一行
    mov word[es:bx], 0x0720   ;
    add bx, 2
    loop .clean_last_line
    ;;光标回到当前字符后面
    mov bx, 1920    
  .set_cursor:    ;设置光标位置  ;BX=代表光标位置 
    mov dx, 0x3d4
    mov al, 0x0e
    out dx, al 
    mov dx, 0x3d5 
    mov al, bh  
    out dx, al        ;高8位  
    mov dx, 0x3d4 
    mov al, 0x0f
    out dx, al 
    mov dx, 0x3d5 
    mov al, bl  
    out dx, al       ;低8位   
  .exit_print_char:  
    pop es
    pop ds 
    pop dx
    pop cx
    pop bx
    pop ax 
ret 

;;=====================================
print_byte_data:  ;;打印一个字节数据   ;传入al(显示的数据)
    push ax
    push bx
    push cx 
    push ds

    mov cx, [es:DataSeg]
    mov ds, cx

    mov cl, '0'
    call  print_char
    
    mov cl, 'x'
    call  print_char
    
    mov ah, al 
    shr ah, 1;无符号右移
    shr ah, 1
    shr ah, 1
    shr ah, 1     ;ah -- 存放字节数据的高4位
    and al, 0x0f  ;al -- 存放字节数据的低4位

    mov bl, ah
    mov bh, 0  
    mov cl, ByteTable[bx]   ;高4位对应的字符
    call  print_char

    mov bl, al 
    mov bh, 0    
    mov cl, ByteTable[bx]   ;低4位对应的字符
    call  print_char

    mov cl, ' '
    call  print_char 

    pop ds
    pop cx 
    pop bx
    pop ax 
ret 

;;***************************************************
section data align=16 vstart=0
    Hello db 'Hello,I come from program on sector 1,loaded by bootloader!', 0x0d, 0x0a, STRINGTAIL 
    ByteTable db '0123456789ABCDEF**' 
    DataLabel db 'Data label:', STRINGTAIL 
    AddrLabel db 'Addr label:', STRINGTAIL
    NewLine db  0x0d, 0x0a, STRINGTAIL  ;显示换行
;;***************************************************
section stack align=16 vstart=0
    resb 128  
stack_end:  
;;***************************************************
section end align=16
    ProgramEnd:

  



