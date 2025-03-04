EXTRN buffer: byte

codeSEG SEGMENT PARA 'CODE'
    assume CS:codeSEG
input proc far
    mov ah, 0Ah
    mov dx, offset buffer
    int 21h 

    ret
input endp
codeSEG ENDS

END