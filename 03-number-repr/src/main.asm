section .bss
Result: resq 16                              ; reserve space for conversion results
AddressArray: resd 17                        ; address map for effective values processing

        
section .data
Integer8p: db 36                             ; values to be converted into hex and bin
Integer8n: db -36
Integer16p: dw 36
Integer16n: dw -36
Integer32p: dd 36
Integer32n: dd -36
Integer64p: dq 36
Integer64n: dq -36
Float32p: dd 36.0
Float32n: dd -72.0
Float32pp: dd 36.36
Float64p: dq 36.0
Float64n: dq -72.0
Float64pp: dq 36.36
Float80p: dt 36.0
Float80n: dt -72.0
Float80pp: dt 36.36
SizeArray:                                 
        dd 1, 1, 2, 2, 4, 4, 8, 8, 4
        dd 4, 4, 8, 8, 8, 10, 10, 10
        
Caption: db "Convertion Result", 0           ; window header placeholder

        
section .text
extern ToStrBin
extern ToStrHex
extern _MessageBoxA@16
extern _ExitProcess@4
global _main

_main:
        mov edi, AddressArray                ; create address map
        mov dword [edi], Integer8p    
        add edi, 4                    
        mov dword [edi], Integer8n
        add edi, 4                    
        mov dword [edi], Integer16p
        add edi, 4                    
        mov dword [edi], Integer16n
        add edi, 4                    
        mov dword [edi], Integer32p
        add edi, 4                    
        mov dword [edi], Integer32n
        add edi, 4                    
        mov dword [edi], Integer64p
        add edi, 4                    
        mov dword [edi], Integer64n
        add edi, 4                    
        mov dword [edi], Float32p
        add edi, 4                    
        mov dword [edi], Float32n
        add edi, 4                    
        mov dword [edi], Float32pp
        add edi, 4                    
        mov dword [edi], Float64p
        add edi, 4                    
        mov dword [edi], Float64n
        add edi, 4                    
        mov dword [edi], Float64pp
        add edi, 4                    
        mov dword [edi], Float80p
        add edi, 4                    
        mov dword [edi], Float80n
        add edi, 4                    
        mov dword [edi], Float80pp

        mov ecx, 0                           ; counter, 17 values
.out:
        push ecx                             ; save counter
        push dword [SizeArray + 4 * ecx]
        push dword [AddressArray + 4 * ecx]
        push Result
        call ToStrHex                        ; after ToStrHex EDI points ->
        mov word [edi], 0x0d0a               ; -> to the end of Result (HACKY!)
        add edi, 2                           ; advance pointer
        pop ecx                              ; restore counter
        push ecx                             ; save counter again

        push dword [SizeArray + 4 * ecx]     ; append to result binary ->
        push dword [AddressArray + 4 * ecx]  ; -> representation
        push edi                             ; -//-
        call ToStrBin                        ; -//-
        
        push 0                               ; show message box with results
        push Caption                         ; -//-
        push Result                          ; -//-
        push 0                               ; -//-
        call _MessageBoxA@16                 ; -//-
        
        pop ecx
        inc ecx
        cmp ecx, 17
        jl .out
        
        push 0                               ; exit programm
        call _ExitProcess@4                  ; -//-
