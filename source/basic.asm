; *******************************************************************************************c; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose : 	Basic start up
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

StartOfBasicCode:

		.include "temp/block.inc"					; block addresses/offsets.
		.include "temp/tokens.inc"					; tokens include file (generated)
		.include "data.asm" 						; data definition.
		.include "expression.asm" 					; expression evaluation
		.include "variable.asm"						; variable management
		.include "utility.asm"						; utility stuff.
		.include "stringutils.asm"					; string utility stuff.
		
		.include "binary/arithmetic.asm"			; binary operators
		.include "binary/bitwise.asm"
		.include "binary/comparison.asm"
		.include "binary/divide.asm"
		.include "binary/multiply.asm"
		.include "unary/simpleunary.asm" 			; unary functions.

		.include "commands/let.asm" 				; assignment
		.include "commands/run.asm" 				; run / end / clear etc.
		.include "commands/dim.asm"					; array dimension
		.include "commands/miscellany.asm"			; all other commands

IDTypeMask = $2000 									; bit masks in identifier.
IDArrayMask = $1000
IDContMask = $0800

UnaryFunction = 8 									; Unary function Token Type ID.
TokenShift = 9										; Token shift to reach precedence.

error	.macro
		jsr 	ErrorHandler 						; call error routine
		.text 	\1,$00 								; with this message
		.endm

; *******************************************************************************************
;
;							Enter BASIC / switch to new instance
;
;	A 	should be set to the page number (e.g. the upper 8 bits)
;	X 	is the base address of the BASIC workspace (lower 16 bits)
;	Y 	is the end address of the BASIC workspace (lower 16 bits)
;
;	Assumes S and DP are set. DP memory is used but not saved on instance switching.
;
; *******************************************************************************************

SwitchBasicInstance:
		rep 	#$30 								; 16 bit A:X mode.
		and 	#$00FF 								; make page number 24 bit
		sta 	DPageNumber 						; save page, base, high in RAM.
		stx		DBaseAddress
		sty 	DHighAddress

		xba 										; put the page number (goes in the DBR) in B
		pha 										; then copy it into B.
		plb
		plb 

		jmp 	Function_RUN
