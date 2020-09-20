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
    mov rdi,1
    syscall
exitZero:
    mov rax,60
    mov rdi,0
    syscall
exit:
    mov rax,60
    syscall
