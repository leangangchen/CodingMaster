mov ax, 0x7c00
mov ds, ax
mov bx, 0x353637    ;立即数超过字范围
mov byte [0xf1], 'H'    
mov byte [0xf2], 0x3839 ;立即数超过字节范围
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa
