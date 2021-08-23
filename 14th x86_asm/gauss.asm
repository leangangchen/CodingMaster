
mov cx, 100 ;设定循环次数
mov ax, 0x0000  ;初始化ax
sum: 
    add ax, cx
    loop sum    ;;cpu自动判断cx寄存器的值，为0则跳过循环，非0则cx-1，然后跳转到标号处

jmp $
times 510-($-$$) db 0
db 0x55, 0xaa
