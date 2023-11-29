.scope Collision
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to initialize the collision map
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc Init
        ; LDA #%10000001
        ; STA CollisionMap
        ; LDX #105
        ; @InitLoop:
        ;     LDA #%11111111
        ;     STA CollisionMap,X
        ;     DEX
        ;     BNE @InitLoop
        RTS
    .endproc

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