.scope Player
    .proc Init
        LDA #16
        STA PlayerX
        LDA #16
        STA PlayerY
        
        LDA #0
        STA PlayerOffsetX
        STA PlayerOffsetY

        LDA #%01010011
        STA PlayerHP

        LDA #%00010001
        STA PlayerAtkDef
        JSR GFX::BufferPlayerStats

        RTS
    .endproc

    .proc Update
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
                JSR GFX::ClearText
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
                BEQ @NoMapCollisionLeft
                    EJECT_PLAYER_RIGHT
                @NoMapCollisionLeft:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectCollisionLeft
                        TAX
                        JSR Objects::Bump
                        EJECT_PLAYER_RIGHT
                @NoObjectCollisionLeft:
                    JSR Mobs::IsAtXY
                    CMP #%11111111
                    BEQ @NoMobCollisionLeft
                        JSR AttackMob
                        EJECT_PLAYER_RIGHT
                @NoMobCollisionLeft:
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
                JSR GFX::ClearText
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
                BEQ @NoMapCollisionRight
                    EJECT_PLAYER_LEFT
                @NoMapCollisionRight:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectCollisionRight
                        TAX
                        JSR Objects::Bump
                        EJECT_PLAYER_LEFT
                    @NoObjectCollisionRight:
                        JSR Mobs::IsAtXY
                        CMP #%11111111
                        BEQ @NoMobCollisionRight
                            JSR AttackMob
                            EJECT_PLAYER_LEFT
                    @NoMobCollisionRight:
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
                JSR GFX::ClearText
                LDA PlayerY
                SEC
                SBC #8
                STA PlayerY
                LDX PlayerX 
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoMapCollisionUp
                    EJECT_PLAYER_DOWN
                @NoMapCollisionUp:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectCollisionUp
                        TAX
                        JSR Objects::Bump
                        EJECT_PLAYER_DOWN
                @NoObjectCollisionUp:
                    JSR Mobs::IsAtXY
                    CMP #%11111111
                    BEQ @NoMobCollisionUp
                        JSR AttackMob
                        EJECT_PLAYER_DOWN
                @NoMobCollisionUp:
                    LDA #8
                    STA PlayerOffsetY
                    JMP @EndGetInput
            @UpButtonPrevPressed:
        @NotUpButton:

        LDA Buttons
        AND #BUTTON_DOWN
        BEQ @NotDownButton
            LDA PrevButtons
            CMP Buttons
            BEQ @DownButtonPrevPressed
                JSR GFX::ClearText
                LDA PlayerY
                CLC
                ADC #8
                STA PlayerY
                LDX PlayerX
                LDY PlayerY
                JSR Map::IsXYSolid
                BEQ @NoMapCollisionDown
                    EJECT_PLAYER_UP
                @NoMapCollisionDown:
                    LDA PlayerX
                    STA ParamXPos
                    LDA PlayerY
                    STA ParamYPos
                    JSR Objects::IsAtXY
                    CMP #%11111111
                    BEQ @NoObjectCollisionDown
                        TAX
                        JSR Objects::Bump
                        EJECT_PLAYER_UP
                @NoObjectCollisionDown:
                    JSR Mobs::IsAtXY
                    CMP #%11111111
                    BEQ @NoMobCollisionDown
                        JSR AttackMob
                        EJECT_PLAYER_UP
                @NoMobCollisionDown:
                    LDA #%11111000
                    STA PlayerOffsetY
                    JMP @EndGetInput
            @DownButtonPrevPressed:
        @NotDownButton:

        @EndGetInput:
        RTS
    .endproc

    .proc Animate
        LDA AnimTimer
        BNE @EndAnimate
            LDX $0201
            INX
            CPX #5
            BNE @SetTile
                LDX #1
            @SetTile:
                STX $0201
        @EndAnimate:
        RTS
    .endproc

    .proc AttackMob
        PHA
        TAX                 ; A holds Mob index
        LDA PlayerAtkDef
        LSR
        LSR
        LSR
        LSR
        STA ParamAtkDef
        JSR Mobs::Hit
        LDA MobsArray+SMob::AtkDef,X
        LSR
        LSR
        LSR
        LSR
        STA Temp
        LDA PlayerHP
        SEC
        SBC Temp
        STA PlayerHP        ;; TODO: die

        JSR GFX::BufferPlayerStats

        LDA #>AttackedMob
        STA ParamPtr+1
        LDA #<AttackedMob
        STA ParamPtr+0
        JSR GFX::BufferLine1Text

        LDA #>GotHit
        STA ParamPtr+1
        LDA #<GotHit
        STA ParamPtr+0
        JSR GFX::BufferLine2Text

        PLA
        TAX
        LDA MobsArray+SMob::Type,X
        BNE @MobStillAlive
            LDA #>KilledMob
            STA ParamPtr+1
            LDA #<KilledMob
            STA ParamPtr+0
            JSR GFX::BufferLine3Text
        @MobStillAlive:

        RTS
    .endproc
.endscope