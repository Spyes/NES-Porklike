.scope Mobs

    .proc Add
        LDX #0
        @ArrayLoop:
            CPX #MAX_MOBS * .sizeof(SMob)
            BEQ @EndRoutine

            LDA MobsArray+SMob::Type,X
            CMP #MobType::NULL
            BEQ @AddNewMob

            @NextMob:
                TXA
                CLC
                ADC #.sizeof(SMob)
                TAX
                JMP @ArrayLoop
        
        @AddNewMob:
            LDA ParamType
            STA MobsArray+SMob::Type,X
            STA MobsArray+SMob::Tile,X
            LDA ParamXPos
            STA MobsArray+SMob::XPos,X
            LDA ParamYPos
            STA MobsArray+SMob::YPos,X
            LDA ParamHP
            STA MobsArray+SMob::HP,X
            LDA ParamAtkDef
            STA MobsArray+SMob::AtkDef,X

        @EndRoutine:
            RTS
    .endproc

    .proc Update
        LDX #0
        @ArrayLoop:
            CPX #MAX_MOBS * .sizeof(SMob)
            BEQ @EndLoop

            LDA MobsArray+SMob::Type,X
            BEQ @NextMob

            ;; TODO: Add mob brain here

            @NextMob:
                TXA
                CLC
                ADC #.sizeof(SMob)
                TAX
                JMP @ArrayLoop
        @EndLoop:

        RTS
    .endproc

    .proc Draw
        LDA #$02
        STA SprPtr+1
        LDA #$40
        STA SprPtr+0

        LDX #0
        LDY #0
        @ArrayLoop:
            CPX #MAX_MOBS * .sizeof(SMob)
            BEQ @EndLoop

            LDA MobsArray+SMob::Type,X
            BEQ @NextMob

            LDA AnimTimer
            BNE @EndAnimate
                LDA MobsArray+SMob::Type,X
                CLC
                ADC #4
                STA Temp
                LDA MobsArray+SMob::Tile,X
                CLC
                ADC #1
                CMP Temp
                BNE @SetTile
                    LDA MobsArray+SMob::Type,X
                @SetTile:
                    STA MobsArray+SMob::Tile,X
            @EndAnimate:

            LDA MobsArray+SMob::YPos,X
            SEC
            SBC #1
            STA ParamYPos
            LDA MobsArray+SMob::Tile,X
            STA ParamTileNum
            LDA #%00000011
            STA ParamAttribs
            LDA MobsArray+SMob::XPos,X
            STA ParamXPos
            JSR GFX::DrawSprite

            @NextMob:
                TXA
                CLC
                ADC #.sizeof(SMob)
                TAX
                JMP @ArrayLoop
        @EndLoop:

        ;; Clear out previously set tiles - we do this by checkig whether we
        ;; drew more tiles last run and zeroing out the sprite data
        TYA             ; Y has number of bytes sent to OAM
        PHA
        @LoopTrailingTiles:
            CPY PrevMobsOAMCount
            BCS :+      ; if we are less than the total previously sent
                LDA #$FF
                STA (SprPtr),Y
                INY
                STA (SprPtr),Y
                INY
                STA (SprPtr),Y
                INY
                STA (SprPtr),Y
                INY
                JMP @LoopTrailingTiles
            :
        PLA
        STA PrevMobsOAMCount
        
        RTS
    .endproc

    .proc IsAtXY
        LDX #0
        @ArrayLoop:
            CPX #MAX_MOBS * .sizeof(SMob)
            BNE :+
                LDA #%11111111
                JMP @EndRoutine
            :

            LDA MobsArray+SMob::Type,X
            BEQ @NextMob

            LDA MobsArray+SMob::XPos,X
            CMP ParamXPos
            BNE @NextMob
                LDA MobsArray+SMob::YPos,X
                CMP ParamYPos
                BNE @NextMob
                    TXA
                    JMP @EndRoutine

            @NextMob:
                TXA
                CLC
                ADC #.sizeof(SMob)
                TAX
                JMP @ArrayLoop

        @EndRoutine:
        RTS
    .endproc

    .proc Hit
        CPX #MAX_OBJECTS * .sizeof(SObject)
        BCS @EndRoutine      ; Make sure X <= MAX_OBJECTS

        LDA MobsArray+SMob::HP,X
        SEC
        SBC ParamAtkDef
        LDY #%00001111
        STY Temp
        BIT Temp            ; Will result in 0 if LSB (current HP) is 0000
        BEQ @Remove
            STA MobsArray+SMob::HP,X
            JMP @EndRoutine

        @Remove:
            LDA #MobType::NULL
            STA MobsArray+SMob::Type,X

        @EndRoutine:
        RTS
    .endproc

.endscope