mov 0xb700, 0xb800  ;指令和操作数非法组合 ;立即数不能赋给立即数
mov [0x01], 0xb800  ;未指定操作大小
mov byte [0x01], 0xb800 ;操作数超过了界限
mov word [0x01], 0xb800
mov word [0x01], [0x02]  ;指令和操作数非法组合 ;内存单元间不能直接交换
mov ax, [0x02]
mov [0x03], ax
mov ds, [0x05]
mov [0x04], ds
mov ax, bx
mov cx, dl  ;指令和操作数非法组合 ;字节和字之间不能直接交换
mov cs, ds  ;指令和操作数非法组合 ;段寄存器间不能直接交换

