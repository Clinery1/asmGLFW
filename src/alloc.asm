; Definitions of what happens. Used for the `prot` and `flags` variables in the mmap syscall

%define PROT_READ       0x1     ; Page can be read.
%define PROT_WRITE      0x2     ; Page can be written.
%define PROT_EXEC       0x4     ; Page can be executed.
%define PROT_NONE       0x0     ; Page can not be accessed.
%define MAP_PRIVATE     0x02    ; Other programs CAN'T read this memory
%define MAP_SHARED      0x01    ; Other programs CAN read this memory
%define MAP_ANONYMOUS   0x20    ; Dont use a file
%define MEM_MAP         9       ; The syscall number for mmap
%define MEM_UNMAP       11      ; The syscall number for munmap
%define MEM_REMAP       25      ; The syscall number for mremap


global myAlloc
global myAlloc_executable
global myFree


section .text

;;;;;;;;;;;;;;;;;;;;;;;;
; MEMORY ALLOC/DEALLOC ;
;;;;;;;;;;;;;;;;;;;;;;;;

; IN:   byte amount:rax,address:rbx
; OUT:  address or error code:rax
myAlloc:
    mov rcx,rbx
    push rbx
    xor rbx,rbx
    call __alloc
    pop rbx
    ret
; IN:   byte amount:rax,address:rbx
; OUT:  address or error code:rax
myAlloc_executable:
    mov rcx,rbx
    push rbx
    mov rbx,3
    call __alloc
    pop rbx
    ret
; IN:   byte amount:rax,my flags:rbx,address:rcx
; my flags: 0x3:executable
; OUT:  address or error code:rax
; if executable, !writable; if no address is to be supplied, rcx should be zero
__alloc:
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    xor rdx,rdx
    and rbx,3
    shr rbx,1
    or rdx,PROT_READ|PROT_WRITE
    xor rdx,rbx  ; Sets PROT_EXE and removes PROT_WRITE if rbx is 3
    xor r8,r8
    xor r9,r9
    mov rsi,rax
    mov rdi,rcx
    mov r10,0x22    ; MAP_PRIVATE|MAP_ANONYMOUS
    mov rax,9
    syscall         ; this calls the function to allocate the memory, after this instruction we have the pointer in rax
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    ret
; IN:   amount:rax,address:rbx
; OUT:  error code:rax
myFree:
    push rdi
    push rsi
    mov rsi,rax
    mov rdi,rbx
    mov rax,11
    syscall
    pop rsi
    pop rdi
    ret


;;;;;;;;;;;;;;;;;;;;;;;
; MEMORY REMAP/CHANGE ;
;;;;;;;;;;;;;;;;;;;;;;;

; IN:   addr:rax,old_len:rbx,new_len:rcx
; OUT:  error code:rax
; Error codes: -1: new_len<=old_len please use mem_shrink to shrink memory
mem_extend:
    cmp rbx,rcx
    jle return
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    mov rdi,rax     ; set the old_address
    mov rsi,rbx     ; set the old_len
    mov rdx,rcx     ; set the new_len
    mov r10,0x22    ; set the flags (same as before)
    mov r8,rdi      ; set the new_address (same as old_address)
    syscall
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    xor rax,rax
    ret
; IN:   addr:rax,old_len:rbx,new_len:rcx
; OUT:  error code:rax
; Error codes: -1: new_len>=old_len please use mem_extend to extend memory
mem_shrink:
    cmp rbx,rcx
    jge return
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    mov rdi,rax     ; set the old_address
    mov rsi,rbx     ; set the old_len
    mov rdx,rcx     ; set the new_len
    mov r10,0x22    ; set the flags (same as before)
    mov r8,rdi      ; set the new_address (same as old_address)
    syscall
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    xor rax,rax
    ret
; IN:   addr:rax,len:rbx,executable(3):rcx
; If executable then rcx should be 3 otherwise, rcx=0
mem_set_executable:
    push rdx
    push rdi
    push rsi
    mov rdi,rax
    mov rsi,rbx
    mov rdx,PROT_READ|PROT_WRITE
    xor rdx,rcx
    mov rax,10
    syscall
    pop rsi
    pop rdi
    pop rdx
    ret

; Helper function, returns rax=-1
return:
    mov rax,-1
    ret
