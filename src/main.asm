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
extern  glEnable
extern  glDepthFunc

; glmc imports
extern  glmc_perspective
extern  glmc_lookat
extern  glmc_mat4_mul

; libc imports (was trying to avoid these)
extern  sinf
extern  cosf

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
%define GL_DEPTH_TEST       0x0b71
%define GL_LESS             0x0201

; GLEW defines
%define GLEW_OK     0

; other defines
%define NULL    0
%define true    1
%define false   0
%define WIDTH   1280
%define HEIGHT  720
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
cubeVertices:dd -1.0,-1.0,-1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,-1.0,-1.0,-1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,-1.0,-1.0,-1.0,1.0,1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,1.0,1.0,1.0,1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,1.0,1.0,-1.0,1.0,1.0,1.0,1.0,1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,1.0,1.0,1.0,-1.0,1.0,1.0,1.0,-1.0,1.0
cubeVerticesLen:equ $-cubeVertices
cubeVerticesTriangles:equ cubeVerticesLen/VEC3LEN
cubeVertexColors:dd 0.583,0.771,0.014,0.609,0.115,0.436,0.327,0.483,0.844,0.822,0.569,0.201,0.435,0.602,0.223,0.310,0.747,0.185,0.597,0.770,0.761,0.559,0.436,0.730,0.359,0.583,0.152,0.483,0.596,0.789,0.559,0.861,0.639,0.195,0.548,0.859,0.014,0.184,0.576,0.771,0.328,0.970,0.406,0.615,0.116,0.676,0.977,0.133,0.971,0.572,0.833,0.140,0.616,0.489,0.997,0.513,0.064,0.945,0.719,0.592,0.543,0.021,0.978,0.279,0.317,0.505,0.167,0.620,0.077,0.347,0.857,0.137,0.055,0.953,0.042,0.714,0.505,0.345,0.783,0.290,0.734,0.722,0.645,0.174,0.302,0.455,0.848,0.225,0.587,0.040,0.517,0.713,0.338,0.053,0.959,0.120,0.393,0.621,0.362,0.673,0.211,0.457,0.820,0.883,0.371,0.982,0.099,0.879
cubeVertexColorsLen:equ $-cubeVertices

; matrix stuff
baseMAT4:dd 1.0,0.0,0.0,0.0,  0.0,1.0,0.0,0.0,  0.0,0.0,1.0,0.0,  0.0,0.0,0.0,1.0

; vector things
cameraPosStart:dd 8.0,3.0,8.0,0.0
cameraLookAtPos:dd 0.0,0.0,0.0,0.0
cameraUp:dd 0.0,1.0,0.0,0.0

; floats
pFourF:dd 0.4
zeroF:dd 0.0
oneF:dd 1.0
threeF:dd 3.0
fovF:dd 0.78539816339744830962
aspectRatioF:dd 1.77777777777777777778
nearFieldF:dd 0.1
farFieldF:dd 100.0
millionF:dd 0.000001
halfPI:dd 1.57079632679489661923
mask1010:dd 1.0,0.0,1.0,0.0

section .bss
; matrices
align 16
mvpMAT4:resb MAT4LEN
projectionMAT4:resb MAT4LEN
viewMAT4:resb MAT4LEN
modelMAT4:resb MAT4LEN
intMAT4:resb MAT4LEN
cameraPos:resd 4

; GL stuff: IDs and buffer storage
window:resq 1
vertexArrayID:resq 1
programID:resq 1
vertexBuffer:resq 1
colorBuffer:resq 1
matrixID:resq 1

; time things
programStartTime:
programTimeSeconds: resq 1
programTimeMicros: resq 1
timeStruct:         ; this specifies the current time in seconds from the unix epoch format
timeSeconds: resq 1 ; type:int
timeMicros: resq 1  ; type:int
timeZoneStruct: resd 2  ; we dont need this guy but it is here so we dont have to worry make a place on the stack
timeRunning:resd 1  ; type:float do with this what you want, it is here.

; scratch vars
scratch1:resq 1
scratch2:resq 1
scratch3:resq 1
scratch4:resq 2
scratch5:resq 2
scratch6:resq 2


section .text
; function(rdi,rsi,rdx,rcx,r8,r9)->rax   other args go to the stack in reverse order
; functions return in rax
_start:
    call getStartTime
    jmp init    ; We use jmp here because glfwInit segfaults when we call init. Hacky stuff here
    .init:
    call initMatrices
    .eventLoop:
    ; do {
        ; Get the time we started this frame for calculation purposes
        call getTime
        call updateSpin
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
            ; enable vertexArrays
            mov rdi,0
            call glEnableVertexAttribArray wrt ..plt
            mov rdi,1
            call glEnableVertexAttribArray wrt ..plt
            mov rdi,0
            mov rsi,3
            mov rdx,GL_FLOAT
            mov rcx,GL_FALSE
            mov r8,0
            mov r9,0
            call glVertexAttribPointer wrt ..plt
            mov rdi,1
            mov rsi,3
            mov rdx,GL_FLOAT
            mov rcx,GL_FALSE
            mov r8,0
            mov r9,0
            call glVertexAttribPointer wrt ..plt
            ; actually draw the triangles, we use staticVertexBufferTriangles because that contains how may triangles (verticies, actually) there are
            mov rdi,GL_TRIANGLES
            mov rsi,0
            mov rdx,cubeVerticesTriangles  ; DISABLED: staticVertexBufferTriangles
            call glDrawArrays wrt ..plt
            ; disable vertexArrays
            mov rdi,1
            call glDisableVertexAttribArray wrt ..plt
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
    mov rax,[rel timeSeconds]
    sub rax,[rel programTimeSeconds]
    mov [rel timeSeconds],rax
    mov rax,[rel timeMicros]
    sub rax,[rel programTimeMicros]
    mov [rel timeMicros],rax
    ; convert the s and us to a float of both.
    movups xmm0,[rel timeStruct]
    cvtdq2ps xmm1,xmm0  ; this converts the ints to floats in xmm0 and puts the floats in xmm1
    movhlps xmm2,xmm1
    movss xmm3,[rel millionF]
    mulss xmm2,xmm3
    addss xmm1,xmm2
    movss [rel timeRunning],xmm1
    ret

initMatrices:
    ; create the view matrix
    call lookAt
    ; move the base matrix (basic transform) into the modelMAT4 variable
    xor rax,rax
    mov rbx,baseMAT4
    mov rcx,modelMAT4
    ; move the cameraPos vector into its position
    movups xmm0,[rel cameraPosStart]
    movaps [rel cameraPos],xmm0
    .move:
    mov rdx,[rbx+rax]
    mov [rcx+rax],rdx
    add rax,8
    cmp rax,64
    jne .move
    ; create the projection matrix
    movss xmm3,[rel farFieldF]
    movss xmm2,[rel nearFieldF]
    movss xmm1,[rel aspectRatioF]
    movss xmm0,[rel fovF]
    mov rdi,projectionMAT4
    call glmc_perspective wrt ..plt
    jmp updateMatrices

updateSpin:
    ; clear scratch 1 and 2
    mov qword[rel scratch1],0
    mov qword[rel scratch2],0
    ; take the sin(timeFloat)
    ; here we take the value in timeFloat, assign it to xmm0 high and low,then add halfPI to xmm0 high then sin(x) that vector
    mov rax,scratch1
    mov rbx,scratch2
    movss xmm0,[rel timeRunning]
    call sinf wrt ..plt
    movss [rel scratch1],xmm0
    movss xmm0,[rel timeRunning]
    call cosf wrt ..plt
    movss [rel scratch2],xmm0
    movss xmm0,[rel timeRunning]
    addss xmm0,[rel oneF]
    mulss xmm0,[rel threeF]
    call sinf wrt ..plt
    movss [rel scratch1+4],xmm0
    movups xmm0,[rel scratch1]
    ; we just finished the sin and cos functions (cos is just sin(x+rad(90)))
    movups xmm1,[rel cameraPosStart]
    mulps xmm0,xmm1
    ; by now we have the values for the X and Z but we need the Y value
    ; add the values to the position
    movups [rel cameraPos],xmm0
    call lookAt
    call updateMatrices
    ret


updateMatrices:
    ; intMAT4 = projectionMAT4 * viewMAT4
    mov rdi,modelMAT4
    mov rsi,viewMAT4
    mov rdx,intMAT4
    call glmc_mat4_mul wrt ..plt
    ; mvpMAT4 = intMAT4 * modelMAT4
    mov rdi,projectionMAT4
    mov rsi,intMAT4
    mov rdx,mvpMAT4
    call glmc_mat4_mul wrt ..plt
    ret

lookAt:
    mov rdi,cameraPos
    mov rsi,cameraLookAtPos
    mov rdx,cameraUp
    mov rcx,viewMAT4
    call glmc_lookat wrt ..plt
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
    mov rdi,GL_DEPTH_TEST
    call glEnable wrt ..plt
    mov rdi,GL_LESS
    call glDepthFunc wrt ..plt
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
    mov [rel matrixID],rax
    ; END SHADER INIT
    ; BEGIN TRIANGLE INIT
    mov rdi,2
    mov rsi,vertexBuffer
    call glGenBuffers wrt ..plt
    ; BEGIN BUFFER SWAP
    xor rbx,rbx
    mov rax,[rel vertexBuffer+4]
    mov [rel vertexBuffer+4],rbx
    mov [rel colorBuffer],rax
    ; END BUFFER SWAP
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,[rel vertexBuffer]
    call glBindBuffer wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,[rel colorBuffer]
    call glBindBuffer wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,cubeVertexColorsLen
    mov rdx,cubeVertexColors
    mov rcx,GL_STATIC_DRAW
    call glBufferData wrt ..plt
    mov rdi,GL_ARRAY_BUFFER
    mov rsi,cubeVerticesLen
    mov rdx,cubeVertices
    mov rcx,GL_STATIC_DRAW
    call glBufferData wrt ..plt
    ; END TRIANGLE INIT
    ; END INIT
    jmp _start.init ; return to just after where we left, see _start as to why this is not a `ret` instruction
