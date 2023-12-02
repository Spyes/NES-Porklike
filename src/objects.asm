.scope Objects
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to add new object to the Objects array in the first empty slot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ParamType, ParamXPos, ParamYPos
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc Add
        LDX #0
        @ArrayLoop:
            CPX #MAX_OBJECTS * .sizeof(SObject)
            BEQ @EndRoutine

            LDA ObjectsArray+SObject::Type,X
            CMP #ObjectType::NULL
            BEQ @AddNewObject

            @NextObject:
                TXA
                CLC
                ADC #.sizeof(SObject)
                TAX
                JMP @ArrayLoop
        
        @AddNewObject:
            LDA ParamType
            STA ObjectsArray+SObject::Type,X
            LDA ParamXPos
            STA ObjectsArray+SObject::XPos,X
            LDA ParamYPos
            STA ObjectsArray+SObject::YPos,X
            LDA ParamMetadata_LO
            STA ObjectsArray+SObject::Metadata_LO,X
            LDA ParamMetadata_HI
            STA ObjectsArray+SObject::Metadata_HI,X

        @EndRoutine:
            RTS
    .endproc

    ;; TODO: Draw objects as background tiles instead of sprites
    ;; IsXYSolid should return true and set A (or different variable) to Tile ID (object type)
    ;; or -1 if it's not an interactable object
    .proc Draw
        LDA #$02
        STA SprPtr+1
        LDA #$04
        STA SprPtr+0            ; SprPtr = $0204

        LDX #0
        LDY #0
        @ArrayLoop:
            CPX #MAX_OBJECTS * .sizeof(SObject)
            BEQ @EndLoop
            LDA ObjectsArray+SObject::YPos,X
            SEC
            SBC #1
            STA ParamYPos
            LDA ObjectsArray+SObject::Type,X
            STA ParamTileNum
            LDA #%00000000
            STA ParamAttribs
            LDA ObjectsArray+SObject::XPos,X
            STA ParamXPos
            JSR GFX::DrawSprite

            @NextObject:
                TXA
                CLC
                ADC #.sizeof(SObject)
                TAX
                JMP @ArrayLoop
        @EndLoop:

        ;; Clear out previously set tiles - we do this by checkig whether we
        ;; drew more tiles last run and zeroing out the sprite data
        TYA             ; Y has number of bytes sent to OAM
        PHA
        @LoopTrailingTiles:
            CPY PrevOAMCount
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
        STA PrevOAMCount
        
        RTS
    .endproc

    ;; Check if an object exists at (ParamXPos,ParamYPos)
    ;; Sets ObjectAtXY to -1 if no object, otherwise sets to objects X index
    .proc IsAtXY
        LDX #0
        @ArrayLoop:
            CPX #MAX_OBJECTS * .sizeof(SObject)
            BNE :+          ; Reached end of array - no object found, return -1
                LDA #%11111111
                JMP @EndRoutine
            :
            LDA ObjectsArray+SObject::Type,X
            CMP #ObjectType::NULL
            BEQ @NextObject
            LDA ObjectsArray+SObject::XPos,X
            CMP ParamXPos
            BNE :+
                LDA ObjectsArray+SObject::YPos,X
                CMP ParamYPos
                BNE :+      ; X and Y match, set A to X (index in array)
                    TXA
                    JMP @EndRoutine
                :
            :
            @NextObject:
                TXA
                CLC
                ADC #.sizeof(SObject)
                TAX
                JMP @ArrayLoop

        @EndRoutine:
        RTS
    .endproc

    .proc Bump
        CPX #MAX_OBJECTS * .sizeof(SObject)
        BCS @EndRoutine      ; Make sure X <= MAX_OBJECTS

        LDA ObjectsArray+SObject::Type,X

        @Tablet:
            CMP #ObjectType::TABLET
            BNE :+
                LDA ObjectsArray+SObject::Metadata_LO,X
                STA ParamPtr+0
                LDA ObjectsArray+SObject::Metadata_HI,X
                STA ParamPtr+1
                JSR Text::Length
                STY ParamLength
                JSR GFX::BufferMessage
                LDA #States::PAUSED
                STA GameState
                JMP @EndRoutine
            :

        ;; TODO: Open chests should be background tiles with collision
        @ChestL:
            CMP #ObjectType::CHEST_CLOSED_L
            BNE :+
                LDA #ObjectType::CHEST_OPEN_L
                JMP @SetType
            :
            CMP #ObjectType::CHEST_OPEN_L
            BEQ @EndRoutine

        @ChestS:
            CMP #ObjectType::CHEST_CLOSED_S
            BNE :+
                LDA #ObjectType::CHEST_OPEN_S
                JMP @SetType
            :
            CMP #ObjectType::CHEST_OPEN_S
            BEQ @EndRoutine

        @Remove:
            LDA #ObjectType::NULL

        @SetType:
            STA ObjectsArray+SObject::Type,X

        @EndRoutine:
            RTS
    .endproc
.endscope