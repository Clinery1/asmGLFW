global myPrint
global myEprint
global exitOne
global exitZero


section .text
myPrint:
    mov rax,1
    mov rdx,rsi
    mov rsi,rdi
    mov rdi,1
    syscall
    ret
myEprint:
    mov rsi,rdx
    mov rdi,rsi
    mov rdi,2
    mov rax,1
    syscall
    ret
exitOne:
    mov rax,60
    mov rdi,-1
    syscall
exitZero:
    mov rax,60
    mov rdi,0
    syscall
exit:
    mov rax,60
    syscall

; IN: rdi:address
createMutex:
    mov byte[rdi],0
    ret

; IN: rdi:address
getMutexDataWritable:
    call lockMutex
    cmp rax,0
    jne .return
    mov rax,rdi
    add rax,1
    .return:
    ret

; IN: rdi:address
getMutexDataReadable:
    sub rax,[rdi]
    ret

; IN: rdi:address
lockMutex:
    cmp byte[rdi],0
    jne locked
    mov byte[rdi],1
    mov rax,0
    ret

locked:
    mov rax,-1
    ret
