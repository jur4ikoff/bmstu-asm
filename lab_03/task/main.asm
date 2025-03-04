EXTRN input: far

stackSEG SEGMENT PARA STACK 'STACK'
    db 100 dup(0)
stackSEG ENDS

dataSEG SEGMENT PARA 'DATA'
    buffer db 100 dup ('$')
dataSEG ENDS

codeSEG SEGMENT PARA 'CODE'
    assume CS:codeSEG, DS:dataSEG, SS: stackSEG
main:
    mov ax, dataSEG
    mov ds, ax

    call input

    ;mov dl, 13
	;int 21h
	
    mov ah, 2

    mov dl, 10
	int 21h

    mov dl, buffer[2]
    int 21h

    mov ax, 4c00h
    int 21h
codeSEG ENDS
END main
