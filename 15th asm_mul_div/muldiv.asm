;8位乘法
mov al, 0xf0
mov ah, 0x02
mul ah
;16位乘法
mov ax, 0xf000
mov bx, 0x0002
mul bx
;16位除法
mov ax, 0x0004
mov bl, 0x0002
div bl 
;32位除法
mov dx, 0x0008
mov ax, 0x0006
mov cx, 0x0002
div cx  ;此处商大于16bit的数，会出现错误
;循环及其补0
jmp $
times 510-($-$$) db 0 
db 0x55, 0xaa
