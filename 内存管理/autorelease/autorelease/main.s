	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0	sdk_version 12, 3
	.p2align	2                               ; -- Begin function -[MyObject object]
"-[MyObject object]":                   ; @"\01-[MyObject object]"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	str	x1, [sp, #16]
	adrp	x8, _OBJC_CLASSLIST_REFERENCES_$_@PAGE
	ldr	x0, [x8, _OBJC_CLASSLIST_REFERENCES_$_@PAGEOFF]
	bl	_objc_alloc_init
	str	x0, [sp, #8]
	ldr	x0, [sp, #8]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_test1                          ; -- Begin function test1
	.p2align	2
_test1:                                 ; @test1
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
                                        ; kill: def $x8 killed $xzr
	stur	xzr, [x29, #-8]
	adrp	x8, _OBJC_CLASSLIST_REFERENCES_$_.1@PAGE
	ldr	x0, [x8, _OBJC_CLASSLIST_REFERENCES_$_.1@PAGEOFF]
	adrp	x8, _OBJC_SELECTOR_REFERENCES_@PAGE
	ldr	x1, [x8, _OBJC_SELECTOR_REFERENCES_@PAGEOFF]
	bl	_objc_msgSend
	str	x0, [sp, #16]
	ldr	x0, [sp, #16]
	adrp	x8, _OBJC_SELECTOR_REFERENCES_.4@PAGE
	ldr	x1, [x8, _OBJC_SELECTOR_REFERENCES_.4@PAGEOFF]
	adrp	x2, l__unnamed_cfstring_@PAGE
	add	x2, x2, l__unnamed_cfstring_@PAGEOFF
	bl	_objc_msgSend
	ldr	x8, [sp, #16]
	stur	x8, [x29, #-8]
	ldr	x8, [sp, #16]
	adrp	x0, l__unnamed_cfstring_.6@PAGE
	add	x0, x0, l__unnamed_cfstring_.6@PAGEOFF
	mov	x9, sp
	str	x8, [x9]
	bl	_NSLog
	bl	__objc_autoreleasePoolPrint
	ldur	x8, [x29, #-8]
	adrp	x0, l__unnamed_cfstring_.8@PAGE
	add	x0, x0, l__unnamed_cfstring_.8@PAGEOFF
	mov	x9, sp
	str	x8, [x9]
	bl	_NSLog
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #0
	str	w8, [sp, #12]                   ; 4-byte Folded Spill
	stur	wzr, [x29, #-4]
	stur	w0, [x29, #-8]
	str	x1, [sp, #16]
	bl	_test1
	ldr	w0, [sp, #12]                   ; 4-byte Folded Reload
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__DATA,__objc_data
	.globl	_OBJC_CLASS_$_MyObject          ; @"OBJC_CLASS_$_MyObject"
	.p2align	3
_OBJC_CLASS_$_MyObject:
	.quad	_OBJC_METACLASS_$_MyObject
	.quad	_OBJC_CLASS_$_NSObject
	.quad	__objc_empty_cache
	.quad	0
	.quad	__OBJC_CLASS_RO_$_MyObject

	.section	__DATA,__objc_classrefs,regular,no_dead_strip
	.p2align	3                               ; @"OBJC_CLASSLIST_REFERENCES_$_"
_OBJC_CLASSLIST_REFERENCES_$_:
	.quad	_OBJC_CLASS_$_MyObject

	.section	__TEXT,__objc_classname,cstring_literals
l_OBJC_CLASS_NAME_:                     ; @OBJC_CLASS_NAME_
	.asciz	"MyObject"

	.section	__DATA,__objc_const
	.p2align	3                               ; @"_OBJC_METACLASS_RO_$_MyObject"
__OBJC_METACLASS_RO_$_MyObject:
	.long	1                               ; 0x1
	.long	40                              ; 0x28
	.long	40                              ; 0x28
	.space	4
	.quad	0
	.quad	l_OBJC_CLASS_NAME_
	.quad	0
	.quad	0
	.quad	0
	.quad	0
	.quad	0

	.section	__DATA,__objc_data
	.globl	_OBJC_METACLASS_$_MyObject      ; @"OBJC_METACLASS_$_MyObject"
	.p2align	3
_OBJC_METACLASS_$_MyObject:
	.quad	_OBJC_METACLASS_$_NSObject
	.quad	_OBJC_METACLASS_$_NSObject
	.quad	__objc_empty_cache
	.quad	0
	.quad	__OBJC_METACLASS_RO_$_MyObject

	.section	__TEXT,__objc_methname,cstring_literals
l_OBJC_METH_VAR_NAME_:                  ; @OBJC_METH_VAR_NAME_
	.asciz	"object"

	.section	__TEXT,__objc_methtype,cstring_literals
l_OBJC_METH_VAR_TYPE_:                  ; @OBJC_METH_VAR_TYPE_
	.asciz	"@16@0:8"

	.section	__DATA,__objc_const
	.p2align	3                               ; @"_OBJC_$_INSTANCE_METHODS_MyObject"
__OBJC_$_INSTANCE_METHODS_MyObject:
	.long	24                              ; 0x18
	.long	1                               ; 0x1
	.quad	l_OBJC_METH_VAR_NAME_
	.quad	l_OBJC_METH_VAR_TYPE_
	.quad	"-[MyObject object]"

	.p2align	3                               ; @"_OBJC_CLASS_RO_$_MyObject"
__OBJC_CLASS_RO_$_MyObject:
	.long	0                               ; 0x0
	.long	8                               ; 0x8
	.long	8                               ; 0x8
	.space	4
	.quad	0
	.quad	l_OBJC_CLASS_NAME_
	.quad	__OBJC_$_INSTANCE_METHODS_MyObject
	.quad	0
	.quad	0
	.quad	0
	.quad	0

	.section	__DATA,__objc_classrefs,regular,no_dead_strip
	.p2align	3                               ; @"OBJC_CLASSLIST_REFERENCES_$_.1"
_OBJC_CLASSLIST_REFERENCES_$_.1:
	.quad	_OBJC_CLASS_$_NSMutableArray

	.section	__TEXT,__objc_methname,cstring_literals
l_OBJC_METH_VAR_NAME_.2:                ; @OBJC_METH_VAR_NAME_.2
	.asciz	"array"

	.section	__DATA,__objc_selrefs,literal_pointers,no_dead_strip
	.p2align	3                               ; @OBJC_SELECTOR_REFERENCES_
_OBJC_SELECTOR_REFERENCES_:
	.quad	l_OBJC_METH_VAR_NAME_.2

	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"obj"

	.section	__DATA,__cfstring
	.p2align	3                               ; @_unnamed_cfstring_
l__unnamed_cfstring_:
	.quad	___CFConstantStringClassReference
	.long	1992                            ; 0x7c8
	.space	4
	.quad	l_.str
	.quad	3                               ; 0x3

	.section	__TEXT,__objc_methname,cstring_literals
l_OBJC_METH_VAR_NAME_.3:                ; @OBJC_METH_VAR_NAME_.3
	.asciz	"addObject:"

	.section	__DATA,__objc_selrefs,literal_pointers,no_dead_strip
	.p2align	3                               ; @OBJC_SELECTOR_REFERENCES_.4
_OBJC_SELECTOR_REFERENCES_.4:
	.quad	l_OBJC_METH_VAR_NAME_.3

	.section	__TEXT,__cstring,cstring_literals
l_.str.5:                               ; @.str.5
	.asciz	"obj0 = %@"

	.section	__DATA,__cfstring
	.p2align	3                               ; @_unnamed_cfstring_.6
l__unnamed_cfstring_.6:
	.quad	___CFConstantStringClassReference
	.long	1992                            ; 0x7c8
	.space	4
	.quad	l_.str.5
	.quad	9                               ; 0x9

	.section	__TEXT,__cstring,cstring_literals
l_.str.7:                               ; @.str.7
	.asciz	"obj1 = %@"

	.section	__DATA,__cfstring
	.p2align	3                               ; @_unnamed_cfstring_.8
l__unnamed_cfstring_.8:
	.quad	___CFConstantStringClassReference
	.long	1992                            ; 0x7c8
	.space	4
	.quad	l_.str.7
	.quad	9                               ; 0x9

	.section	__DATA,__objc_classlist,regular,no_dead_strip
	.p2align	3                               ; @"OBJC_LABEL_CLASS_$"
l_OBJC_LABEL_CLASS_$:
	.quad	_OBJC_CLASS_$_MyObject

	.section	__DATA,__objc_imageinfo,regular,no_dead_strip
L_OBJC_IMAGE_INFO:
	.long	0
	.long	64

.subsections_via_symbols
