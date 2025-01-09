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
    global _main
    extern _printf
    extern _pthread_create
    extern _pthread_join
    extern _exit

thread_function:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    ; Print message with thread number
    mov     rsi, rdi        ; Thread number is passed directly
    lea     rdi, [rel message]
    xor     eax, eax
    call    _printf

    add     rsp, 16
    pop     rbp
    xor     rax, rax
    ret

_main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32         ; Align stack

    ; Save callee-saved registers we'll use
    push    rbx
    push    r12

    ; Print start message
    lea     rdi, [rel start_msg]
    xor     eax, eax
    call    _printf

    ; Initialize
    xor     rbx, rbx        ; Thread counter
    lea     r12, [rel thread_ids]   ; Base of thread_ids array

create_threads:
    ; Create thread
    lea     rdi, [r12 + rbx * 8]  ; Where to store thread ID
    xor     rsi, rsi              ; No attributes
    lea     rdx, [rel thread_function]
    mov     rcx, rbx              ; Pass thread number directly
    call    _pthread_create

    ; Print creation message
    lea     rdi, [rel create_msg]
    mov     rsi, rbx
    xor     eax, eax
    call    _printf

    inc     rbx
    cmp     rbx, thread_count
    jl      create_threads

    ; Join all threads
    xor     rbx, rbx

join_threads:
    ; Join thread
    mov     rdi, [r12 + rbx * 8]  ; Get thread ID
    xor     rsi, rsi              ; No return value
    call    _pthread_join

    ; Print join message
    lea     rdi, [rel join_msg]
    mov     rsi, rbx
    xor     eax, eax
    call    _printf

    inc     rbx
    cmp     rbx, thread_count
    jl      join_threads

    ; Print exit message
    lea     rdi, [rel exit_msg]
    xor     eax, eax
    call    _printf

    ; Restore registers and clean up
    pop     r12
    pop     rbx

    ; Exit properly on macOS
    xor     rdi, rdi        ; Exit code 0
    call    _exit           ; Call exit function
