; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		transfer.asm
;		Purpose : 	GOTO, GOSUB, RETURN, ON expr GOTO 
;		Date :		12th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									GOTO <line number>
;
; *******************************************************************************************

Function_GOTO: ;; goto
		lda 	(DCodePtr) 					; look at the number
		cmp 	#$4000						; range 4000-BFFF
		bcc 	_FGOFail
		cmp 	#$C000
		bcs 	_FGOFail
		sec 								; convert to 0-32767
		sbc 	#$4000 						; and put in X.
		tax
		;
		lda 	#Block_ProgramStart 		; start of program.
		clc
		adc 	DBaseAddress 				; into Y
		tay
		;
_FGOSearch:
		lda 	$0000,y 					; look at link , exit if zero.
		beq 	_FGOUnknown
		txa 								; does it match line number.
		cmp 	$0002,y 					
		beq 	_FGOFound 					; yes, then found.
		tya 								; no follow the link
		clc
		adc 	$0000,y 					
		tay
		bra 	_FGOSearch
		;
_FGOFound:
		sta 	DLineNumber 				; store as new line number
		tya 								; Y + 4 is the code pointer.
		clc
		adc 	#4
		sta 	DCodePtr 					
		rts									; and continue
		;
_FGOFail:
		#error 	"Bad Line Number"
_FGOUnknown:
		#error 	"Unknown Line Number"				

; *******************************************************************************************
;
;									GOSUB <line number>
;
; *******************************************************************************************

Function_GOSUB: ;; gosub
		ldx 	DStack 						; point Y to the stack.
		;
		lda 	DCodePtr 					; save code ptr at +0 , 2 added to skip line number
		clc
		adc 	#2
		sta 	$02,x 						; save pos at +2
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		lda 	#gosubTokenID 				; save gosub token at +6
		sta 	$06,x

		txa 								; advance stack by 6.
		clc
		adc 	#6
		sta 	DStack

		bra 	Function_GOTO 				; and do a GOTO.

; *******************************************************************************************
;
;											RETURN
;
; *******************************************************************************************

Function_RETURN: ;; return
		ldx 	DStack
		lda 	$00,x
		cmp 	#gosubTokenID 				; check top token.		
		bne 	_FRetFail
		txa 								; unpick stack.
		sec
		sbc 	#6
		sta 	DStack
		tax
		lda 	$02,x 						; copy code pointer out.
		sta 	DCodePtr
		lda 	$04,x 						; copy line number out
		sta 	DLineNumber
		rts

_FRetFail:
		#error 	"Return without Gosub"