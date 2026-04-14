PROCESSOR 16F877A
#include <xc.inc>

; Configuration bits
config FOSC = HS, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF

; Variable definitions
PSECT udata_shr, class=COMMON, space=1, delta=1
d1:         DS 1
d2:         DS 1

; Reset Vector
PSECT resetVec, class=CODE, delta=2, abs
org 0x00
    goto start

PSECT code, class=CODE, delta=2, abs
org 0x05
global start

start:
    ; --- Step 1: Ports Initialization ---
    banksel TRISA
    bsf     TRISA, 0    ; RA0/AN0 as input
    clrf    TRISB       ; PORTB as output (LCD Data)
    clrf    TRISC       ; PORTC as output (LCD Control)
    
    ; --- Step 2: ADC Initialization ---
    banksel ADCON1
    ; ADFM=0 (Left justified), PCFG=1110 (AN0 analog, others digital)
    movlw   0x0E        
    movwf   ADCON1      ; [cite: 1753]
    
    banksel ADCON0
    ; Fosc/32 clock, Channel 0 (AN0), ADON=1
    movlw   0x81        
    movwf   ADCON0      ; [cite: 1751]
    
    banksel PORTB
    call    LCD_INIT

main_loop:
    ; --- Step 3: ADC Acquisition & Conversion ---
    call    delay_short ; Acquisition time (Tacq) 
    
    banksel ADCON0
    bsf     ADCON0, 2   ; Set GO/DONE bit to start 
    
wait_adc:
    btfsc   ADCON0, 2   ; Wait for GO/DONE to clear 
    goto    wait_adc
    
    ; --- Step 4: Display Result ---
    banksel ADRESH
    movf    ADRESH, W   ; Get 8 MSB bits (Left justified)
    
    call    LCD_DATA    ; Display binary value on PORTB
    
    goto    main_loop

; --- LCD Helper Subroutines ---
LCD_INIT:
    movlw   0x38
    call    LCD_CMD
    movlw   0x0C
    call    LCD_CMD
    return

LCD_CMD:
    movwf   PORTB
    bcf     PORTC, 0    ; RS = 0
    bsf     PORTC, 2    ; E = 1
    nop
    bcf     PORTC, 2    ; E = 0
    call    delay_short
    return

LCD_DATA:
    movwf   PORTB
    bsf     PORTC, 0    ; RS = 1
    bsf     PORTC, 2    ; E = 1
    nop
    bcf     PORTC, 2    ; E = 0
    call    delay_short
    return

delay_short:            ; Shortened for simulation speed
    movlw   2
    movwf   d1
d_l:
    movlw   10
    movwf   d2
d_i:
    decfsz  d2, f
    goto    d_i
    decfsz  d1, f
    goto    d_l
    return

end