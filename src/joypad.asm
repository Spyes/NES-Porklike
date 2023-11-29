.scope Joypad
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to handle reading joypad data
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc ReadController
        LDA #1                      ; A = 1
        STA Buttons                 ; Buttons = %00000001
        STA JOYPAD1                 ; Set Latch=1 to begin 'Input'/collection mode
        LSR                         ; %00000001 -> %00000000 , A = 0
        STA JOYPAD1                 ; Set Latch=0 to begin 'Output' mode
    @ReadControllersLoop:  
        LDA JOYPAD1                 ; Read a bit from the controller data line and invert
                                    ; And also send a signal to the Clock line to shift the bits
        LSR                         ; Shift-right to place that 1-bit we just read into the Carry value
        ROL Buttons                 ; Rotate bits left, placing the Carry value into the 1st bit of Buttons (%00000001 -> %00000010 -> %00000011)
        BCC @ReadControllersLoop

        RTS
    .endproc
.endscope