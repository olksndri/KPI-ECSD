PROCESSOR 16F877A
#include <xc.inc>

; Configuration bits
config FOSC = HS, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF

; Reset Vector
PSECT resetVec, class=CODE, delta=2, abs
org 0x00
    goto start

PSECT code, class=CODE, delta=2, abs
org 0x05
global start

start:
    ; --- Step 1: Ports Initialization ---
    banksel TRISB
    bcf     TRISB, 1    ; RB1 as output
    bcf     TRISB, 3    ; RB3 as output
    
    banksel PORTB
    clrf    PORTB       ; Clear LEDs initially
    
    ; --- Step 2: Timer0 Initialization ---
    banksel OPTION_REG
    ; T0CS = 0 (Internal clock), PSA = 0 (Prescaler to TMR0)
    ; PS2:PS0 = 101 (1:64 ratio) 
    movlw   0x85        
    movwf   OPTION_REG
    
    banksel TMR0
    clrf    TMR0        ; Start timer from 0

main_loop:
    ; --- Step 3: Polling INTCON for overflow ---
    banksel INTCON
    btfss   INTCON, 2   ; Check T0IF flag
    goto    main_loop   ; Wait for overflow (FFh -> 00h)
    
    ; --- Step 4: Action on overflow ---
    bcf     INTCON, 2   ; Clear T0IF flag manually
    
    banksel PORTB
    ; Toggle/Turn on RB1 and RB3
    movlw   0x0A        ; Pattern for RB1 and RB3 (0000 1010)
    xorwf   PORTB, f    ; Toggle LEDs
    
    goto    main_loop   ; Repeat cycle

end

    
    
    