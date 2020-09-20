; What is in this file:
;   the function `loadShader` is contained in this file, this function reads the vertex and fragment shaders
;   from their respective files, compiles them, links them, and returns the program ID
;
; What is the pseudocode function for `loadShader`:
;   loadShader()->programID(rax)



global  myLoadShader


; GL imports
extern  glCreateShader
extern  glCreateProgram
extern  glShaderSource
extern  glCompileShader
extern  glGetShaderiv
extern  glGetProgramiv
extern  glGetShaderInfoLog
extern  glGetProgramInfoLog
extern  glAttachShader
extern  glLinkProgram
extern  glDetachShader
extern  glDeleteShader

; other imports
extern  myAlloc
extern  myFree
extern  myPrint
extern  exitOne
extern  _start.exit


; GL defines
%define GL_FRAGMENT_SHADER 0x8b30
%define GL_VERTEX_SHADER 0x8b31
%define GL_COMPILE_STATUS 0x8b81
%define GL_LINK_STATUS 0x8b82
%define GL_INFO_LOG_LENGTH 0x8b84
%define GL_FALSE 0
%define GL_TRUE 1


section .data
; fragment things
fragReadError:db "Could not read fragment shader",10
fragReadErrorLen:equ $-fragReadError
compileFrag:db "Compiling frag shader",10
compileFragLen:equ $-compileFrag
fragShaderFilename:db "fragment.glsl",0
fragFileNotFoundMsg:db "File `fragment.glsl` is not found",10
fragFileNotFoundMsgLen:equ $-fragFileNotFoundMsg

; vertex things
vertReadError:db "Could not read vertex shader",10
vertReadErrorLen:equ $-vertReadError
compileVert:db "Compiling vertex shader",10
compileVertLen:equ $-compileVert
vertShaderFilename:db "vertex.glsl",0
vertFileNotFoundMsg:db "File `vertex.glsl` is not found",10
vertFileNotFoundMsgLen:equ $-vertFileNotFoundMsg

; other stuff
openMode:db "r",0
allocErrorText:db "Memory allocation error",10
allocErrorTextLen:equ $-allocErrorText
linkText:db "Linking the program",10
linkTextLen:equ $-linkText

section .bss
; fragment things
fragSrcPtrPtr:resq 1
fragSrcPtr:resq 1
fragSize:resq 1
fragID:resq 1

; vertex things
vertSrcPtrPtr:resq 1
vertSrcPtr:resq 1
vertSize:resq 1
vertID:resq 1

; other things
programID:resq 1
statbuf:resq 32
result:resq 1
infoLogLength:resq 1
infoLogPtr:resq 1


section .text
; function(rdi,rsi,rdx,rcx,r8,r9)->rax   other args go to the stack in reverse order
; functions return in rax


myLoadShader:
    ; move the pointer to the pointer to the shader code into [(SHADER_TYPE)SrcPtrPtr]
    mov rdi,fragSrcPtr
    mov [rel fragSrcPtrPtr],rdi
    mov rdi,vertSrcPtr
    mov [rel vertSrcPtrPtr],rdi
    ; create the IDs of the shaders
    mov rdi,GL_VERTEX_SHADER
    call glCreateShader wrt ..plt
    mov [rel vertID],rax
    mov rdi,GL_FRAGMENT_SHADER
    call glCreateShader wrt ..plt
    mov [rel fragID],rax
    ; read the files and store them in memory for compilation
    call readVert
    call readFrag
    ; compile the fragment shader
    call compileAndCheckVert
    ; now onto the fragment shader
    call compileAndCheckFrag
    ; now we link the programs
    call linkProgram
    ; finally, do some other stuff before cleanup
    mov rdi,[rel programID]
    mov rsi,[rel vertID]
    call glDetachShader wrt ..plt
    mov rdi,[rel programID]
    mov rsi,[rel fragID]
    call glDetachShader wrt ..plt
    mov rdi,[rel vertID]
    call glDeleteShader wrt ..plt
    mov rdi,[rel fragID]
    call glDeleteShader wrt ..plt
    ; we are finished loading so free the shader buffers
    mov rax,[rel fragSrcPtr]
    mov rax,[rel fragSize]
    call myFree wrt ..plt
    mov rax,[rel vertSrcPtr]
    mov rax,[rel vertSize]
    call myFree wrt ..plt
    mov qword[rel vertSrcPtr],0
    mov qword[rel fragSrcPtr],0
    mov rax,[rel programID]
    ret

allocError:
    mov rdi,allocErrorText
    mov rsi,allocErrorTextLen
    call myPrint wrt ..plt
    jmp _start.exit wrt ..plt

vertFileNotFound:
    mov rdi,vertFileNotFoundMsg
    mov rsi,vertFileNotFoundMsgLen
    call myPrint wrt ..plt
    jmp _start.exit wrt ..plt
fragFileNotFound:
    mov rdi,fragFileNotFoundMsg
    mov rsi,fragFileNotFoundMsgLen
    call myPrint wrt ..plt
    jmp _start.exit wrt ..plt

linkProgram:
    mov rdi,linkText
    mov rsi,linkTextLen
    call myPrint wrt ..plt
    call glCreateProgram wrt ..plt
    mov [rel programID],rax
    mov rdi,[rel programID]
    mov rsi,[rel vertID]
    call glAttachShader wrt ..plt
    mov rdi,[rel programID]
    mov rsi,[rel fragID]
    call glAttachShader wrt ..plt
    mov rdi,[rel programID]
    call glLinkProgram wrt ..plt
    ; final check here
    mov rdi,[rel programID]
    mov rsi,GL_LINK_STATUS
    mov rdx,result
    call glGetProgramiv wrt ..plt
    mov rdi,[rel programID]
    mov rsi,GL_INFO_LOG_LENGTH
    mov rdx,infoLogLength
    call glGetProgramiv wrt ..plt
    mov [rel infoLogLength],rax
    cmp qword[rel infoLogLength],0
    je .continue
    .error:
        mov rdi,[rel infoLogLength]
        add rdi,1
        mov rsi,0
        call myAlloc wrt ..plt
        cmp rax,-1
        je allocError
        mov [rel infoLogPtr],rax
        mov rdi,[rel programID]
        mov rsi,[rel infoLogLength]
        mov rdx,0
        mov rcx,[rel infoLogPtr]
        call glGetProgramInfoLog wrt ..plt
        mov rdi,[rel infoLogPtr]
        mov rsi,[rel infoLogLength]
        call myPrint wrt ..plt
        jmp _start.exit wrt ..plt
        ; no more code in this block
    .continue:
    ret

compileAndCheckVert:
    mov rdi,compileVert
    mov rsi,compileVertLen
    call myPrint wrt ..plt
    mov rdi,[rel vertID]
    mov rsi,1
    mov rdx,[rel vertSrcPtrPtr]
    mov rcx,0
    ; segfault from the next place
    call glShaderSource wrt ..plt
    mov rdi,[rel vertID]
    call glCompileShader wrt ..plt
    ; we now check the vertex shader.
    mov rdi,[rel vertID]
    mov rsi,GL_COMPILE_STATUS
    mov rdx,result
    call glGetShaderiv wrt ..plt
    mov rdi,[rel vertID]
    mov rsi,GL_INFO_LOG_LENGTH
    mov rdx,infoLogLength
    call glGetShaderiv wrt ..plt
    mov [rel infoLogLength],rax
    cmp qword[rel infoLogLength],0
    je .continue
    .error:
        mov rdi,[rel infoLogLength]
        add rdi,1
        mov rsi,0
        call myAlloc wrt ..plt
        cmp rax,-1
        je allocError
        mov [rel infoLogPtr],rax
        mov rdi,[rel vertID]
        mov rsi,[rel infoLogLength]
        mov rdx,0
        mov rcx,[rel infoLogPtr]
        call glGetShaderInfoLog wrt ..plt
        mov rdi,[rel infoLogPtr]
        mov rsi,[rel infoLogLength]
        call myPrint wrt ..plt
        jmp _start.exit wrt ..plt
        ; no more code in this block
    .continue:
    ret

compileAndCheckFrag:
    mov rdi,compileFrag
    mov rsi,compileFragLen
    call myPrint wrt ..plt
    mov rdi,[rel fragID]
    mov rsi,1
    mov rdx,[rel fragSrcPtrPtr] ; this needs a pointer to a pointer for some reason... if you just give a pointer to the text then it segfaults
    mov rcx,0
    call glShaderSource wrt ..plt
    mov rdi,[rel fragID]
    call glCompileShader wrt ..plt
    ; we now check the vertex shader.
    mov rdi,[rel fragID]
    mov rsi,GL_COMPILE_STATUS
    mov rdx,result
    call glGetShaderiv wrt ..plt
    mov rdi,[rel fragID]
    mov rsi,GL_INFO_LOG_LENGTH
    mov rdx,infoLogLength
    call glGetShaderiv wrt ..plt
    mov [rel infoLogLength],rax
    cmp qword[rel infoLogLength],0
    je .continue
    .error:
        mov rdi,[rel infoLogLength]
        add rdi,1
        mov rsi,0
        call myAlloc wrt ..plt
        cmp rax,-1
        je allocError
        mov [rel infoLogPtr],rax
        mov rdi,[rel fragID]
        mov rsi,[rel infoLogLength]
        mov rdx,0
        mov rcx,[rel infoLogPtr]
        call glGetShaderInfoLog wrt ..plt
        mov rdi,[rel infoLogPtr]
        mov rsi,[rel infoLogLength]
        call myPrint wrt ..plt
        jmp _start.exit wrt ..plt
        ; no more code in this block
    .continue:
    ret

readVert:
    ; stack grown DOWN (-) on push and UP (+) on pop
    ; open the file
    mov rax,2
    mov rdi,vertShaderFilename
    mov rsi,0
    mov rdx,openMode
    syscall
    cmp rax,-2
    je vertFileNotFound
    push rax    ; store the FD in the stack, it is still in rax so move the FD to rdi
    ; fstat the file so we can get the size of it
    mov rdi,rax
    mov rax,5
    mov rsi,statbuf
    syscall
    mov rax,[rel statbuf+48]
    add rax,10
    mov [rel vertSize],rax
    mov rbx,0
    call myAlloc wrt ..plt
    cmp rax,-1
    je allocError
    mov [rel vertSrcPtr],rax
    ; read the file
    mov rax,0
    pop rdi
    mov rsi,[rel vertSrcPtr] ; this contains a pointer to the value so it needs to read what is in the value
    mov rdx,[rel statbuf+48]
    syscall
    cmp rax,-1
    je .vertError
    mov rbx,[rel vertSrcPtr]
    mov byte[rbx+rax+1],0
    ret
    .vertError:
    mov rax,1
    mov rdi,1
    mov rsi,vertReadError
    mov rdx,vertReadErrorLen
    syscall
    jmp _start.exit wrt ..plt
    ; we shouldn't be executing code after an exit syscall
readFrag:
    ; stack grown DOWN (-) on push and UP (+) on pop
    mov rax,2
    mov rdi,fragShaderFilename
    mov rsi,0
    mov rdx,openMode
    syscall
    cmp rax,-2
    je fragFileNotFound
    push rax
    mov rdi,rax
    mov rax,5
    mov rsi,statbuf
    syscall
    mov rax,[rel statbuf+48]
    add rax,10
    mov [rel fragSize],rax
    mov rbx,0
    call myAlloc wrt ..plt
    cmp rax,-1
    je allocError
    mov [rel fragSrcPtr],rax
    mov rax,0
    pop rdi
    mov rsi,[rel fragSrcPtr]
    mov rdx,[rel statbuf+48]
    syscall
    cmp rax,-1
    je .fragError
    mov rbx,[rel fragSrcPtr]
    mov byte[rbx+rax+1],0
    ret
    .fragError:
    mov rax,1
    mov rdi,1
    mov rsi,fragReadError
    mov rdx,fragReadErrorLen
    syscall
    jmp _start.exit wrt ..plt
