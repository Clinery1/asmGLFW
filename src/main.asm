global  _start
global  _start.exit


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
extern  glGetError

; my imports
extern  myLoadShader
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
%define GL_DEPTH_BUFFER_BIT 0x00000100
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
%define WIDTH   1024
%define HEIGHT  768


section .data
zero:dq 0
windowName:db "My ASM window",0
exitMessage:db "Closing now",10
exitMessageLen:equ $-exitMessage
initError:db "Failed to initialize GLFW",10
initErrorLen:equ $-initError
windowError:db "Failed to create the window",10
windowErrorLen:equ $-windowError
pFourF:dd 0.4
zeroF:dd 0.0
oneF:dd 1.0
staticVertexBuffer:dd -1.0,-1.0,0.0,  1.0,-1.0,0.0,  0.0,1.0,0.0
staticVertexBufferLen:equ $-staticVertexBuffer

section .bss
window:resq 1
vertexArrayID:resq 1
programID:resq 1
vertexBuffer:resq 10


section .text
; function(rdi,rsi,rdx,rcx,r8,r9)->rax   other args go to the stack in reverse order
; functions return in rax
_start:
    xor rax,rax
    mov [rel vertexBuffer],rax
    ; BEGIN INIT
    call glfwInit wrt ..plt
    cmp rax,false
    je _start.initError
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
    mov rdi,WIDTH
    mov rsi,HEIGHT
    mov rdx,windowName
    mov rcx,NULL
    mov r8,NULL
    call glfwCreateWindow wrt ..plt
    mov [rel window],rax
    cmp qword[rel window],NULL
    je _start.windowError
    mov rdi,[rel window]
    call glfwMakeContextCurrent wrt ..plt
    mov rdi,[rel window]
    mov rsi,GLFW_STICKY_KEYS
    mov rdx,GL_TRUE
    call glfwSetInputMode wrt ..plt
    movss xmm0,[rel zeroF]  ; R
    movss xmm1,[rel zeroF]  ; G
    movss xmm2,[rel pFourF] ; B
    movss xmm3,[rel oneF]   ; A this is not needed though since we don't have an RGBA buffer. dont ask why, I dont know
    call glClearColor wrt ..plt
    mov rdi,1
    mov rsi,vertexArrayID
    call glGenVertexArrays wrt ..plt
    mov rdi,[rel vertexArrayID]
    call glBindVertexArray wrt ..plt
    ; BEGIN SHADER INIT
    call myLoadShader wrt ..plt
    mov [rel programID],rax
    ; END SHADER INIT
    ; BEGIN TRIANGLE INIT
    mov rdi,3
    mov rsi,vertexBuffer
    call glGenBuffers wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,[rel vertexBuffer]
    call glBindBuffer wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,staticVertexBufferLen
    mov rdx,staticVertexBuffer
    mov rcx,GL_STATIC_DRAW
    call glBufferData wrt ..plt
    ; END TRIANGLE INIT
    ; END INIT
    .actionLoop:
    ; do {
        mov rdi,GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
        call glClear wrt ..plt
        mov rdi,[rel programID]
        call glUseProgram wrt ..plt
        ; BEGIN triangle drawing
        mov rdi,0
        call glEnableVertexAttribArray wrt ..plt
        mov rsi,vertexBuffer
        call glBindBuffer wrt ..plt
        mov rdi,0
        mov rsi,3
        mov rdx,GL_FLOAT
        mov rcx,GL_FALSE
        mov r8,0
        mov r9,0
        call glVertexAttribPointer wrt ..plt
        mov rdi,GL_TRIANGLES
        mov rsi,0
        mov rdx,3
        call glDrawArrays wrt ..plt
        mov rdi,0
        call glDisableVertexAttribArray wrt ..plt
        ; END   triangle drawing
        mov rdi,[rel window]
        call glfwSwapBuffers wrt ..plt
        call glfwPollEvents wrt ..plt
    ; } while (glfwGetKey(window,GLFW_KEY_ESCAPE)!=GLFW_PRESS && glfwWindowShouldClose(window)==0)  the instructions from here to .cleanup are all the comparison
    ; pseudo code for the next 9 lines: if escape key is pressed OR window should close THEN jump to .cleanup
    mov rdi,[rel window]
    mov rsi,GLFW_KEY_ESCAPE
    call glfwGetKey wrt ..plt
    cmp rax,GLFW_PRESS
    je .exit
    mov rdi,[rel window]
    call glfwWindowShouldClose wrt ..plt
    cmp rax,0
    je .actionLoop
    .cleanup:
    mov rdi,1
    mov rsi,vertexBuffer
    call glDeleteBuffers wrt ..plt
    mov rdi,1
    mov rsi,vertexArrayID
    call glDeleteVertexArrays wrt ..plt
    mov rdi,programID
    call glDeleteProgram wrt ..plt
    ; we can exit now
    .exit:
        mov rdi,exitMessage
        mov rsi,exitMessageLen
        call myPrint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitZero wrt ..plt
    .initError:
        mov rdi,initError
        mov rsi,initErrorLen
        call myEprint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitOne wrt ..plt
    .windowError:
        mov rdi,windowError
        mov rsi,windowErrorLen
        call myEprint wrt ..plt
        call glfwTerminate wrt ..plt
        jmp exitOne wrt ..plt
