stackSEG SEGMENT PARA STACK 'STACK'
    DB 200h DUP (?)
stackSEG ENDS

dataSEG SEGMENT WORD 'DATA'
HelloMessage DB 13
    DB 10
    DB 'Hello World!'
    DB '$'
dataSEG ENDS

codeSEG SEGMENT WORD 'CODE'
    ASSUME CS:codeSEG, DS:dataSEG
dispMsg:
    mov ax, dataSEG
    mov ds, ax

    mov dx, offset HelloMessage
    mov ah, 9

    mov cx, 3       
    LoopStart: ; Метка цикла
        int 21h    
        loop LoopStart 


    mov ah, 4ch
    int 21h
codeSEG ENDS

END dispMsg