section .bss
ResStr: resq 64                              ; reserve space for conversion results
Result: resd 28

        
section .data
Caption: db "LONGOP Result", 0               ; window header
ValueA:
        dd 80010001h, 80020001h, 80030001h, 80040001h, 80050001h, 80060001h, 80070001h
        dd 80080001h, 80090001h, 800A0001h, 800B0001h, 800C0001h, 800D0001h, 800E0001h
        dd 800F0001h, 80100001h, 80110001h, 80120001h, 80130001h, 80140001h, 80150001h
        dd 80160001h, 80170001h, 80180001h, 80190001h, 801A0001h, 801B0001h, 801C0001h
ValueB:
        times 28 dd 80000001h

        
section .text
extern Add896
extern Sub224
extern ToStrHex
extern _MessageBoxA@16
extern _ExitProcess@4
global _main

_main:
        mov ecx, 3
        push ecx
.sum:
        mov eax, 112
        push eax
        push ValueA
        push ValueB
        push Result
        call Add896
        pop eax
.convert:
        push eax
        push Result
        push ResStr
        call ToStrHex
        jmp .ShowResults
        
.CalcVal:
        push ecx
        mov eax, 26
        mov edi, ValueA
        mov ecx, 0
.CalcValLoop:
        mov dword [edi], eax
        add edi, 4
        inc eax
        inc ecx
        cmp ecx, 28
        jl .CalcValLoop
        jmp .sum
        
.FillWithZero:
        push ecx
        mov edi, ValueB
        mov ecx, 0
.FillWithZeroLoop:
        mov dword [edi], 0
        add edi, 4
        inc ecx
        cmp ecx, 7
        jl .FillWithZeroLoop        
.diff:
        mov eax, 28
        push eax
        push ValueB
        push ValueA
        push Result
        call Sub224
        pop eax
        jmp .convert
        
.ShowResults:
        push 0                               
        push Caption                         
        push ResStr                          
        push 0                               
        call _MessageBoxA@16
        
        pop ecx
        dec ecx
        cmp ecx, 2
        je .CalcVal
        cmp ecx, 1
        je .FillWithZero

        push 0                               ; exit programm
        call _ExitProcess@4                  ; -//-
        
