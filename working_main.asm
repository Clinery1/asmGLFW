global  _start


; GLFW imports
extern  glfwInit
extern  glfwWindowHint
extern  glfwCreateWindow
extern  glfwMakeContextCurrent
extern  glfwSetInputMode
extern  glfwTerminate
extern  glfwSwapBuffers
extern  glfwPollEvents
extern  glfwGetKey
extern  glfwWindowShouldClose

; openGL imports
extern  glClearColor
extern  glGenVertexArrays
extern  glBindVertexArray
extern  glGenBuffers
extern  glBindBuffer
extern  glClear
extern  glUseProgram
extern  glEnableVertexAttribArray
extern  glBindBuffer
extern  glVertexAttribPointer
extern  glDrawArrays
extern  glDisableVertexAttribArray
extern  glDeleteBuffers
extern  glDeleteVertexArrays
extern  glDeleteProgram
extern  glBufferData

; GLEW imports
extern  glewExperimental
extern  glewInit

; my imports
extern  myPrint
extern  myEprint
extern  exitZero
extern  exitOne


; GLFW defines
%define GLFW_SAMPLES                0x0002100D
%define GLFW_CONTEXT_VERSION_MAJOR  0x00022002
%define GLFW_CONTEXT_VERSION_MINOR  0x00022003
%define GLFW_OPENGL_FORWARD_COMPAT  0x00022006
%define GLFW_OPENGL_PROFILE         0x00022008
%define GLFW_OPENGL_CORE_PROFILE    0x00032001
%define GLFW_STICKY_KEYS            0x00033002
%define GLFW_KEY_ESCAPE             256
%define GLFW_PRESS                  1

; openGL defines
%define GL_COLOR_BUFFER_BIT 0x00004000
%define GL_TRIANGLES        0x0004
%define GL_ARRAY_BUFFER     0x8892
%define GL_STATIC_DRAW      0x88e4
%define GL_FLOAT            0x1406
%define GL_TRUE             1
%define GL_FALSE            0

; GLEW defines
%define GLEW_OK     0

; other defines
%define NULL    0
%define true    1
%define false   0


section .data
width:equ 1024
height:equ 768
windowName:db "My ASM window",0
exitMessage:db "Closing now",10
exitMessageLen:equ $-exitMessage
initError:db "Failed to initialize GLFW",10
initErrorLen:equ $-initError
windowError:db "Failed to create the window",10
windowErrorLen:equ $-windowError
glewInitError:db "Failed to initialize GLEW",10
glewInitErrorLen:equ $-glewInitError
pFourF:dd 0.4
zeroF:dd 0.0
staticVertexBufferData:dd -1.0,1.0,0.0,  1.0,-1.0,0.0,  0.0,1.0,0.0
staticVertexBufferDataLen:equ $-staticVertexBufferData

section .bss
window:resq 1
vertexArrayID:resq 1
programID:resq 1
vertexBuffer:resq 1


section .text
; function(rdi,rsi,rdx,rcx,r8,r9)->rax   other args go to the stack in reverse order
; functions return in rax
_start:
    mov byte[rel glewExperimental],true
    call glfwInit wrt ..plt
    cmp rax,false
    je .initError
    mov rdi,GLFW_SAMPLES
    mov rsi,4
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_CONTEXT_VERSION_MAJOR
    mov rsi,3
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_CONTEXT_VERSION_MINOR
    mov rsi,3
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_OPENGL_FORWARD_COMPAT
    mov rsi,GL_TRUE
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_OPENGL_PROFILE
    mov rsi,GLFW_OPENGL_CORE_PROFILE
    call glfwWindowHint wrt ..plt
    mov rdi,1024
    mov rsi,768
    mov rdx,windowName
    mov rcx,NULL
    mov r8,NULL
    call glfwCreateWindow wrt ..plt
    mov [rel window],rax
    cmp qword[rel window],NULL
    je .windowError
    mov rdi,[rel window]
    call glfwMakeContextCurrent wrt ..plt
    mov byte[rel glewExperimental],true
    call glewInit wrt ..plt
    cmp rax,GLEW_OK
    jne .glewError
    ; we can exit now
    .exit:
        mov rdi,exitMessage ;wrt ..gotpc
        mov rsi,exitMessageLen wrt ..gotpc
        call myPrint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitZero wrt ..plt
    .initError:
        mov rdi,initError wrt ..gotpc
        mov rsi,initErrorLen wrt ..gotpc
        call myEprint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitOne wrt ..plt
    .windowError:
        mov rdi,windowError wrt ..gotpc
        mov rsi,windowErrorLen wrt ..gotpc
        call myEprint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitOne wrt ..plt
    .glewError:
        mov rdi,glewInitError wrt ..gotpc
        mov rsi,glewInitErrorLen wrt ..gotpc
        call myEprint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitOne wrt ..plt
