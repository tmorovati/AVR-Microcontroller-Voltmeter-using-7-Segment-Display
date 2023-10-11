;
; receive.asm
;
; Created: 6/17/2020 11:24:45 PM
; Author : Asus
;


; in this application we want to receive data from another micro using usaurt protocol and then convert it from analog to digital 
; and show it on 7segment 

.include "m16def.inc"

ldi r16 , (1 << RXEN)
out ucsrb , r16 
ldi r16 , (1 << ucsz1) | (1 << ucsz0 ) | (1 << ursel) | (1 << ucpol )
out ucsrc , r16 
ldi r16 , 0x33 
out ubrrl , r16 

ldi r16 , 0xff 
out ddra , r16  ;output porta
out ddrb , r16  ;outputs portb 
cbi ddrd , 0 
sbi portd , 0  ; receiver
ldi r16 , 0 
out ddrc , r16 
ldi r16 , 0xff
out portc , r16 ; input portc 


ldi r16 , 0x87
out adcsra , r16 
ldi r16 , 0xc0 
out admux , r16  ; adc setting 


.EQU FIRST=0XF7
.EQU SECOND=0XFB
.EQU THIRD=0XFD
.EQU FOURTH=0XFE  ; refreshing (on 4 sevensegment)

LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16			; SP SETTING

ldi r29 , 1 

main : 
	sbis ucsra , rxc 
	rjmp main 
	in r16 , udr 
	;out porta , r16
	sbi adcsra , adsc 
	call AD_converter
	rjmp main 

	AD_converter:
			sbis adcsra , adif 
			rjmp AD_converter
			sbi adcsra , adif 
			in r20 , adcl
			in r23 , adch
			call check_first_key
			check_second_key:
			sbic pinc , 1 
			rjmp back
			add r20 , r29  
			
			
			back:
			call sevenseg
			ret


check_first_key:
	sbic pinc , 0
	rjmp check_second_key
	cpi r20 , 25 
	brcs turn_on_lamp 
	ret 


turn_on_lamp:
	sbi portb , 7 
	rjmp back			

			
sevenseg:
LDI R27, 200
		LOOP1:
			LDI ZH, HIGH(JMP_TABLE)
			LDI ZL, LOW (JMP_TABLE)

			in r20 , adcl
			in r23 , adch 
			RCALL SEP
			RCALL SHOW
			DEC R27
			BRNE LOOP1
			ret




;---------------------SHOW--------------------
SHOW:
	ADD ZL, R21
	ADC ZH, R0
	RCALL RET_IJMP 
	LDI R18, FIRST
	RCALL SEG

	ADD ZL, R22
	ADC ZH, R0
	RCALL RET_IJMP 
	LDI R18, SECOND
	RCALL SEG

	ADD ZL, R24
	ADC ZH, R0
	RCALL RET_IJMP 
	LDI R18, THIRD
	RCALL SEG

	ADD ZL, R25
	ADC ZH, R0
	RCALL RET_IJMP  
	LDI R18, FOURTH
	RCALL SEG

RET_IJMP:
	IJMP
CON:
	LDI ZH, HIGH(JMP_TABLE)
	LDI ZL, LOW (JMP_TABLE)
	RET

SEG:
	OUT PORTA, R17
	OUT PORTB, R18
	RCALL DELAY	
	RET

;---------------------SEPRATE--------------------
SEP:
	MOV R21, R20
	ANDI R21, 0X0F
	MOV R22, R20
	SWAP R22
	ANDI R22, 0X0F

	MOV R24, R23
	ANDI R24, 0X0F
	MOV R25, R23
	SWAP R25
	ANDI R25, 0X0F
	
	RET	

;---------------------JUMP TABLE--------------------	
JMP_TABLE:
	RJMP ZERO
	RJMP ONE
	RJMP TWO
	RJMP THREE
	RJMP FOUR
	RJMP FIVE
	RJMP SIX
	RJMP SEVEN
	RJMP EIGHT
	RJMP NINE

ZERO:
	LDI R17, 0X3F
	RJMP CON
ONE:
	LDI R17, 0X06
	RJMP CON
TWO:
	LDI R17, 0X5B
	RJMP CON
THREE:
	LDI R17, 0X4F
	RJMP CON
FOUR:			  
	LDI R17, 0Xe6
	RJMP CON
FIVE:
	LDI R17, 0X6D
	RJMP CON
SIX:
	LDI R17, 0X7D
	RJMP CON
SEVEN:
	LDI R17, 0X03
	RJMP CON
EIGHT:
	LDI R17, 0X7F
	RJMP CON
NINE:
	LDI R17, 0X6F
	RJMP CON


;---------------------DELAY FUNC.--------------------
DELAY: 
	LDI R28, 30
L2:
	LDI R26, 255
L1:
	NOP
	NOP
	DEC R26
	BRNE L1
	DEC R28
	BRNE L2
	RET