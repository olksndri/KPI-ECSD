PROCESSOR 16F877A
#include <xc.inc>

; Configuration bits
config FOSC = HS, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF

; Variable definitions in Access Bank (Shared memory)
PSECT udata_shr, class=COMMON, space=1, delta=1
d1:       DS 1          ; Delay counter 1
d2:       DS 1          ; Delay counter 2
char_pos: DS 1          ; Counter for shifts

; Reset Vector
PSECT resetVec, class=CODE, delta=2, abs
org 0x00
    goto start

PSECT code, class=CODE, delta=2
global start

start:
    ; --- Ports initialization ---
    banksel TRISB       
    clrf    TRISB       ; PORTB as output (LCD D0-D7)
    clrf    TRISC       ; PORTC as output (Control: RC0=RS, RC1=RW, RC2=E)
    
    banksel PORTB
    call    LCD_INIT    ; Setup LCD parameters

    ; Print initial text
    movlw   'O'
    call    LCD_DATA
    movlw   '.'
    call    LCD_DATA
    movlw   ' '
    call    LCD_DATA
    movlw   'T'
    call    LCD_DATA
    movlw   'Y'
    call    LCD_DATA
    movlw   'M'
    call    LCD_DATA
    movlw   'O'
    call    LCD_DATA
    movlw   'S'
    call    LCD_DATA
    movlw   'H'
    call    LCD_DATA
    movlw   'E'
    call    LCD_DATA
    movlw   'N'
    call    LCD_DATA
    movlw   'K'
    call    LCD_DATA
    movlw   'O'
    call    LCD_DATA

main_loop:
    ; Move Right 16 times
    movlw   16
    movwf   char_pos
move_r_loop:
    movlw   0x1C        ; Command: Shift display right
    call    LCD_CMD
    call    delay_ms
    decfsz  char_pos, f
    goto    move_r_loop

    ; Move Left 16 times
    movlw   16
    movwf   char_pos
move_l_loop:
    movlw   0x18        ; Command: Shift display left
    call    LCD_CMD
    call    delay_ms
    decfsz  char_pos, f
    goto    move_l_loop

    goto    main_loop

; --- LCD Subroutines ---

LCD_INIT:
    movlw   0x38        ; 8-bit mode, 2 lines, 5x7 font
    call    LCD_CMD
    movlw   0x0C        ; Display ON, Cursor OFF
    call    LCD_CMD
    movlw   0x01        ; Clear Display
    call    LCD_CMD
    call    delay_ms
    return

LCD_CMD:
    movwf   PORTB       ; Send command to PORTB
    bcf     PORTC, 0    ; RS = 0 (Instruction)
    bcf     PORTC, 1    ; RW = 0 (Write)
    bsf     PORTC, 2    ; E = 1 (Enable)
    nop
    bcf     PORTC, 2    ; E = 0 (Disable)
    call    delay_ms
    return

LCD_DATA:
    movwf   PORTB       ; Send data to PORTB
    bsf     PORTC, 0    ; RS = 1 (Data)
    bcf     PORTC, 1    ; RW = 0 (Write)
    bsf     PORTC, 2    ; E = 1 (Enable)
    nop
    bcf     PORTC, 2    ; E = 0 (Disable)
    call    delay_ms
    return

; Delay for simulation visibility
;delay_ms:
;    movlw   255
;    movwf   d1   
;d_loop:
;    movlw   255
;    movwf   d2
delay_ms:
    movlw   2       ; Just a few cycles instead of 255
    movwf   d1
d_loop:
    decfsz  d1, f
    goto    d_loop
    return
d_inner:
    decfsz  d2, f
    goto    d_inner
    decfsz  d1, f
    goto    d_loop
    return

end