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
extern  glGetUniformLocation
extern  glUniformMatrix4fv

; glmc imports
extern  glmc_perspective
extern  glmc_lookat
extern  glmc_mat4_mul
extern  glmc_mat4_zero

; my imports
extern  myLoadShader
extern  myPrint
extern  myEprint
extern  exitZero
extern  exitOne
extern  cacheShader


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
%define MAT4LEN 64
%define VEC3LEN 12
%define VEC4LEN 16
%define ONEMAT4 dd 1.0,0.0,0.0,0.0,  0.0,1.0,0.0,0.0,  0.0,0.0,1.0,0.0,  0.0,0.0,0.0,1.0


section .data
; error messages
initError:db "Failed to initialize GLFW",10
initErrorLen:equ $-initError
windowError:db "Failed to create the window",10
windowErrorLen:equ $-windowError

; names/messages
windowName:db "My ASM window",0
exitMessage:db "Closing now",10
exitMessageLen:equ $-exitMessage
MVPString:db "MVP",0

; vertex buffer stuff
staticVertexBuffer:dd -1.0,-1.0,0.0, 1.0,-1.0,0.0, 0.0,1.0,0.0,  -1.0,1.0,0.0, 0.0,0.5,0.0, 1.0,1.0,0.0,  1.0,0.25,0.0, 1.0,-0.25,0.0, 0.75,0.0,0.0,  -1.0,0.25,0.0, -1.0,-0.25,0.0, -0.75,0.0,0.0
staticVertexBufferLen:equ $-staticVertexBuffer
staticVertexBufferTriangles:equ staticVertexBufferLen/VEC3LEN

; matrix stuff
baseMAT4:dd 1.0,0.0,0.0,0.0,  0.0,1.0,0.0,0.0,  0.0,0.0,1.0,0.0,  0.0,0.0,0.0,1.0

; vector things
cameraPos:dd 4.0,3.0,3.0
cameraLookAt:dd 0.0,0.0,0.0
cameraHead:dd 0.0,1.0,0.0

; floats
pFourF:dd 0.4
zeroF:dd 0.0
oneF:dd 1.0
deg45:dd 0.785398
fourThirds:dd 1.33333333333333333333
pOneF:dd 0.1
hundredF:dd 100.0

section .bss
; GL stuff: IDs and buffer storage
window:resq 1
vertexArrayID:resq 1
programID:resq 1
vertexBuffer:resq 1
matrixID:resq 1

; time things
programStartTime:
programTimeSeconds: resq 1
programTimeMicros: resq 1
timeStruct:
timeSeconds: resq 1
timeMicros: resq 1
timeZoneStruct: resd 2  ; we dont need this guy but it is here so we dont have to worry make a place on the stack

; matrices
align 16
projectionMAT4:resb MAT4LEN
viewMAT4:resb MAT4LEN
modelMAT4:resb MAT4LEN
mvpMAT4:resb MAT4LEN
intMAT4:resb MAT4LEN


section .text
; function(rdi,rsi,rdx,rcx,r8,r9)->rax   other args go to the stack in reverse order
; functions return in rax
_start:
    call getStartTime
    jmp init    ; We use jmp here because glfwInit segfaults when we call init. Hacky stuff here
    .init:
    call generateMatrices
    .eventLoop:
    ; do {
        ; clear the screen, this starts the render process
        mov rdi,GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
        call glClear wrt ..plt
        ; use the triangle's shader
        mov rdi,[rel programID]
        call glUseProgram wrt ..plt
        ; set the uniform in the shader
        mov rdi,[rel matrixID]
        mov rsi,1
        mov rdx,GL_FALSE
        mov rcx,mvpMAT4
        call glUniformMatrix4fv wrt ..plt
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
            ; actually draw the triangles, we use staticVertexBufferTriangles because that contains how may triangles (verticies, actually) there are
            mov rdi,GL_TRIANGLES
            mov rsi,0
            mov rdx,staticVertexBufferTriangles
            call glDrawArrays wrt ..plt
            mov rdi,0
            call glDisableVertexAttribArray wrt ..plt
        ; END   triangle drawing
        ; swap the render buffers which displays the frame we just rendered
        mov rdi,[rel window]
        call glfwSwapBuffers wrt ..plt
        call glfwPollEvents wrt ..plt
    ; } while (glfwGetKey(window,GLFW_KEY_ESCAPE)!=GLFW_PRESS && glfwWindowShouldClose(window)==0)  the instructions from here to .cleanup are all the comparison
        ; test if the escape key has been pressed, if so then jump to .cleanup
        mov rdi,[rel window]
        mov rsi,GLFW_KEY_ESCAPE
        call glfwGetKey wrt ..plt
        cmp rax,GLFW_PRESS
        je .cleanup
        ; if the used tried to close the window then stop looping to .eventLoop
        mov rdi,[rel window]
        call glfwWindowShouldClose wrt ..plt
        cmp rax,0
        je .eventLoop
    .cleanup:
    ; this is where we destroy buffers, arrays and GLSL programs
    mov rdi,1
    mov rsi,vertexBuffer
    call glDeleteBuffers wrt ..plt
    mov rdi,1
    mov rsi,vertexArrayID
    call glDeleteVertexArrays wrt ..plt
    mov rdi,programID
    call glDeleteProgram wrt ..plt
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

getStartTime:
    mov rax,96
    mov rdi,programStartTime
    mov rsi,timeZoneStruct
    syscall
    ret
getTime:
    mov rax,96
    mov rdi,timeStruct
    mov rsi,timeZoneStruct
    syscall
    ret

generateMatrices:
    ; create the view matrix
    mov rdi,cameraPos
    mov rsi,cameraLookAt
    mov rdx,cameraHead
    mov rcx,viewMAT4
    call glmc_lookat wrt ..plt

    ; move the base matrix (basic transform) into the modelMAT4 variable
    xor rax,rax
    mov rbx,baseMAT4
    .move:
    movss xmm0,[rbx+rax]
    movss [rbx+rax],xmm0
    add rax,VEC4LEN
    cmp rax,64
    jne .move

    ; create the projection matrix
    movss xmm3,[rel hundredF]
    movss xmm2,[rel pOneF]
    movss xmm1,[rel fourThirds]
    movss xmm0,[rel deg45]
    mov rdi,projectionMAT4
    call glmc_perspective wrt ..plt

    ; intMAT4 = projectionMAT4 * viewMAT4
    mov rdi,projectionMAT4
    mov rsi,viewMAT4
    mov rdx,intMAT4
    call glmc_mat4_mul wrt ..plt
    ; mvpMAT4 = intMAT4 * modelMAT4
    mov rdi,baseMAT4
    mov rsi,intMAT4
    mov rdx,mvpMAT4
    call glmc_mat4_mul wrt ..plt
    ret

init:
    ; BEGIN INIT
    call glfwInit wrt ..plt
    cmp rax,false
    je _start.initError
    ; START WINDOW HINTS
    mov rdi,GLFW_SAMPLES
    mov rsi,4
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_CONTEXT_VERSION_MAJOR
    mov rsi,4
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_CONTEXT_VERSION_MINOR
    mov rsi,5
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_OPENGL_FORWARD_COMPAT
    mov rsi,GL_TRUE
    call glfwWindowHint wrt ..plt
    mov rdi,GLFW_OPENGL_PROFILE
    mov rsi,GLFW_OPENGL_CORE_PROFILE
    call glfwWindowHint wrt ..plt
    ; END WINDOW HINTS
    ; this is where we actually create the window, after this function call the window will either popup or you have an error
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
    ; here we use the MMX registers for passing floats to the function `glClearColor`
    movss xmm0,[rel zeroF]  ; R
    movss xmm1,[rel zeroF]  ; G
    movss xmm2,[rel pFourF] ; B
    movss xmm3,[rel oneF]   ; A this is not needed though since we don't have an RGBA buffer. apparently a later tutorial introduces the alpha channel
    call glClearColor wrt ..plt
    mov rdi,1
    mov rsi,vertexArrayID
    call glGenVertexArrays wrt ..plt
    mov rdi,[rel vertexArrayID]
    call glBindVertexArray wrt ..plt
    ; BEGIN SHADER INIT
    call myLoadShader wrt ..plt
    mov [rel programID],rax
    mov rdi,rax
    mov rsi,MVPString
    call glGetUniformLocation wrt ..plt
    breakpoint:
    mov [rel matrixID],rax
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
    jmp _start.init ; return to just after where we left, see _start as to why this is not a `ret` instruction
