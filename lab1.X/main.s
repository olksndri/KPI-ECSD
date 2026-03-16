; Variant 6
; Press switch S2 to turn on diode RB1; press switch S3 to turn off all diodes.

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
    bsf     TRISA, 4    ; RA4 (S2) at the input
    bsf     TRISB, 0    ; RB0 (S3) at the input
    bcf     TRISB, 1    ; RB1 (diode) at the output
    
    banksel PORTA       ; Return to the bank 0
    clrf    PORTB       ; Turn off all diodes at startup

wait_s2:
    ; Waiting for S2 (RA4) to be pressed
    btfsc   PORTA, 4    ; Check the bit. If 0 (pressed) - skip GOTO 
    goto    wait_s2     ; Button not pressed -> loop

    bsf     PORTB, 1    ; Turn on diode RB1

wait_s3:
    ;  Waiting for S3 (RB0) to be pressed
    btfsc   PORTB, 0    ; Check bit 0 of port B
    goto    wait_s3     
    
    clrf    PORTB       ; Turn off all diodes
    goto    wait_s2     ; Back to top

end