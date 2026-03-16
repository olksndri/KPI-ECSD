PROCESSOR 16F877A
#include <xc.inc>

; Configuration
config FOSC = HS, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF

; Reset Vector - address 0
PSECT resetVec, class=CODE, delta=2, abs
org 0x00
    goto start

PSECT code, class=CODE, delta=2
global start
start:
    ; --- Ports initialization ---
    banksel TRISA       ; Select Bank 1 to set the direction
    bsf	    TRISA, 0	; Set as input '1' 
    bcf	    TRISB, 0	; Set as output '0' 

    banksel PORTA       ; Return to the bank 0
    clrf    PORTB       ; Turn off all diodes at startup

loop:
    btfsc   PORTA, 0    ; Check the bit. If 0 (pressed) - skip GOTO 
    goto    loop	; Button not pressed -> loop

    btfsc   PORTB, 0    ; If diode is 0: skip GOTO set0 and GOTO set1
    goto    set0	; Set 0 
    goto    set1	; Set 0 

set0: 
    bcf	    PORTB, 0
    goto    loop

set1: 
    bsf	    PORTB, 0
    goto    loop


end