.scope GFX
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to load all 32 color palette values from ROM
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc LoadPalette
        LDA #$3F
        STA PPU_ADDR
        LDA #0
        STA PPU_ADDR

        LDY #0
    @LoadPaletteLoop:
        LDA PaletteData,Y
        STA PPU_DATA
        INY
        CPY #32
        BNE @LoadPaletteLoop
        
        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to load 255 tiles in the first nametable
    ;; Params - BgPtr holds lo- and hi-bytes of nametable to load
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc LoadNametable
        LDA #$20
        STA PPU_ADDR
        LDA #0
        STA PPU_ADDR

        LDX #0                    ; X = 0 -> x is the outer loop index (hi-byte) from $0 to $4
        LDY #0                    ; Y = 0 -> y is the inner loop index (lo-byte) from $0 to $FF

    OuterLoop:
        InnerLoop:
            LDA (BgPtr),Y           ; Fetch the value pointed by BgPtr + Y (only Y can be used to offset pointer)
            STA PPU_DATA            ; Store in the PPU data
            INY                     ; Y++
            CPY #0                  ; If Y == 0 (roll off from $FF)
            BEQ IncreaseHiByte      ;  Then: increase the hi-byte
            JMP InnerLoop           ;  Else: keep looping
        IncreaseHiByte:
            INC BgPtr+1             ; Increment hi-byte pointer to point to the next bg section (next 255 chunk)
            INX                     ; X++
            CPX #4                  ; If we looped 4 hi bytes
            BNE OuterLoop

        RTS                         ; Retrun from subroutine
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to load all 16 bytes into OAM-RAM starting at $0200
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc LoadSprites
        LDX #0
    @LoadSpritesLoop:
        LDA SpriteData,X
        STA $0200,X
        INX
        CPX #36
        BNE @LoadSpritesLoop

        RTS
    .endproc

    .proc EnablePPURendering
        LDA #%10001000              ; Enable NMI (bit 7) and set background to use 2nd pattern table (bit 4 - $1000)
        STA PPU_CTRL
        LDA #0
        STA PPU_SCROLL              ; Disable X scroll
        STA PPU_SCROLL              ; Disable Y scroll
        LDA #%00011110
        STA PPU_MASK                ; Set PPU_MASK bits
        RTS
    .endproc

    .proc DisablePPURendering
        LDA #0
        STA PPU_CTRL
        STA PPU_MASK
        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to draw tiles in the background using buffering $0700 - $0779
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Buffer format starting at memory address $0700:
    ;;
    ;; 03 20 52 00 00 02 01 20  78 00 00
    ;;  | \___/ \______/  | \___/   |  |
    ;;  |   |      |      |   |     |  |
    ;;  |   |      |      |   |     |  Length=0 (end of buffering)
    ;;  |   |      |      |   |     Byte to copy 
    ;;  |   |      |      |   PPU address $2078 
    ;;  |   |      |      Length=1
    ;;  |   |      Bytes to copy
    ;;  |   PPU address $2052
    ;;  Length=3
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc BufferTextPanel
        LDA #$07
        STA BuffPtr+1
        LDA #$00
        STA BuffPtr+0

        LDY #0                  ; Index in pointer

    @TopBorder:
        LDA #TEXT_PANEL_WIDTH+2 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$41
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        ; Left border
        LDA #$10
        STA (BuffPtr),Y
        INY

        ; Top border
        LDA #$11
        LDX #0
        @DrawTopBorder:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndDrawTopBorder
            STA (BuffPtr),Y
            INY
            INX
            JMP @DrawTopBorder
        @EndDrawTopBorder:

        ; Top-right border
        LDA #$14
        STA (BuffPtr),Y
        INY

    @LeftBorder1:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$61
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$12
        STA (BuffPtr),Y
        INY

    @RightBorder1:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$62+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$15
        STA (BuffPtr),Y
        INY

    @LeftBorder2:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$81
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$12
        STA (BuffPtr),Y
        INY

    @RightBorder2:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$82+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$15
        STA (BuffPtr),Y
        INY

    @LeftBorder3:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A1
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$12
        STA (BuffPtr),Y
        INY

    @RightBorder3:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A2+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #$15
        STA (BuffPtr),Y
        INY

    @BottomBorder:
        ; Bottom border
        LDA #TEXT_PANEL_WIDTH+2 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$C1
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        ; Bottom-left border
        LDA #$13
        STA (BuffPtr),Y
        INY

        ; Bottom border
        LDA #$17
        LDX #0
        @DrawBottomBorder:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndDrawBottomBorder
            STA (BuffPtr),Y
            INY
            INX
            JMP @DrawBottomBorder
        @EndDrawBottomBorder:

        ; Bottom-right border
        LDA #$16
        STA (BuffPtr),Y
        INY

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to draw tiles in the background using buffering $0750 - $0762
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc BufferLine1Text
        LDA #$07
        STA BuffPtr+1
        LDA #$50
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH   ; Legth
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$62                ; First line
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        @Loop:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop
            TYA
            PHA
            TXA
            TAY
            LDA (ParamPtr),Y
            STA Temp
            PLA
            TAY
            LDA Temp
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop
        @EndLoop:

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    .proc BufferLine2Text
        LDA #$07
        STA BuffPtr+1
        LDA #$70
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH   ; Legth
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A2                ; First line
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        @Loop:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop
            TYA
            PHA
            TXA
            TAY
            LDA (ParamPtr),Y
            STA Temp
            PLA
            TAY
            LDA Temp
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop
        @EndLoop:

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    .proc BufferLine3Text
        LDA #$07
        STA BuffPtr+1
        LDA #$90
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH   ; Legth
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$E2                ; First line
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        @Loop:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop
            TYA
            PHA
            TXA
            TAY
            LDA (ParamPtr),Y
            STA Temp
            PLA
            TAY
            LDA Temp
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop
        @EndLoop:

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    .proc BufferLine4Text
        LDA #$07
        STA BuffPtr+1
        LDA #$B0
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH   ; Legth
        STA (BuffPtr),Y
        INY

        LDA #$23
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$22                ; First line
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        @Loop:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop
            TYA
            PHA
            TXA
            TAY
            LDA (ParamPtr),Y
            STA Temp
            PLA
            TAY
            LDA Temp
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop
        @EndLoop:

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    .proc BufferPlayerStats
        LDA #$07
        STA BuffPtr+1
        LDA #$D0
        STA BuffPtr+0

        LDY #0

    @Attack:
        LDA #1
        STA (BuffPtr),Y
        INY

        LDA #$20
        STA (BuffPtr),Y
        INY
        LDA #$D8
        STA (BuffPtr),Y
        INY

        LDA PlayerAtkDef
        LSR
        LSR
        LSR
        LSR
        CLC
        ADC #$30
        STA (BuffPtr),Y
        INY

    @Defense:
        LDA #1
        STA (BuffPtr),Y
        INY

        LDA #$21
        STA (BuffPtr),Y
        INY
        LDA #$38
        STA (BuffPtr),Y
        INY

        LDA PlayerAtkDef
        AND #%00001111
        CLC
        ADC #$30
        STA (BuffPtr),Y
        INY

    @HP:
        LDA #1
        STA (BuffPtr),Y
        INY

        LDA #$20
        STA (BuffPtr),Y
        INY
        LDA #$78
        STA (BuffPtr),Y
        INY

        LDA PlayerHP
        AND #%00001111
        CLC
        ADC #$30
        STA (BuffPtr),Y
        INY

    @MaxHP:
        LDA #1
        STA (BuffPtr),Y
        INY

        LDA #$20
        STA (BuffPtr),Y
        INY
        LDA #$7B
        STA (BuffPtr),Y
        INY

        LDA PlayerHP
        LSR
        LSR
        LSR
        LSR
        CLC
        ADC #$30
        STA (BuffPtr),Y
        INY

    @End:
        LDA #0
        STA (BuffPtr),Y
        INY

        RTS
    .endproc

    .proc BufferPlayerHP
        LDA #$07
        STA BuffPtr+1
        LDA #$A9
        STA BuffPtr+0

        LDY #0

        LDA #0
        STA (BuffPtr),Y
        INY

        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to clear message panel tiles in the background using buffering
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc ClearTextPanel
        LDA #$07
        STA BuffPtr+1
        LDA #$00
        STA BuffPtr+0

    @TopBorder:
        LDY #0                  ; Index in pointer
        LDA #TEXT_PANEL_WIDTH+2 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$41
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

        LDX #0
        LDA #0
        @ClearTopBorder:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndClearTopBorder
            STA (BuffPtr),Y
            INY
            INX
            JMP @ClearTopBorder
        @EndClearTopBorder:

        LDA #0
        STA (BuffPtr),Y
        INY

    @LeftBorder1:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$61
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @RightBorder1:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$62+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @LeftBorder2:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$81
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @RightBorder2:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$82+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @LeftBorder3:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A1
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @RightBorder3:
        LDA #1                 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A2+TEXT_PANEL_WIDTH
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDA #0
        STA (BuffPtr),Y
        INY

    @BottomBorder:
        LDA #TEXT_PANEL_WIDTH+2 ; Length
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$C1
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        ; Bottom-left border
        LDA #0
        STA (BuffPtr),Y
        INY

        ; Bottom border
        LDX #0
        LDA #0
        @ClearBottomBorder:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndClearBottomBorder
            STA (BuffPtr),Y
            INY
            INX
            JMP @ClearBottomBorder
        @EndClearBottomBorder:

        ; Bottom-right border
        LDA #0
        STA (BuffPtr),Y
        INY

        LDA #0
        STA (BuffPtr),Y         ; Length=0 to indicate end of buffer
        INY

        RTS
    .endproc

    .proc ClearText
    @ClearLine1:
        LDA #$07
        STA BuffPtr+1
        LDA #$50
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH   ; Legth
        STA (BuffPtr),Y
        INY                     ; Y++

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$62
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        LDA #0
        @Loop1:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop1
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop1
        @EndLoop1:

        LDA #0
        STA (BuffPtr),Y
        INY

    @ClearLine2:
        LDA #$07
        STA BuffPtr+1
        LDA #$70
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$A2
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        LDA #0
        @Loop2:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop2
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop2
        @EndLoop2:

    @ClearLine3:
        LDA #$07
        STA BuffPtr+1
        LDA #$90
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH
        STA (BuffPtr),Y
        INY

        LDA #$22
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$E2
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        LDA #0
        @Loop3:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop3
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop3
        @EndLoop3:

    @ClearLine4:
        LDA #$07
        STA BuffPtr+1
        LDA #$B0
        STA BuffPtr+0

        LDY #0
        LDA #TEXT_PANEL_WIDTH
        STA (BuffPtr),Y
        INY

        LDA #$23
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA #$22
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        LDA #0
        @Loop4:
            CPX #TEXT_PANEL_WIDTH
            BEQ @EndLoop4
            STA (BuffPtr),Y
            INX
            INY
            JMP @Loop4
        @EndLoop4:

        LDA #0
        STA (BuffPtr),Y
        INY

        RTS
    .endproc

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to copy tiles from BuffPtr ($0700) to current nametable data
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc BackgroundCopy
        LDY #0
        BufferLoop:
            LDA (BuffPtr),Y         ; First byte is length
            BEQ EndBackgroundCopy   ; if Length==0, break
            TAX                     ; X = Length
            INY                     ; Y++
            LDA (BuffPtr),Y         ; Fetch hi-byte of PPU address to be updated
            STA PPU_ADDR
            INY
            LDA (BuffPtr),Y         ; Fetch lo-byte of PPU address to be updated
            STA PPU_ADDR
            INY
            DataLoop:
                LDA (BuffPtr),Y
                STA PPU_DATA
                INY                 ; Y++
                DEX                 ; X--
                BNE DataLoop        ; While X > 0, keep sending data
                JMP BufferLoop      ; Loop back until we finish the buffer (Length=0)
        EndBackgroundCopy:
        RTS
    .endproc

    ;; Draw sprite to SprPtr starting at Y (set exterally)
    .proc DrawSprite
        LDA ParamYPos
        STA (SprPtr),Y
        INY

        LDA ParamTileNum
        STA (SprPtr),Y
        INY

        LDA ParamAttribs
        STA (SprPtr),Y
        INY

        LDA ParamXPos
        STA (SprPtr),Y
        INY

        RTS
    .endproc
.endscope