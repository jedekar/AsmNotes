section .bss
Result: resd 16                       ; reserve space for cpuid results
Vendor: resd 4                        ; reserve for vendor string
Brand: resd 13                        ; reserve for brand name


section .data
Caption: db "CPUID Result", 0         ; window header placeholder
VendorCap: db "Vendor ID", 0          ; for manufacturer string
BrandCap: db "Brand", 0               ; processor brand string
  
section .text
extern _MessageBoxA@16
extern _ExitProcess@4
global _main

_main:
        mov eax, 0                    ; gather vendor string
        mov edi, Vendor               ; pointer to reserved space
        cpuid                         
        mov [edi], ebx                ; compose vendor string
        add edi, 4                    ; advance pointer by DWORD
        mov [edi], edx                ; -//-
        add edi, 4                    ; -//-
        mov [edi], ecx                ; -//-

        push 0                        ; show message box with vendor
        push VendorCap                ; -//-
        push Vendor                   ; -//-
        push 0                        ; -//-
        call _MessageBoxA@16          ; -//-
        
        
        mov ecx, 0                    ; counter, (0<=2) 3 loops, 3 calls
.LowerCalls:
        push ecx                      ; save counter
                
        push ecx                      ; call CPUID
        push Result                   ; -//-
        call CpuIdToStr               ; -//-
        
        push 0                        ; call message box
        push Caption                  ; -//-
        push Result                   ; -//-
        push 0                        ; -//-
        call _MessageBoxA@16          ; -//-

        pop ecx                       ; retrieve counter
        inc ecx                       ; increment counter
        cmp ecx, 2                    ; check whether lower calls are finished
        jle .LowerCalls               ; jump, if aren't
        mov ecx, 0x80000000           ; counter, (0<=5) 6 loops, 6 calls
.HigherCalls:
        push ecx

        push ecx                      ; call CPUID
        push Result                   ; -//-
        call CpuIdToStr               ; -//-
        
        push 0                        ; show CPUID results
        push Caption                  ; -//-
        push Result                   ; -//-
        push 0                        ; -//-
        call _MessageBoxA@16          ; -//-

        pop ecx                       ; retrieve counter
        inc ecx                       ; increment counter
        cmp ecx, 0x80000008           ; check whether higher calls are finished
        jle .HigherCalls
        
        mov eax, 0x80000002           ;   calls from 0x80000002 to 0x80000004 ->
        mov edi, Brand                ;-> return brand name, works in the same ->
.GatherBrand:                         ;-> way as the code after '_main' label. 
        push eax                      
        push edi                     
        cpuid
        pop edi
        mov [edi], eax
        add edi, 4
        mov [edi], ebx
        add edi, 4
        mov [edi], ecx
        add edi, 4
        mov [edi], edx
        add edi, 4
        pop eax
        inc eax
        cmp eax, 0x80000004
        jle .GatherBrand

        push 0                        ; show message box with brand
        push BrandCap                 ; -//-
        push Brand                    ; -//-
        push 0                        ; -//-
        call _MessageBoxA@16          ; -//-
        
        push 0
        call _ExitProcess@4


        ;---------------------------------------------------------------
        ; GenPlcHldStr: generate placeholder for CPUID results
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (dword) - address where results will be stored
        ;
        ; Output:
        ; Placeholder string in "REG=xxxxxxxx" format with new line
        ; (carriage return + line feed) after each register
        ;
        ; Registers:
        ; This procedure changes state of EAX, ECX, EDI, EBP, ESP
        ;---------------------------------------------------------------
        
GenPlcHldStr:
        push ebp
        mov ebp, esp
        mov edi, [ebp + 8]            ; take argument (address)
        mov dword eax, "EAX="         ; register name (item)
        mov ecx, 3                    ; items counter, 4 loops (3>=0) - 4 registers
.items:
        mov [edi], eax                ; place item
        add edi, 4                    ; advance pointer
        push ecx                      ; save items counter
        mov ecx, 7                    ; digits counter, 8 loops (7>=0) - 8 chars
.digits:
        mov byte [edi], "x"           ; place 'x' for future digit
        add edi, 1                    ; advance pointer
        dec ecx                       ; decrement digits counter
        cmp ecx, 0                    ; check whether loop is finished
        jge .digits                   ; jump, if isn't
        
        mov word [edi], 0x0d0a        ; carriage return + line feed
        add edi, 2                    ; advance pointer
        add eax, 0x00000100           ; change middle letter
        pop ecx                       ; retrieve items counter
        dec ecx                       ; decrement items counter
        cmp ecx, 0                    ; check whether loop is finished
        jge .items                    ; jump, if isn't
        mov byte [edi], 0             ; null-termination
        
        pop ebp                       ; restore base pointer from stack back
        ret 4                         ; return from procedure freeing 4 bytes (arguments length) from stack
        

        ;---------------------------------------------------------------
        ; DwordToStrHex: converts 8 nybbles to 8 hexadecimal characters
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (dword) - 32-bit number to be converted
        ; 2. (dword) - address where results will be stored
        ;
        ; Output:
        ; Four ASCII characters string, representing hexadecimal number
        ;
        ; Registers:
        ; This procedure changes state of EAX, EBX, EDX, EDI, EBP, ESP
        ;---------------------------------------------------------------

DwordToStrHex:
        push ebp                      ; push in the stack address in base pointer
        mov ebp, esp                  ; base pointer now points to head of the stack
        mov edi, [ebp + 8]            ; take second argument (address)
        mov ebx, [ebp + 12]           ; take first argument (number)
        xor eax, eax                  ; EAX is zeroed
        mov ecx, 7                    ; counter, 8 loops (7>=0) - 8 chars
.next:
        mov al, bl                    ; load first 8 bits
        and al, 0Fh                   ; select only lower 4 bits (higher half of AL is zeroed)
        add ax, 48                    ; add ASCII table offset to make number char code (0-9 -> 48-57)
        cmp ax, 58                    ; check for overflow
        jl .store                     ; store char if less than 58
        add ax, 7                     ; add another offset for A-F digits (10-15 -> 65-70)
.store:
        mov [edi + ecx], al           ; write converted number (flow from right to left)
        shr ebx, 4                    ; shift next nybble into lower position
        dec ecx                       ; decrement counter
        cmp ecx, 0                    ; compare with zero
        jge .next                     ; if it is greater than or equals to zero, continue conversion

        pop ebp                       ; restore base pointer from stack back
        ret 8                         ; return from procedure freeing 8 bytes (arguments length) from stack


        ;---------------------------------------------------------------
        ; CpuIdToStr: invokes CPUID and returns string with EAX-EDX
        ; contents
        ;---------------------------------------------------------------
        ; Input:
        ; 1. (dword) - CPUID code
        ; 2. (dword) - address, where results will be stored
        ;
        ; Output:
        ; String in "REG=xxxxxxxx" format with each register on new
        ; line (carriage return + line feed)
        ;
        ; Registers:
        ; This procedure changes state of EAX, EBX, EDX, EDI, EBP, ESP
        ;---------------------------------------------------------------

CpuIdToStr:
        push ebp                      ; push in the stack address in base pointer
        mov ebp, esp                  ; base pointer now points to head of the stack
        mov eax, [ebp + 12]           ; take first argument (code)
        cpuid                         ; call CPUID with code in EAX
        push edx                      ; save results
        push ecx                      ; -//-
        push ebx                      ; -//-
        push eax                      ; -//-

        mov edi, [ebp + 8]            ; take second argument (address)
        push edi                      ; generate placeholder
        call GenPlcHldStr             ; -//-
        mov edi, [ebp + 8]            ; take second argument again (address)
        add edi, 4                    ; add offset in registers string
        mov ecx, 2                    ; counter (2<=5), 4 loops - 4 registers
.next:
        push edi                      ; save pointer
        push ecx                      ; save counter
        push dword [esp + 4 * ecx]    ; number to be converted
        push edi                      ; pointer to char after register label
        call DwordToStrHex            ; convert register contents to string
        pop ecx                       ; retrieve values back
        pop edi                       ; -//-
        add edi, 14                   ; add name + value + \n\r in bytes offset
        inc ecx                       ; increment counter
        cmp ecx, 5                    ; check whether loop is finished
        jle .next                     ; jump, if isn't

        pop eax                       ; clear stack from CPUID results
        pop ebx                       ; -//-
        pop ecx                       ; -//-
        pop edx                       ; -//-
        pop ebp                       ; restore base pointer from stack back
        ret 8                         ; return from procedure freeing 8 bytes (arguments length) from stack
