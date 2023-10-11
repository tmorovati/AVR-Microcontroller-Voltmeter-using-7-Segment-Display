;
; transmit.asm
;
; Created: 6/17/2020 11:04:32 PM
; Author : Asus
;


; in this program we want to read data from voltage-meter and send it to another micro using usart protocols 
; baud-rate = 4800 - 8bit data - 1stop bit - for 1mhz micro 

.include "m16def.inc"

ldi r16 , (1 << TXEN)
out ucsrb , r16 
ldi r16 , (1 << ucsz1) | (1 << ucsz0 ) | (1 << ursel) |(1 << ucpol )
out ucsrc , r16 
ldi r16 , 0x33 
out ubrrl , r16 


ldi r16 , 0 
out ddra , r16 ;PORTA is input 
ldi r16 , 0xff 
out porta , r16 ; enable pull-ups 
out ddrc , r16 ; portc output

main : 
	in  r17, pina  
	sbis ucsra , udre
	rjmp main 
	out udr , r17
	out portc , r17 
	rjmp main 
