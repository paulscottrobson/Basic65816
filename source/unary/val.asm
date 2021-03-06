; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		val.asm
;		Purpose : 	String to Integer
;		Date :		11th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									val(string,base)
;
; *******************************************************************************************

Function_VAL: 	;; val( 
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextString 			; get the value you are absoluting
		pha 								; put string address on stack.
		jsr 	VALGetBase 					; process , base (shared with STR$()) 					
		ply 								; get string address back
		phx 								; save X on stack
		tax 								; base in X
		tya 								; address in A
		jsr 	StringToInteger 
		plx 								; restore X
		sta 	EXSValueL+0,x
		sty 	EXSValueH+0,x
		rts

; *******************************************************************************************
;
;								Get Base. either ,Base) or )
;
; *******************************************************************************************

VALGetBase:
		lda 	(DCodePtr)					; look at next
		cmp 	#commaTokenID 				; if comma, go to get base code.
		beq 	_VGBAlternate
		jsr 	ExpectRightBracket			; expect ), and return 10.
		lda 	#10
		rts
;
;		found ,base, means base other than 10.
;

_VGBAlternate:
		jsr 	ExpectComma 				; skip comma.
		jsr 	EvaluateNextInteger 		; get base
		cpy 	#0							; check base legal
		bne 	_VGBBadBase 				
		cmp 	#2
		bcc 	_VGBBadBase
		cmp 	#16+1						; 0-9A-F
		bcs 	_VGBBadBase
		jsr 	ExpectRightBracket 			; get right bracket and return.
		rts
;
_VGBBadBase:
		#error 	"Bad Number Base"

; *******************************************************************************************
;
;		   Convert string at A base X and return in YA, error message if illegal.
;
; *******************************************************************************************

StringToInteger:
		sta 	DTemp3 						; DTemp3 is the character pointer
		lda 	(DTemp3)					; DTemp3+2 is the character count to do.
		and 	#$00FF
		sta 	DTemp3+2		
		beq 	_STIError 					; if length zero it's bad.
		inc 	DTemp3 						; skip length byte.
		;
		stx 	DSignCount 					; Signcount is the base, 2-16.
		stz 	DTemp1 						; Zero DTemp1, this is the result register.
		stz 	DTemp1+2
		;
		;		See if it is -something
		;
		lda 	(DTemp3)					; look at first character
		and 	#$00FF 						; mask off
		pha 								; push on stack
		cmp 	#"-"						; if not -, skip
		bne 	_STILoop
		inc 	DTemp3 						; advance pointer over minus sign
		dec 	DTemp3+2					; dec count
		beq 	_STIError 					; if only - then error.
		;
		;		Scan string loop
		;
_STILoop:		
		lda 	DSignCount 					; multiply DTemp1 by DSignCount
		jsr 	MultiplyTemp1ByA
		;
		lda 	(DTemp3)					; get character, mask
		and 	#$00FF
		jsr 	ConvertUpperCase	 		; make U/C
		;
		cmp 	#'0' 						; validate it check if 0-9
		bcc 	_STIError
		cmp 	#'9'+1
		bcc 	_STIOkay1
		cmp 	#'A' 						; check if A-Z
		bcc 	_STIError
		cmp 	#'Z'+1
		bcs 	_STIError
		clc 								; shift to correct range.
		adc 	#9
_STIOkay1:
		and 	#15 						; now in range 0-35
		cmp 	DSignCount 					; error if >= base
		bcs 	_STIError
		;
		;		Add digit into return value.
		;
		clc 								; add A to DTemp1
		adc 	DTemp1
		sta 	DTemp1
		bcc 	_STINoCarry
		inc 	DTemp1+2
_STINoCarry:
		inc 	DTemp3 						; get character, pre-increment because of count byte
		dec 	DTemp3+2 					; decrement counter
		bne 	_STILoop 					; loop back.
		pla 								; get optional minus bac
		cmp 	#"-"
		bne 	_STINotNegative 			; handle the negative character
		sec 								; negate DTemp1
		lda 	#0 
		sbc 	DTemp1
		sta 	DTemp1
		lda 	#0 
		sbc 	DTemp1+2
		sta 	DTemp1+2
_STINotNegative:		
		lda 	DTemp1 						; get the result
		ldy 	DTemp1+2
		rts

_STIError:
		#error 	"Bad constant"

; *******************************************************************************************
;
;									Convert A to upper case
;
; *******************************************************************************************

ConvertUpperCase:
		cmp 	#'a'
		bcc 	_CUCExit
		cmp 	#'z'+1
		bcs 	_CUCExit
		sec
		sbc 	#32
_CUCExit:
		rts

; *******************************************************************************************
;
;						Multiply DTemp1 by A (uses DTemp2), CS on overflow.
;
; *******************************************************************************************

MultiplyTemp1ByA:

_MTGeneral:
		phx
		tax 								; multiplier in X
		lda 	DTemp1 						; copy DTemp1 to DTemp2
		sta 	DTemp2
		lda 	DTemp1+2
		sta 	DTemp2+2
		stz 	DTemp1 						; zero DTemp1
		stz 	DTemp1+2 					
		ldy 	#0 		 					; this is the 'high byte' of the result.
		;
		;		Main multiply loop.
		;
_MTLoop:
		txa 								; shift X right into C 
		lsr 	a
		tax
		bcc 	_MTNoAdd
		clc
		lda 	DTemp1 						; add if LSB set
		adc 	DTemp2
		sta 	DTemp1		
		lda 	DTemp1+2
		adc 	DTemp2+2
		sta 	DTemp1+2	
		bcc 	_MTNoAdd
		iny
_MTNoAdd:
		asl 	DTemp2  					; shift multiplicand left
		rol 	DTemp2+2
		bcc 	_MTNoOverflow
		iny
_MTNoOverflow:
		txa 								; until multiplier is zero.
		bne 	_MTLoop
		tya
		clc
		adc 	#$FFFF
		plx 								; restore X
		rts 								; and exit
