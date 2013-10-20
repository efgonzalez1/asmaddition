dosseg
.model small
.stack 64h

.data
header db 'Large Number Addition$'
num1_msg db 'Enter the 1st Number: $'
num2_msg db 'Enter the 2nd Number: $'
error_msg db 'ERROR: Numbers must have the same amount of digits (includes leading zeros).',
             '           Press [ESC] to exit   OR   Press any other key to try again.$'
continue db 'Do you want to continue? [Y] / [N]$'
tmp db '0', 15 dup('$')
num1 db '0', 15 dup('$')
num2 db '0', 15 dup('$')
solution db '0', 16 dup('$')
num1_size db 0
num2_size db 0

.code
main proc
    mov ax, @data
    mov ds, ax
    call init_page
    call print_header
    call prompt_num1
    call prompt_num2
    call check_input
    call calculate
    call print_solution
    call prompt_continue
 exit:
    call init_page
    mov ah, 4Ch
    int 21h
main endp

init_page proc
    mov ah, 02h             ;set cursor to row 0, col 0
    mov dx, 0000h
    mov bh, 0
    int 10h
    mov ah, 06h             ;clear screen
    mov al, 0
    mov bh, 07h
    mov cx, 0000h
    mov dh, 24
    mov dl, 79
    int 10h
    ret
init_page endp

print_header proc
    mov ah, 06h
    mov al, 0
    mov bh, (010b shl 4)    ;green background, black text
    mov dh, ch
    mov dl, 80
    int 10h
    mov ah, 02h             ;set cursor to row 0, col 29
    mov dx, 001Dh 			;this way header is centered
    mov bh, 0
    int 10h
    mov ah, 09h
    mov dx, offset header
    int 21h
    ret
print_header endp

prompt_num1 proc
    mov ah, 02h             ;set cursor to row 2, col 0
    mov dx, 0200h
    mov bh, 0
    int 10h
    mov ah, 09h             ;print prompt message
    mov dx, offset num1_msg
    int 21h
    call get_input
    mov bx, offset num1_size
    mov [bx], dx            ;store size in variable for later use
    mov cx, dx              ;store size in counter
    mov si, offset num1
    call swap_tmp
    ret
prompt_num1 endp

prompt_num2 proc
    mov ah, 02h             ;set cursor to row 3, col 0
    mov dx, 0300h
    mov bh, 0
    int 10h
    mov ah, 09h             ;print prompt message
    mov dx, offset num2_msg
    int 21h
    call get_input
    mov bx, offset num2_size
    mov [bx], dx            ;store size in variable for later use
    mov cx, dx              ;store size in counter
    mov si, offset num2
    call swap_tmp
    ret
prompt_num2 endp

get_input proc
    mov bx, offset tmp
    push bx
    mov dx, 0               ;use dx to count how many digits are entered
    push dx                 ;save for later (other instructions overwrite bx)
    input:
        mov ah, 03h
        mov bh, 0
        int 10h
        cmp dl, 37          ;break out when user enters 15 digit num
        je exit_loop
        mov ah, 00h
        int 16h
        cmp al, 0Dh         ;break out on carriage return press
        je exit_loop
        cmp al, 08h
        je backspc
        cmp al, 30h         ;only accept input if in range of ascii integers
        jb input
        cmp al, 39h
        jg input
        mov ah, 02h         ;display what user enters
        mov dl, al
        int 21h
        pop dx
        inc dx              ;increase digit counter
        pop bx
        mov [bx], al        ;save input digit to tmp
        inc bx
        push bx
        push dx             ;save digit counter at top of stack
        loop input
    exit_loop:
        pop dx
        pop bx
        ret
    backspc:
        pop dx
        dec dx              ;decrease digit counter
        pop bx
        dec bx
        mov [bx], '$$'       ;clear entry in memory
        push bx
        push dx             ;save digit counter at top of stack
        call backspace
        jmp input
get_input endp

backspace proc
    back:
        mov ah, 03h             ;get cursor position
        mov bh, 0
        int 10h
        cmp dl, 16h             ;dont erase past prompt
        je exit_back
        mov ah, 06h             ;clear screen from current spot to one space back
        mov al, 0
        mov bh, 07h
        mov cx, dx              ;cursor pos stored in dx
        sub cx, 0001h
        push cx                 ;save new cursor position
        int 10h
        mov ah, 02h             ;set cursor to saved position
        pop dx
        mov bh, 0
        int 10h
    exit_back:
        ret
backspace endp

check_input proc
    mov bx, offset num1_size
    mov si, offset num2_size
    mov ah, [bx]
    mov al, [si]
    cmp ah, al
    je good_input
    error:
        call reset_vars
        mov ah, 06h             ;error will have pink background, white text
        mov al, 0
        mov bh, (101b shl 4) + 1111b
        mov cx, 0500h
        mov dx, 064Fh
        int 10h
        mov ah, 02h             ;set cursor to row 5, col 0
        mov dx, 0500h
        mov bh, 0
        int 10h
        mov ah, 09h
        mov dx, offset error_msg
        int 21h
        mov ah, 00h
        int 16h
        cmp al, 1Bh             ;exit on esc
        je exit
        jmp main                ;press any other key to start over
    good_input:                 ;do nothing
    ret
check_input endp

swap_tmp proc
    ;assume si=offset numX, cx=# digits
    mov bx, offset tmp
    swap:
        mov dx, [bx]
        mov [si], dl
        inc si
        inc bx
    loop swap
    ret
swap_tmp endp

print_solution proc
    mov ah, 06h             ;solution will have red background
    mov al, 0
    mov bh, (100b shl 4) + 1111b
    mov cx, 0500h
    mov dx, 054Fh
    int 10h
    mov ah, 02h             ;set the cursor to row 5, col 0
    mov dx, 0500h
    mov bh, 0
    int 10h
    mov ah, 09h             ;print solution
    mov dx, offset solution
    int 21h
    ret
print_solution endp

calculate proc
    mov bx, offset num1_size
    mov ch, 0
    mov cl, [bx]                ;copy size to counter
    mov bx, offset num1 - 1
    mov si, offset num2 - 1
    add bx, cx                  ;point to last digit in num1
    add si, cx                  ;point to last digit in num2
    add_digits:
        mov ah, 0
        mov al, [bx]
        add al, [si]
        aaa
        or ax, 3030h
        cmp ah, 30h             ;check for no carry, otherwise we assume carry
        je no_carry
        carry:
            ;save result to stack note:high bits ignored when checked later on
            push ax
            ;save current ptr of num1
            push bx
            ;;;mini loop to adjust carry for rest of digits
            more_carry:
                ;digit pointer for num1 one unit to the left
                dec bx
                ;add carry [1]
                mov ah, 0
                mov al, [bx]
                add al, '1'
                aaa
                or ax, 3030h
                ;save al to num1
                mov [bx], al
                ;check if previous carry causes more carry
                ;ie: check if ah is 31h
                cmp ah, 31h
                    ;false: jump to  digit_pointer_reset. ie point to original value before we checked for more carry
                    jne digit_pointer_reset
                    ;true: continue on to check_final_carry

                    check_final_carry:
                        ;cmp bx to offset num1
                        mov dx, offset num1
                        cmp bx, dx
                        ;true: jmp leading_one
                        je leading_one
                        ;jmp mini loop aka more carry
                        jmp more_carry

            digit_pointer_reset:
                ;mov bx, [original ptr position]
                pop bx
                mov dx, offset num1
                cmp bx, dx
                je save_solution
                ;jmp point_to_next_digits
                jmp point_to_next_digits

            point_to_next_digits:
                dec bx
                dec si
                loop add_digits

            leading_one:
                ;mov bx, [original ptr position]
                pop bx
                ;set left most solution digit to 1
                mov di, offset solution
                mov [di], '$1'
                jmp point_to_next_digits

        no_carry:
            push ax             ;save result
            dec bx              ;move num1 digit pointer one unit to the left
            dec si              ;move num2 digit pointer one unit to the left
            loop add_digits

    save_solution:
        mov bx, offset num1_size
        mov ch, 0
        mov cl, [bx]                ;copy size to counter
        mov bx, offset solution + 1 ;point to 2nd digit in case we have leading zero
        check_leading:
            cmp [bx - 1], '$1'
            je copy_digits
            ;;double_check
            ;add leading digits one last time to see if they have a carry
            mov si, offset num1
            mov di, offset num2
            mov ah, 0
            mov al, [si]
            add al, [di]
            aaa
            or ax, 3030h
            cmp ah, 30h         ;remove leading zero when no carry
            je remove_lead_zero
            ;set left most solution digit to 1
            mov si, offset solution
            mov [si], '$1'
            jmp copy_digits
        remove_lead_zero:
            dec bx
            mov [bx], '$$'
        copy_digits:
            ;pop digit results and load to solution label in memory
            pop ax
            mov [bx], al
            inc bx
            loop copy_digits
    ret
calculate endp

reset_vars proc
    mov cx, 14              ;set counter
    mov bx, offset tmp
    reset_tmp:
        mov [bx], '$$'
        inc bx
        loop reset_tmp
    mov cx, 14              ;set counter
    mov bx, offset num1
    reset_num1:
        mov [bx], '$$'
        inc bx
        loop reset_num1
    mov cx, 14              ;set counter
    mov bx, offset num2
    reset_num2:
        mov [bx], '$$'
        inc bx
        loop reset_num2
    mov cx, 14              ;set counter
    mov bx, offset solution
    mov [bx], '0'
    inc bx
    reset_solution:
        mov [bx], '$$'
        inc bx
        loop reset_solution
    ret
reset_vars endp

prompt_continue proc
    call reset_vars
    mov ah, 02h             ;set cursor to row 7, col 0
    mov dx, 0700h
    mov bh, 0
    int 10h
    mov ah, 09h             ;print prompt message
    mov dx, offset continue
    int 21h
    mov ah, 00h
    int 16h
    cmp al, 59h             ;Check if 'Y' pressed
    je main
    cmp al, 79h             ;Check if 'y' pressed
    je main
    cmp al, 4Eh             ;Check if 'N' pressed
    je exit
    cmp al, 6Eh             ;Check if 'n' pressed
    je exit
    cmp al, 1Bh             ;esc in hex (ah 0 stores it in al)
    je exit
    jmp prompt_continue
    ret
prompt_continue endp

end main
