.scope Text

    .proc Length
        LDY #0
        @Loop:
            LDA (ParamPtr),Y            ; LDA sets the Z flag if the result is 0
            BEQ @Break                  ; if A is zero (Z-flag is 1) break out of loop

        @DrawLetter:
            STA PPU_DATA
        @NextLetter:
            INY                         ; Y++
            JMP @Loop

        @Break:
        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to load text in the nametable until it finds a 0-terminator
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc LoadText
        BIT PPU_STATUS                  ; Read from PPU_ADDR to reset address latch
        LDA #$22
        STA PPU_ADDR
        LDA #$42
        STA PPU_ADDR

        LDY #0
        @Loop:
            LDA (ParamPtr),Y            ; LDA sets the Z flag if the result is 0
            BEQ @Break                  ; if A is zero (Z-flag is 1) break out of loop

        @DrawLetter:
            STA PPU_DATA
        @NextLetter:
            INY                         ; Y++
            JMP @Loop

        @Break:
        RTS
    .endproc

.endscope