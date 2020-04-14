section .text
global ToStrBin                 ; global labels, can be -> 
global ToStrHex                 ; -> seen from other objects

        
        ;---------------------------------------------------------------
        ; ToDigitHex: convert to hex digit ASCII code
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (AL) - number to be converted
        ;
        ; Output:
        ; ASCII code of hex digit in AL register
        ; 
        ; Registers:
        ; AL
        ;---------------------------------------------------------------        

ToDigitHex:
        and al, 0fh             ; select lower nybble
        add al, 48              ; add ASCII table offset
        cmp al, 58              ; check if char is in [48, 57] interval
        jl .exit                ; -//-
        add al, 7               ; if not, add another offset (A-F digits)
.exit:
        ret

        
        ;---------------------------------------------------------------
        ; ToStrBin: convert number to bin string
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (dword) - length of number in bytes
        ; 2. (dword) - address of number to be converted
        ; 3. (dword) - address where results will be stored
        ;
        ; Output:
        ; String with binary digits representing number, with SPACE
        ; after each octet
        ;
        ; Registers:
        ; EAX, EBX, ECX, EDX, ESI, EDI
        ;---------------------------------------------------------------
        
ToStrBin:
        push ebp
        mov ebp, esp
        mov ecx, [ebp + 16]     ; counter, length of number
        cmp ecx, 0              ; if length is zero, exit
        jle .exit               ; -//-
        mov esi, [ebp + 12]     ; take number address
        mov edi, [ebp + 8]      ; pointer, result address
.next:
        mov al, [esi + ecx - 1] ; take first byte of the number
        mov edx, 8              ; counter, 8 bits/conversion
.convert:
        shl al, 1               ; select bit
        jc .one
        mov byte [edi], 48      ; insert zero
        inc edi                 ; advance pointer
        jmp .continue
.one:
        mov byte [edi], 49      ; insert one
        add edi, 1              ; advance pointer
.continue:
        dec edx                 ; decrement bits counters
        jnz .convert
        mov byte [edi], 32      ; insert SPACE char
        inc edi                 ; advance pointer
        dec ecx                 ; decrement bytes counter
        jnz .next
        mov byte [edi], 0       ; insert NULL char
.exit:
        pop ebp
        ret 12

        
        ;---------------------------------------------------------------
        ; ToStrHex: convert number to hex string
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (dword) - length of number in bytes
        ; 2. (dword) - address of number to be converted
        ; 3. (dword) - address where results will be stored
        ;
        ; Output:
        ; String with hexadecimal digits representing number, with
        ; SPACE after each octet
        ;
        ; Registers:
        ; EAX, EBX, ECX, EDX, ESI, EDI
        ;---------------------------------------------------------------
        
ToStrHex:
        push ebp
        mov ebp, esp
        mov ecx, [ebp + 16]     ; counter, length of number
        cmp ecx, 0              ; if length is zero, exit
        jle .exit               ; -//-
        mov esi, [ebp + 12]     ; take number address
        mov edi, [ebp + 8]      ; pointer, result address
.convert:
        mov dl, [esi + ecx - 1] ; take first byte of the number
        mov al, dl              ; move for conversion
        shr al, 4               ; select first digit
        call ToDigitHex         
        mov [edi], al           ; save result
        mov al, dl              ; select second digit
        call ToDigitHex         
        mov [edi + 1], al       ; save result
        mov eax, ecx            ; check if last octet is being converted
        cmp eax, 4              ; -//-
        jle .next               ; -//-
        dec eax                 ; find next byte index
        and eax, 3              ; if index is a factor of 8, insert SPACE
        cmp al, 0               ; -//- 
        jne .next               ; if not, continue conversion
        mov byte [edi + 2], 32  ; insert SPACE char
        inc edi                 ; advance pointer
.next:
        add edi, 2              ; advance pointer
        dec ecx                 ; decrement counter
        jnz .convert            
        mov byte [edi], 0       ; insert end-of-line char
.exit:
        pop ebp
        ret 12
