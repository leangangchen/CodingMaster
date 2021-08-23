;bx:ax=0x0001f000
mov bx, 0x0001
mov ax, 0xf000
;dx:cx=0x00101000
mov dx, 0x0010
mov cx, 0x1000
;低位相加
add ax, cx
;高位相加
adc bx, dx

;bx:ax=0x00020003
mov bx, 0x0002
mov ax, 0x0003
;dx:cx=0x00003002
mov dx, 0x0000
mov cx, 0x3002
;低位相减
sub ax, cx
;高位相减
sbb bx, dx

jmp $
times 510-($-$$) db 0   
db 0x55, 0xaa
