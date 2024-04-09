section .data
    prompt db "Enter operation (+, -, *, /): ", 0
    num1_prompt db "Enter first number: ", 0
    num2_prompt db "Enter second number: ", 0
    result_msg db "Result: ", 0
    newline db 0xA, 0

section .bss
    num1 resb 10
    num2 resb 10
    result resb 10

section .text
    global _start

_start:
    ; Display prompt for operation
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, prompt
    mov edx, 27           ; length of prompt
    int 0x80

    ; Read operation from user
    mov eax, 3            ; sys_read
    mov ebx, 0            ; stdin
    mov ecx, prompt
    mov edx, 2            ; read 2 bytes (operation and newline)
    int 0x80

    ; Read first number from user
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, num1_prompt
    mov edx, 17           ; length of num1_prompt
    int 0x80

    mov eax, 3            ; sys_read
    mov ebx, 0            ; stdin
    mov ecx, num1
    mov edx, 10           ; maximum input length
    int 0x80

    ; Read second number from user
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, num2_prompt
    mov edx, 18           ; length of num2_prompt
    int 0x80

    mov eax, 3            ; sys_read
    mov ebx, 0            ; stdin
    mov ecx, num2
    mov edx, 10           ; maximum input length
    int 0x80

    ; Convert ASCII input to integers
    mov ebx, num1
    call atoi

    mov ebx, num2
    call atoi

    ; Perform the selected operation
    mov eax, dword [num1]
    cmp byte [prompt], '+'
    je add_numbers
    cmp byte [prompt], '-'
    je subtract_numbers
    cmp byte [prompt], '*'
    je multiply_numbers
    cmp byte [prompt], '/'
    je divide_numbers

    ; Invalid operation
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp exit_program

add_numbers:
    add eax, dword [num2]
    jmp display_result

subtract_numbers:
    sub eax, dword [num2]
    jmp display_result

multiply_numbers:
    imul eax, dword [num2]
    jmp display_result

divide_numbers:
    cmp dword [num2], 0
    je division_by_zero
    mov ebx, dword [num2]
    cdq                   ; sign extend eax into edx
    idiv ebx              ; edx:eax / ebx, quotient in eax, remainder in edx

display_result:
    ; Display the result
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, result_msg
    mov edx, 8            ; length of result_msg
    int 0x80

    ; Convert the result to ASCII and print
    mov eax, dword [eax]
    call itoa
    mov eax, result
    call print_string

exit_program:
    ; Exit the program
    mov eax, 1            ; sys_exit
    xor ebx, ebx          ; exit status 0
    int 0x80

atoi:
    ; Convert ASCII string to integer in ebx
    xor eax, eax          ; result
.next_digit:
    movzx edx, byte [ebx]
    test dl, dl           ; end of string?
    jz .done
    sub dl, '0'           ; convert ASCII to binary
    imul eax, eax, 10     ; multiply result by 10
    add eax, edx          ; add next digit
    inc ebx
    jmp .next_digit
.done:
    ret

itoa:
    ; Convert integer in eax to ASCII string in result
    mov ecx, 10           ; divisor
    mov edi, result       ; destination
    xor edx, edx          ; clear remainder
.next_digit:
    xor eax, eax          ; clear upper bits
    div ecx               ; divide eax by 10
    add dl, '0'           ; convert remainder to ASCII
    dec edi               ; move to next character
    mov [edi], dl         ; store ASCII character
    test eax, eax         ; quotient zero?
    jnz .next_digit       ; if not, continue
    ret

print_string:
    ; Print null-terminated string pointed to by eax
    mov ebx, eax          ; pointer to string
    xor eax, eax          ; syscall number
    .loop:
    lodsb                 ; load byte at esi into al, and increment esi
    test al, al           ; is it zero?
    jz .done              ; if yes, we're done
    mov ecx, eax          ; set up for write
    mov edx, 1            ; we're only writing one byte
    mov eax, 4            ; syscall number for sys_write
    int 0x80              ; make kernel call
    jmp .loop             ; rinse and repeat
    .done:
    ret

division_by_zero:
    ; Handle division by zero error
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, error_msg
    mov edx, 16           ; length of error_msg
    int 0x80

    jmp exit_program

section .data
    error_msg db "Error: Division by zero", 0
