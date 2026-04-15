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
    banksel TRISB
    clrf    TRISB       ; First, set all pins to output mode (0)
    bsf     TRISB, 0    ; Now, set RB0 to input mode (1)
    banksel TRISC
    clrf    TRISC       ; PORTC as output (Control & PWM)
    
    ; --- Step 2: PWM Initialization (Buzzer) ---
    banksel PR2
    movlw   0xFF        ; Set PWM period
    movwf   PR2
    banksel CCPR1L
    movlw   0x7F        ; 50% duty cycle
    movwf   CCPR1L
    banksel T2CON
    movlw   0x04        ; Timer2 ON, Prescaler 1:1
    movwf   T2CON
    
    ; --- Step 3: Timer0 Initialization (Polling mode) ---
    banksel OPTION_REG
    movlw   0x07        ; Internal clock, Prescaler 1:256 to TMR0
    movwf   OPTION_REG
    
    banksel PORTB
    call    LCD_INIT

check_object:
    banksel TMR0
    clrf    TMR0        ; Reset timer window
    banksel INTCON
    bcf     INTCON, 2   ; Clear T0IF

wait_loop:
    ; Check if button RB0 is pressed (Object is ALIVE)
    banksel PORTB
    btfss   PORTB, 0
    goto    object_ok
    
    ; Check if time expired (TMR0 overflow)
    banksel INTCON
    btfsc   INTCON, 2   ; Check T0IF
    goto    object_failed
    
    goto    wait_loop

object_ok:
    ; Stop buzzer if it was on
    banksel CCP1CON
    clrf    CCP1CON     
    ; Show message on LCD
    call    LCD_CLEAR
    movlw   'O'         ; "OK"
    call    LCD_DATA
    movlw   'K'
    call    LCD_DATA
    call    delay_long  ; Hold message
    goto    check_object

object_failed:
    ; Start sound signal (PWM mode)
    banksel CCP1CON
    movlw   0x0C        ; PWM mode active
    movwf   CCP1CON
    goto    check_object

; --- LCD Helper Subroutines ---
LCD_INIT:
    movlw   0x38        ; 8-bit, 2-line
    call    LCD_CMD
    movlw   0x0C        ; Display ON
    call    LCD_CMD
    return

LCD_CLEAR:
    movlw   0x01
    call    LCD_CMD
    return

LCD_CMD:
    movwf   PORTB
    banksel PORTC
    bcf     PORTC, 0    ; RS = 0
    bsf     PORTC, 3    ; E = 1 (Using RC3 to avoid PWM conflict on RC2)
    nop
    bcf     PORTC, 3    ; E = 0
    call    delay_long
    return

LCD_DATA:
    movwf   PORTB
    banksel PORTC
    bsf     PORTC, 0    ; RS = 1
    bsf     PORTC, 3    ; E = 1
    nop
    bcf     PORTC, 3    ; E = 0
    call    delay_long
    return

delay_long:
    movlw   10
    movwf   d1
d_l: movlw 255
    movwf   d2
d_i: decfsz d2, f
    goto d_i
    decfsz d1, f
    goto d_l
    return

end


