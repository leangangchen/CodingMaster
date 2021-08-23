mov ax, 0b800h      ; 选定(0b800h*16)=0xb8000段地址开始，即对彩色文本进行操作
mov ds, ax

mov byte [0x00],'2' ;发送文本内容到显存偏移地址低位，显存偏移地址高位不赋值 使用默认属性
mov byte [0x02],'0'
mov byte [0x04],'2'
mov byte [0x06],'1'
mov byte [0x08],','
mov byte [0x0a],'H'
mov byte [0x0c],'a'
mov byte [0x0e],'p'
mov byte [0x10],'p'
mov byte [0x12],'y'
mov byte [0x14],' '
mov byte [0x16],'N'
mov byte [0x18],'e'
mov byte [0x1a],'w'
mov byte [0x1c],' '
mov byte [0x1e],'Y'
mov byte [0x20],'e'
mov byte [0x22],'a'
mov byte [0x24],'r'
mov byte [0x26],'!'

jmp $   ;标定当前位置

times 510-($-$$) db 0   ;;从jmp标定位置到MBR结束都填充0  
;;MBR占用512字节，$代表jmp所在得到位置，$$代表程序起始位置，($-$$)算得从程序开头到jmp位置一共有多少字节
db 0x55,0xaa    ;填充MBR分区结尾的标志位

