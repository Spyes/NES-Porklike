.scope Player
    .proc Init
        LDA #16
        STA PlayerX
        LDA #16
        STA PlayerY
        
        LDA #0
        STA PlayerOffsetX
        STA PlayerOffsetY

        LDA #10
        STA PlayerAnimTimer

        RTS
    .endproc

    .proc Update
        DEC PlayerAnimTimer
        LDA PlayerOffsetX
        BNE :+
            LDA PlayerOffsetY
            BEQ @GetInput
        :

        LDA PlayerOffsetX
        BEQ :+
            BPL @XOffsetGreaterThan0
            BMI @XOffsetLessThan0
        :

        LDA PlayerOffsetY
        BEQ :+
            BPL @YOffsetLessThan0
            BMI @YOffsetGreaterThan0
        :

        JMP @EndUpdate

        @XOffsetGreaterThan0:
            DEC PlayerOffsetX
            JMP @EndUpdate
        @XOffsetLessThan0:
            INC PlayerOffsetX
            JMP @EndUpdate
        @YOffsetLessThan0:
            DEC PlayerOffsetY
            JMP @EndUpdate
        @YOffsetGreaterThan0:
            INC PlayerOffsetY
            JMP @EndUpdate
    
        @GetInput:
            JSR GetInput

        @EndUpdate:
        RTS
    .endproc

    .proc Draw
        JSR Animate
        LDA PlayerX
        CLC
        ADC PlayerOffsetX
        CLC
        STA $0203
        LDA PlayerY
        CLC
        ADC PlayerOffsetY
        SEC
        SBC #1
        STA $0200
        RTS
    .endproc

    .proc GetInput
        LDA Buttons
        AND #BUTTON_LEFT
        BEQ @NotLeftButton
            LDA PrevButtons
            CMP Buttons
            BEQ @LeftButtonPrevPressed
                LDA $0202
                ORA #%01000000      ; Flip sprite horizontally
                STA $0202
                LDA PlayerX
                SEC
                SBC #8
                STA PlayerX
                LDX PlayerX
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoCollisionLeft
                    LDA PlayerX
                    CLC
                    ADC #8
                    STA PlayerX
                    LDA #%11111100
                    STA PlayerOffsetX           ; PlayerOffsetX = -4
                    JMP @EndGetInput
                @NoCollisionLeft:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectLeft
                        TAX
                        JSR Objects::Bump
                        LDA PlayerX
                        CLC
                        ADC #8
                        STA PlayerX
                        LDA #%11111100
                        STA PlayerOffsetX
                        JMP @EndGetInput
                @NoObjectLeft:
                    LDA #8
                    STA PlayerOffsetX           ; PlayerOffsetX = 8
                    JMP @EndGetInput
            @LeftButtonPrevPressed:
        @NotLeftButton:

        LDA Buttons
        AND #BUTTON_RIGHT
        BEQ @NotRightButton
            LDA PrevButtons
            CMP Buttons
            BEQ @RightButtonPrevPressed
                LDA $0202
                AND #%10111111      ; Unflip sprite horizontally
                STA $0202
                LDA PlayerX
                CLC
                ADC #8         
                STA PlayerX
                LDX PlayerX
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoCollisionRight
                    LDA PlayerX
                    SEC
                    SBC #8
                    STA PlayerX
                    LDA #4
                    STA PlayerOffsetX
                    JMP @EndGetInput
                @NoCollisionRight:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectRight
                        TAX
                        JSR Objects::Bump
                        LDA PlayerX
                        SEC
                        SBC #8
                        STA PlayerX
                        LDA #4
                        STA PlayerOffsetX
                        JMP @EndGetInput
                    @NoObjectRight:
                        LDA #%11111000
                        STA PlayerOffsetX           ; PlayerOffsetX = -8
                        JMP @EndGetInput
            @RightButtonPrevPressed:
        @NotRightButton:
 
        LDA Buttons
        AND #BUTTON_UP
        BEQ @NotUpButton
            LDA PrevButtons
            CMP Buttons
            BEQ @UpButtonPrevPressed
                LDA PlayerY
                SEC
                SBC #8
                STA PlayerY
                LDX PlayerX 
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoCollisionUp
                    LDA PlayerY
                    CLC
                    ADC #8
                    STA PlayerY
                    LDA #%11111100
                    STA PlayerOffsetY
                    JMP @EndGetInput
                @NoCollisionUp:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectUp
                        TAX
                        JSR Objects::Bump
                        LDA PlayerY
                        CLC
                        ADC #8
                        STA PlayerY
                        LDA #%11111100
                        STA PlayerOffsetY
                        JMP @EndGetInput
                @NoObjectUp:
                    LDA #8
                    STA PlayerOffsetY
                    JMP @EndGetInput
            @UpButtonPrevPressed:
        @NotUpButton:

        LDA Buttons
        AND #BUTTON_DOWN
        BEQ :+
            LDA PrevButtons
            CMP Buttons
            BEQ :+
                LDA PlayerY
                CLC
                ADC #8
                STA PlayerY
                LDX PlayerX
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoCollisionDown
                    LDA PlayerY
                    SEC
                    SBC #8
                    STA PlayerY
                    LDA #4
                    STA PlayerOffsetY
                    JMP @EndGetInput
                @NoCollisionDown:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectDown
                        TAX
                        JSR Objects::Bump
                        LDA PlayerY
                        SEC
                        SBC #8
                        STA PlayerY
                        LDA #4
                        STA PlayerOffsetY
                        JMP @EndGetInput
                @NoObjectDown:
                    LDA #%11111000
                    STA PlayerOffsetY
                    JMP @EndGetInput
            :
        :

        @EndGetInput:
        RTS
    .endproc

    .proc Animate
        LDA PlayerAnimTimer
        BNE @EndAnimate
            LDX $0201
            INX
            CPX #4
            BNE @SetTile
                LDX #1
            @SetTile:
                STX $0201
                LDA #10
                STA PlayerAnimTimer
        @EndAnimate:
        RTS
    .endproc
.endscope