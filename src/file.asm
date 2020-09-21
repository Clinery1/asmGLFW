global  openFile
global  statFile
global  readFile
global  fileSize
global  closeFile
global  writeFile
global  createFile


section .bss
statbuf:resb 150


section .text
; IN: rdi: fileName,rsi:mode
; fileName: a string of characters terminated by a zero;mode: a 32bit number specifying the mode e.g. 0775o for RWX-RWX-R-X
createFile:
    mov rax,85
    syscall
    ret


; IN: rdi: fileName,rsi:openMode
; fileName: a string of characters terminated by a zero;openMode: the r/w/x permissions you want to open the file with, does not mean you get these permissions though
openFile:
    mov rax,2
    mov rdx,rsi
    mov rsi,0
    syscall
    ret

; IN: rdi: fileDescriptor
closeFile:
    mov rax,3
    syscall
    ret

; IN: rdi: fileDescriptor, rsi: statBuf*
; fileDescriptor: the value returned by openFile; statBuf*: the pointer to a statbuf, this needs to be at least
;   144 bytes in size
; ERRORS: Whatever the statbuf syscall returns
statFile:
    mov rax,5
    syscall
    ret

; IN:  rdi: fileDescriptor
; ERRORS: Whatever the statbuf syscall returns
fileSize:
    mov rsi,statbuf
    call statFile
    cmp rax,0
    jge .continue
    ret
    .continue:
    mov rax,[rel statbuf+48]
    ret

; IN: rdi: fileDescriptor, rsi: readBuffer*, rdx: amt
; readBuffer*: a buffer to contain the read data, has to be amt length; amt: how many bytes to read
readFile:
    mov rax,0
    syscall
    ret
writeFile:
    mov rax,1
    syscall
    ret
