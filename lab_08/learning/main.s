	.file	"main.c"
	.text
	.type	dialog_destroy, @function
dialog_destroy:
.LFB2401:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	%rdx, -24(%rbp)
	call	gtk_widget_get_type@PLT
	movq	%rax, %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdi
	call	gtk_widget_destroy@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2401:
	.size	dialog_destroy, .-dialog_destroy
	.globl	find_upper_degree_of_two
	.type	find_upper_degree_of_two, @function
find_upper_degree_of_two:
.LFB2402:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	$1, -8(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L3
.L4:
	sall	-8(%rbp)
	addl	$1, -4(%rbp)
.L3:
	movl	-8(%rbp), %eax
	cltq
	cmpq	%rax, -24(%rbp)
	jg	.L4
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2402:
	.size	find_upper_degree_of_two, .-find_upper_degree_of_two
	.section	.rodata
.LC0:
	.string	"label"
	.align 8
.LC1:
	.string	"\320\236\321\210\320\270\320\261\320\272\320\260, \320\275\321\203\320\266\320\275\320\276 \320\262\320\262\320\265\321\201\321\202\320\270 \320\261\320\265\320\267\320\275\320\260\320\272\320\276\320\262\320\276\320\265 \321\207\320\270\321\201\320\273\320\276"
.LC2:
	.string	"\320\236\321\210\320\270\320\261\320\272\320\260"
.LC3:
	.string	"response"
	.align 8
.LC4:
	.string	"\320\221\320\273\320\270\320\266\320\260\320\271\321\210\320\260\321\217 \321\201\321\202\320\265\320\277\320\265\320\275\321\214 \320\264\320\262\320\276\320\271\320\272\320\270 %d : 2^%d = %lld"
.LC5:
	.string	"\320\240\320\265\320\267\321\203\320\273\321\214\321\202\320\260\321\202"
	.text
	.type	on_button_clicked, @function
on_button_clicked:
.LFB2403:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$80, %rsp
	movq	%rdi, -72(%rbp)
	movq	%rsi, -80(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	-80(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %rax
	movl	$80, %esi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdx
	leaq	.LC0(%rip), %rax
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	g_object_get_data@PLT
	movq	%rax, -40(%rbp)
	call	gtk_entry_get_type@PLT
	movq	%rax, %rdx
	movq	-48(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdi
	call	gtk_entry_get_text@PLT
	movq	%rax, -32(%rbp)
	movq	$0, -56(%rbp)
	leaq	-56(%rbp), %rcx
	movq	-32(%rbp), %rax
	movl	$10, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	strtoll@PLT
	movq	%rax, -24(%rbp)
	movq	-56(%rbp), %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L7
	cmpq	$0, -24(%rbp)
	jns	.L8
.L7:
	leaq	.LC1(%rip), %r8
	movl	$1, %ecx
	movl	$3, %edx
	movl	$1, %esi
	movl	$0, %edi
	movl	$0, %eax
	call	gtk_message_dialog_new@PLT
	movq	%rax, -16(%rbp)
	call	gtk_window_get_type@PLT
	movq	%rax, %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	gtk_window_set_title@PLT
	movq	-16(%rbp), %rax
	movl	$0, %r9d
	movl	$0, %r8d
	movl	$0, %ecx
	leaq	dialog_destroy(%rip), %rdx
	leaq	.LC3(%rip), %rsi
	movq	%rax, %rdi
	call	g_signal_connect_data@PLT
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	gtk_widget_show_all@PLT
	jmp	.L9
.L8:
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	find_upper_degree_of_two@PLT
	movl	%eax, -60(%rbp)
	movl	-60(%rbp), %eax
	movl	$1, %edx
	movl	%eax, %ecx
	salq	%cl, %rdx
	movq	%rdx, %rax
	movl	-60(%rbp), %edx
	pushq	%rax
	movl	-60(%rbp), %eax
	pushq	%rax
	movl	%edx, %r9d
	leaq	.LC4(%rip), %r8
	movl	$1, %ecx
	movl	$0, %edx
	movl	$1, %esi
	movl	$0, %edi
	movl	$0, %eax
	call	gtk_message_dialog_new@PLT
	addq	$16, %rsp
	movq	%rax, -16(%rbp)
	call	gtk_window_get_type@PLT
	movq	%rax, %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdx
	leaq	.LC5(%rip), %rax
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	gtk_window_set_title@PLT
	movq	-16(%rbp), %rax
	movl	$0, %r9d
	movl	$0, %r8d
	movl	$0, %ecx
	leaq	dialog_destroy(%rip), %rdx
	leaq	.LC3(%rip), %rsi
	movq	%rax, %rdi
	call	g_signal_connect_data@PLT
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	gtk_widget_show_all@PLT
.L9:
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L10
	call	__stack_chk_fail@PLT
.L10:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2403:
	.size	on_button_clicked, .-on_button_clicked
	.section	.rodata
	.align 8
.LC6:
	.string	"\320\233\320\2408 \320\277\320\276 \320\234\320\227\320\257\320\237. \320\237\320\276\320\277\320\276\320\262 \320\256.\320\220."
.LC7:
	.string	"destroy"
.LC8:
	.string	"\320\222\320\262\320\265\320\264\320\270\321\202\320\265\321\221 \321\202\320\265\320\272\321\201\321\202: "
	.align 8
.LC9:
	.string	"\320\235\320\260\320\271\321\202\320\270 \320\261\320\273\320\270\320\266\320\260\320\271\321\210\321\203\321\216 \321\201\320\262\320\265\321\200\321\205\321\203 \321\201\321\202\320\265\320\277\320\265\320\275\321\214 \320\264\320\262\320\276\320\271\320\272\320\270"
.LC10:
	.string	"clicked"
	.text
	.globl	main
	.type	main, @function
main:
.LFB2404:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movl	%edi, -52(%rbp)
	movq	%rsi, -64(%rbp)
	leaq	-64(%rbp), %rdx
	leaq	-52(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	gtk_init@PLT
	movl	$0, %edi
	call	gtk_window_new@PLT
	movq	%rax, -40(%rbp)
	call	gtk_window_get_type@PLT
	movq	%rax, %rdx
	movq	-40(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdx
	leaq	.LC6(%rip), %rax
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	gtk_window_set_title@PLT
	call	gtk_window_get_type@PLT
	movq	%rax, %rdx
	movq	-40(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movl	$100, %edx
	movl	$300, %esi
	movq	%rax, %rdi
	call	gtk_window_set_default_size@PLT
	movq	-40(%rbp), %rax
	movl	$0, %r9d
	movl	$0, %r8d
	movl	$0, %ecx
	movq	gtk_main_quit@GOTPCREL(%rip), %rdx
	leaq	.LC7(%rip), %rsi
	movq	%rax, %rdi
	call	g_signal_connect_data@PLT
	call	gtk_grid_new@PLT
	movq	%rax, -32(%rbp)
	call	gtk_container_get_type@PLT
	movq	%rax, %rdx
	movq	-40(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	gtk_container_add@PLT
	leaq	.LC8(%rip), %rax
	movq	%rax, %rdi
	call	gtk_label_new@PLT
	movq	%rax, -24(%rbp)
	call	gtk_grid_get_type@PLT
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdi
	movq	-24(%rbp), %rax
	movl	$1, %r9d
	movl	$1, %r8d
	movl	$0, %ecx
	movl	$0, %edx
	movq	%rax, %rsi
	call	gtk_grid_attach@PLT
	call	gtk_entry_new@PLT
	movq	%rax, -16(%rbp)
	call	gtk_grid_get_type@PLT
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdi
	movq	-16(%rbp), %rax
	movl	$1, %r9d
	movl	$1, %r8d
	movl	$0, %ecx
	movl	$1, %edx
	movq	%rax, %rsi
	call	gtk_grid_attach@PLT
	leaq	.LC9(%rip), %rax
	movq	%rax, %rdi
	call	gtk_button_new_with_label@PLT
	movq	%rax, -8(%rbp)
	call	gtk_grid_get_type@PLT
	movq	%rax, %rdx
	movq	-32(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	g_type_check_instance_cast@PLT
	movq	%rax, %rdi
	movq	-8(%rbp), %rax
	movl	$1, %r9d
	movl	$2, %r8d
	movl	$1, %ecx
	movl	$0, %edx
	movq	%rax, %rsi
	call	gtk_grid_attach@PLT
	movq	-16(%rbp), %rdx
	movq	-8(%rbp), %rax
	movl	$0, %r9d
	movl	$0, %r8d
	movq	%rdx, %rcx
	leaq	on_button_clicked(%rip), %rdx
	leaq	.LC10(%rip), %rsi
	movq	%rax, %rdi
	call	g_signal_connect_data@PLT
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	gtk_widget_show_all@PLT
	call	gtk_main@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2404:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
