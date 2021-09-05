STRINGTAIL EQU 0X00
SETCHAR EQU 0X07
VIDEOMEM EQU 0XB800
STRINGLEN EQU 0XFFFF 

section head align=16 vstart=0
        Size dd ProgramEnd  ;4b 0x00
    SegmentAddr:
        CodeSeg dd section.code.start   ;4b 0x04
        DataSeg dd section.data.start   ;4b 0x08
        StackSeg dd section.stack.start ;4b 0x0c 
    SegmentNum:
        SegNum db (SegmentNum-SegmentAddr)/4;1b 0x10 
    Entry dw CodeStart  ;2b 0x11 ;偏移地址  
          dd section.code.start ;4b 0x13  ;段地址  
    
section code align=16 vstart=0
CodeStart:
    mov ax, [DataSeg]   ;mov ax, [ds:DataSeg]
    mov ds, ax
    xor si, si
    call    PrintString
    jmp $

;;=======================
PrintString:
    push ax
    push bx
    push cx
    push dx  
    push es 
  .setup:
    mov ax, VIDEOMEM
    mov es, ax
    xor di, di  ;相当于清除di
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
    pop es 
    pop dx
    pop cx
    pop bx
    pop ax 
ret 

section data align=16 vstart=0
    Hello db 'Hello,I come from program on sector 1,loaded by bootloader!', 0x00

section stack align=16 vstart=0
    resb 128

section end align=16
    ProgramEnd:

  



