PROCESSOR 16F877A
#include <xc.inc>

; Configuration bits: High-speed crystal, Watchdog off, Power-up timer on
config FOSC = HS, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF

; Variable definitions in common memory
PSECT udata_shr, class=COMMON, space=1, delta=1
temp_data: DS 1         ; Buffer for verification read

; Reset Vector - absolute address 0x00
PSECT resetVec, class=CODE, delta=2, abs
org 0x00
    goto start

; Main Code - absolute address 0x05 to ensure debugger synchronization
PSECT code, class=CODE, delta=2, abs
org 0x05
global start

start:
    ; --- STEP 1: WRITE DATA 0x06 TO EEPROM ADDRESS 0x10 ---
    
    banksel EEADR       ; Switch to Bank 2
    movlw   0x10        ; Load target EEPROM address
    movwf   EEADR       ; Set EEADR (10Dh)
    movlw   0x06        ; Load data value (Variant 6)
    movwf   EEDATA      ; Set EEDATA (10Ch)
    
    banksel EECON1      ; Switch to Bank 3
    bcf     EECON1, 7   ; EEPGD = 0: Select EEPROM data memory
    bsf     EECON1, 2   ; WREN = 1: Enable write cycle
    
    ; Required unlock sequence (must be performed with interrupts disabled)
    bcf     INTCON, 7   ; GIE = 0: Disable global interrupts
    movlw   0x55        ; Mandatory sequence byte 1
    movwf   EECON2
    movlw   0xAA        ; Mandatory sequence byte 2
    movwf   EECON2
    bsf     EECON1, 1   ; WR = 1: Initiate write operation
    bsf     INTCON, 7   ; GIE = 1: Re-enable interrupts
    
    ; Wait for write completion (WR bit is cleared by hardware)
ee_wait:
    btfsc   EECON1, 1   ; Check if WR bit is still set
    goto    ee_wait     ; Busy wait until write is finished
    
    bcf     EECON1, 2   ; WREN = 0: Disable further writes

    ; --- STEP 2: READ BACK FOR VERIFICATION ---
    
    banksel EEADR       ; Switch to Bank 2
    movlw   0x10        ; Set address to read from
    movwf   EEADR
    
    banksel EECON1      ; Switch to Bank 3
    bcf     EECON1, 7   ; EEPGD = 0: Select EEPROM
    bsf     EECON1, 0   ; RD = 1: Initiate read operation
    
    banksel EEDATA      ; Switch to Bank 2
    movf    EEDATA, W   ; Read resulting byte into W register
    
    banksel temp_data   ; Return to variables bank
    movwf   temp_data   ; Store for debugging/verification

main_loop:
    goto    main_loop   ; Infinite loop

end