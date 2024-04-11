section .data
    board db 3 dup (3 dup (' '))   ; 3x3 game board

section .text
    global _start

_start:
    call print_board
    ; Your game logic goes here

print_board:
    mov esi, board         ; Load address of the board
    mov ecx, 3             ; Outer loop counter (rows)

outer_loop:
    mov edi, esi           ; Copy board address for inner loop
    mov ecx, 3             ; Inner loop counter (columns)

inner_loop:
    mov al, [edi]          ; Load current cell value
    movzx eax, al          ; Zero extend to 32-bit for syscall
    cmp al, ' '            ; Check if cell is empty
    je empty_cell          ; Jump if empty
    ; Print current cell value
    mov eax, 4             ; Syscall number for sys_write
    mov ebx, 1             ; File descriptor 1 (stdout)
    mov ecx, edi           ; Address of current cell
    mov edx, 1             ; Number of bytes to write
    int 0x80               ; Call kernel

empty_cell:
    inc edi                ; Move to next cell
    loop inner_loop        ; Repeat inner loop

    ; Move to next row
    add esi, 3             ; Move to next row
    loop outer_loop        ; Repeat outer loop

    ; Print newline
    mov eax, 4             ; Syscall number for sys_write
    mov ebx, 1             ; File descriptor 1 (stdout)
    mov ecx, newline       ; Address of newline
    mov edx, 1             ; Number of bytes to write
    int 0x80               ; Call kernel

    ret

section .data
    newline db 0x0A        ; Newline character
