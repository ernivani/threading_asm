default rel

section .data
    message: db 'Hello from thread %d!', 0xA, 0
    start_msg: db 'Starting program...', 0xA, 0
    create_msg: db 'Created thread %d', 0xA, 0
    join_msg: db 'Joined thread %d', 0xA, 0
    exit_msg: db 'Program exiting...', 0xA, 0
    thread_count equ 4

section .bss
    align 8
    thread_ids: resq thread_count

section .text
%ifdef __LINUX__
    global main
    extern printf
    extern pthread_create
    extern pthread_join
    extern exit
%else
    global _main
    extern _printf
    extern _pthread_create
    extern _pthread_join
    extern _exit
%endif

thread_function:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16
    
    ; Save the thread number (passed in rdi) before we overwrite it
    push    rdi

    ; Print message with thread number
%ifdef __LINUX__
    lea     rdi, [rel message]
    pop     rsi             ; Restore thread number as second argument
    call    printf
%else
    pop     rsi             ; Restore thread number as second argument
    lea     rdi, [rel message]
    xor     eax, eax
    call    _printf
%endif

    add     rsp, 16
    pop     rbp
    xor     rax, rax
    ret

%ifdef __LINUX__
main:
%else
_main:
%endif
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32         ; Align stack

    ; Save callee-saved registers we'll use
    push    rbx
    push    r12

    ; Print start message
    lea     rdi, [rel start_msg]
    xor     eax, eax
%ifdef __LINUX__
    call    printf
%else
    call    _printf
%endif

    ; Initialize
    xor     rbx, rbx        ; Thread counter
    lea     r12, [rel thread_ids]   ; Base of thread_ids array

create_threads:
    ; Create thread
    lea     rdi, [r12 + rbx * 8]  ; Where to store thread ID
    xor     rsi, rsi              ; No attributes
    lea     rdx, [rel thread_function]
    mov     rcx, rbx              ; Pass thread number directly
%ifdef __LINUX__
    call    pthread_create
%else
    call    _pthread_create
%endif

    ; Print creation message
    lea     rdi, [rel create_msg]
    mov     rsi, rbx
    xor     eax, eax
%ifdef __LINUX__
    call    printf
%else
    call    _printf
%endif

    inc     rbx
    cmp     rbx, thread_count
    jl      create_threads

    ; Join all threads
    xor     rbx, rbx

join_threads:
    ; Join thread
    mov     rdi, [r12 + rbx * 8]  ; Get thread ID
    xor     rsi, rsi              ; No return value
%ifdef __LINUX__
    call    pthread_join
%else
    call    _pthread_join
%endif

    ; Print join message
    lea     rdi, [rel join_msg]
    mov     rsi, rbx
    xor     eax, eax
%ifdef __LINUX__
    call    printf
%else
    call    _printf
%endif

    inc     rbx
    cmp     rbx, thread_count
    jl      join_threads

    ; Print exit message
    lea     rdi, [rel exit_msg]
    xor     eax, eax
%ifdef __LINUX__
    call    printf
%else
    call    _printf
%endif

    ; Restore registers and clean up
    pop     r12
    pop     rbx

    ; Exit properly
    xor     rdi, rdi        ; Exit code 0
%ifdef __LINUX__
    call    exit
%else
    call    _exit
%endif
