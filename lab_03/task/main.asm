EXTRN input_count: far

stackSEG SEGMENT PARA STACK 'STACK'
    db 100 dup(0)
stackSEG ENDS

dataSEG SEGMENT PARA 'DATA'
    PUBLIC buffer
    buffer db 100 dup ('$')
dataSEG ENDS

codeSEG SEGMENT PARA 'CODE'
    assume CS:codeSEG, DS:dataSEG, SS: stackSEG
main:
    mov ax, dataSEG
    mov ds, ax

    call input_count

	
    mov ah, 2
    mov dl, 10 
	int 21h

    mov dl, buffer[2 + 2]
    int 21h

    mov ax, 4c00h
    int 21h
codeSEG ENDS
END main
