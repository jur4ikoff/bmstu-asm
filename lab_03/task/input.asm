EXTRN buffer: byte

codeSEG SEGMENT PARA 'CODE'
    assume CS:codeSEG
input_count proc far
    mov ah, 0Ah
    mov dx, offset buffer
    int 21h 

    ret
input_count endp
codeSEG ENDS

END