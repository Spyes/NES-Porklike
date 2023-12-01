.scope GFX
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Subroutine to load all 32 color palette values from ROM
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .proc LoadPalette
        LDA #$3F
        STA PPU_ADDR
        LDA #$00
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
        LDA #$00
        STA PPU_ADDR

        LDX #$00                    ; X = 0 -> x is the outer loop index (hi-byte) from $0 to $4
        LDY #$00                    ; Y = 0 -> y is the inner loop index (lo-byte) from $0 to $FF

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
    ;; Subroutine to draw tiles in the background using buffering
    ;; Params - ParamLength, ParamPtr
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
    .proc BufferMessage
        LDA #$07
        STA BuffPtr+1
        LDA #$00
        STA BuffPtr+0

        LDY #0                  ; Index in pointer

        LDA ParamLength         ; Legth = 1 (how many bytes we will send)
        STA (BuffPtr),Y
        INY                     ; Y++

        LDA ParamXPos
        STA (BuffPtr),Y         ; Hi-byte of the PPU address to be updated
        INY
        LDA ParamYPos
        STA (BuffPtr),Y         ; Lo-byte of the PPU address to be updated
        INY

        LDX #0
        @Loop:
            CPX ParamLength
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

    .proc ClearMessage
        LDA #$07
        STA BuffPtr+1
        LDA #$00
        STA BuffPtr+0

        LDY #0

        LDA #100
        STA (BuffPtr),Y
        INY
        INY
        INY

        LDX #0
        @Loop:
            CPX #100
            BEQ @Break
            LDA #0
            STA (BuffPtr),Y
            INY
            INX
            JMP @Loop
        @Break:

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