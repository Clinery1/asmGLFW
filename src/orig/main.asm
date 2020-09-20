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
%define GL_TRIANGLES        0x0004
%define GL_ARRAY_BUFFER     0x8892
%define GL_STATIC_DRAW      0x88e4
%define GL_FLOAT            0x1406

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
    ; time to create the window
    call createWindow
    ; now we init GLEW
    mov byte[rel glewExperimental],true
    call glewInit wrt ..plt
    cmp rax,0
    jne .glewError
    ; no error so we continue
    ; set this so we can access the ESC key
    mov rdi,[rel window]
    mov rsi,GLFW_STICKY_KEYS
    mov rdx,true
    call glfwSetInputMode wrt ..plt
    ; set the dark blue background
    mov rdi,[rel zeroF]
    mov rsi,rdi
    mov rdx,[rel pFourF]
    mov rcx,rdi
    call glClearColor wrt ..plt

    mov rdi,1
    mov rsi,vertexArrayID
    call glGenVertexArrays wrt ..plt
    mov rdi,[rel vertexArrayID]
    call glBindVertexArray wrt ..plt

    ; load and compile the shaders
    call myLoadShader
    mov [rel programID],rax
    mov rdi,1
    mov rsi,vertexBuffer
    call glGenBuffers wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,[rel vertexBuffer]
    call glBindBuffer wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,staticVertexBufferDataLen
    mov rdx,staticVertexBufferData
    mov rcx,GL_STATIC_DRAW
    call glBufferData wrt ..plt

    call actionLoop
    ; cleanup time!
    mov rdi,1
    mov rsi,vertexBuffer
    call glDeleteBuffers wrt ..plt
    mov rdi,1
    mov rsi,vertexArrayID
    call glDeleteVertexArrays wrt ..plt
    mov rdi,[rel programID]
    call glDeleteProgram wrt ..plt
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


actionLoop:
    mov rdi,GL_COLOR_BUFFER_BIT
    call glClear wrt ..plt

    mov rdi,[rel programID]
    call glUseProgram wrt ..plt

    mov rdi,0
    call glEnableVertexAttribArray wrt ..plt

    mov rdi,GL_ARRAY_BUFFER
    mov rsi,vertexBuffer
    call glBindBuffer wrt ..plt

    mov rdi,0
    mov rsi,3
    mov rdx,GL_FLOAT
    mov rcx,false
    mov r8,0
    mov r9,0
    call glVertexAttribPointer wrt ..plt

    mov rdi,GL_TRIANGLES
    mov rsi,0
    mov rdx,3
    call glDrawArrays wrt ..plt

    mov rdi,0
    call glDisableVertexAttribArray wrt ..plt

    mov rdi,[rel window]
    call glfwSwapBuffers wrt ..plt

    call glfwPollEvents wrt ..plt

    ; here we test if the loop is finished, if yes then we return otherwise jmp back to actionLoop
    mov rdi,[rel window]
    mov rsi,GLFW_KEY_ESCAPE
    call glfwGetKey wrt ..plt
    cmp rax,GLFW_PRESS
    je .return
    mov rdi,[rel window]
    call glfwWindowShouldClose wrt ..plt
    cmp rax,0
    je .return

    jmp actionLoop
    .return:
    ret

createWindow:
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
    mov rsi,true
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_OPENGL_PROFILE
    mov rsi,GLFW_OPENGL_CORE_PROFILE
    call glfwWindowHint wrt ..plt
    ; we have hinted at what we want now we create the window! this is the best part (not really, I am getting lots of segfaults as of 9/19/20@1536)
    .problem:
    mov rdi,width
    mov rsi,height
    lea rdx,[rel windowName]
    xor rcx,rcx
    xor r8,r8
    call glfwCreateWindow wrt ..plt
    mov [rel window],rax
    cmp qword[rel window],NULL
    je _start.windowError
    mov rdi,[rel window]
    call glfwMakeContextCurrent wrt ..plt
    ret
