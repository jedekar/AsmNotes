section .text
global Add896                       ; global labels, can be -> 
global Sub224                       ; -> seen from other objects

        
        ;---------------------------------------------------------------
        ; AddSubArb: add/subtract two arbitrary-length words
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (stack) - address of the first word
        ; 2. (stack) - address of the second word
        ; 3. (stack) - address where results will be stored
        ; 4. (stack) - word length in bytes
        ; 5. (stack) - add/sub flag, 0/1 correspondingly
        ;
        ; Output:
        ; Sum, 112-byte number
        ;
        ; Registers:
        ; EAX, EBX, ECX, EDX, EDI, ESI
        ;---------------------------------------------------------------

AddSubArb:
        push ebp
        mov ebp, esp
        mov ecx, [ebp + 12]         ; counter, word length
        mov edi, [ebp + 16]         ; address of result
        mov ebx, [ebp + 20]         ; second word
        mov eax, [ebp + 24]         ; first word
        mov esi, 0                  ; offset index
        clc
.next:
        mov edx, [ebp + 8]          ; choose addition/subtraction
        dec edx                     ; -//-
        jz .diff                    ; -//-
        mov edx, [eax + 4 * esi]    ; load first word 
        adc edx, [ebx + 4 * esi]    
        jmp .store
.diff:
        mov edx, [eax + 4 * esi]    ; load first word 
        sbb edx, [ebx + 4 * esi]    
.store:
        mov [edi + 4 * esi], edx    ; store result
        inc esi                     
        dec ecx
        jnz .next

        pop ebp
        ret 20
        
        
        ;---------------------------------------------------------------
        ; Add896: add two 112-byte words
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (stack) - address of the first word
        ; 2. (stack) - address of the second word
        ; 3. (stack) - address where results will be stored
        ;
        ; Output:
        ; Sum, 112-byte number
        ;
        ; Registers:
        ; EAX, EBX, ECX, EDX, EDI, ESI - implicitly
        ;---------------------------------------------------------------
        
Add896:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8]          ; address of result
        mov ebx, [ebp + 12]         ; second word
        mov eax, [ebp + 16]         ; first word
        
        push eax
        push ebx
        push edi
        push 112
        push 0
        call AddSubArb

        pop ebp
        ret 12

        
        ;---------------------------------------------------------------
        ; Sub224: subtract two 28-byte words
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (stack) - address of the first word
        ; 2. (stack) - address of the second word
        ; 3. (stack) - address where results will be stored
        ;
        ; Output:
        ; Difference, 28-byte number
        ;
        ; Registers:
        ; EAX, EBX, ECX, EDX, EDI, ESI - implicitly
        ;---------------------------------------------------------------
        
Sub224:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8]          ; address of result
        mov ebx, [ebp + 12]         ; second word
        mov eax, [ebp + 16]         ; first word
        
        push eax
        push ebx
        push edi
        push 28
        push 1
        call AddSubArb
        
        pop ebp
        ret 12
