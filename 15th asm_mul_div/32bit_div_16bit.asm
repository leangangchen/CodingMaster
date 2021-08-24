mov dx, 0x0009  ;被除数
mov ax, 0x0006 
mov cx, 0x0002  ;除数
;设置ss寄存器
mov bx, 0x0000
mov ss, bx 
;设置sp寄存器
mov sp, bx 
;ax压入栈
push ax  

mov ax, dx 
mov dx, 0
div cx 
mov bx, ax  ;bx保存高位16bit除于cx后的商，
            ;dx保存着高位16bit除于cx后的余数        
;ax弹出栈
pop ax  
div cx      ;高位16bit除于cx后的余数作为被除数高位继续参与运算

;循环及补0
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa
