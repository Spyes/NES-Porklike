.scope Map
    .proc Init
        ;; TODO automatically add objects from nametable
        LDA #ObjectType::DOOR
        STA ParamType
        LDA #40
        STA ParamXPos
        LDA #24
        STA ParamYPos

        JSR Objects::Add

        LDA #ObjectType::DOOR
        STA ParamType
        LDA #24
        STA ParamXPos
        LDA #64
        STA ParamYPos
        JSR Objects::Add

        LDA #ObjectType::TABLET
        STA ParamType
        LDA #24
        STA ParamXPos
        LDA #40
        STA ParamYPos
        JSR Objects::Add

        LDA #ObjectType::VASE_L
        STA ParamType
        LDA #16
        STA ParamXPos
        LDA #80
        STA ParamYPos
        JSR Objects::Add

        LDA #ObjectType::CHEST_CLOSED_S
        STA ParamType
        LDA #24
        STA ParamXPos
        LDA #96
        STA ParamYPos
        JSR Objects::Add

        RTS
    .endproc

    ;; TODO: Draw objects as background tiles instead of sprites
    ;; IsXYSolid should return true and set A (or different variable) to Tile ID (object type)
    ;; or -1 if it's not an interactable object

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to check if a X,Y coordinate is solid or not
    ;; Params - X register, Y register
    ;; Sets A to 1 if solid, 0 if not
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc IsXYSolid
        ; (X / 64) + (Y / 8) * 4
        ; (X / 8) AND %0111
        TXA             ; X / 64
        LSR
        LSR
        LSR
        LSR
        LSR
        LSR
        STA Temp
        TYA
        LSR    
        LSR    
        LSR    
        ASL
        ASL
        CLC
        ADC Temp
        TAY             ; Byte index in collision map

        TXA             ; X / 8
        LSR
        LSR
        LSR
        AND #%0111
        TAX             ; Bit mask index in collision mask

        LDA CollisionMap,Y
        AND CollisionMask,X

        RTS
    .endproc
.endscope