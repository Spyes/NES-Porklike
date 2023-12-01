;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macro to initialize the NES by disabling rendering and clearinng RAM values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.macro INIT_NES

    SEI             ; Disable all IRQ interrupts
    CLD		        ; Clear the decimal mode (unsupported by NES)

    LDX #$FF
    TXS	    	    ; Initialize the stack pointer at $01FF

    INX             ; Incremet X from $FF to $0

    STX PPU_CTRL    ; Disable NMI
    STX PPU_MASK    ; Disable rendering
    STX $4010       ; Disable DMC IRQs

    LDA #$40
    STA $4017       ; Disable APU frame IRQ


    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    BIT $2002
@VBlankWait1:        ; Wait for the first VBlank from the PPU
    BIT PPU_STATUS  ; Perform a bit-wise check with the PPU_STATUS ($2002) port
    BPL @VBlankWait1 ; Loop until bit-7 (sign bit) is 1, 0 = positive 1 = negative

    TXA             ; A = 0
@ClearRAM:
    STA $0000,X	    ; Zero RAM addresses from $0000 to $00FF
    STA $0100,X	    ; Zero RAM addresses from $0100 to $01FF
    STA $0200,X	    ; Zero RAM addresses from $0200 to $02FF
    STA $0300,X	    ; Zero RAM addresses from $0300 to $03FF
    STA $0400,X	    ; Zero RAM addresses from $0400 to $04FF
    STA $0500,X	    ; Zero RAM addresses from $0500 to $05FF
    STA $0600,X	    ; Zero RAM addresses from $0600 to $06FF
    STA $0700,X	    ; Zero RAM addresses from $0700 to $07FF
    INX             ; X++
    BNE @ClearRAM	; Loops until X reaches zero again (after roll-off)

@InitSound:
    LDA #%00000001  ; Enable Square 1 channel
    STA APU_FLAGS

@VBlankWait2:        ; Wait for the second VBlank from the PPU
    BIT PPU_STATUS  ; Perform a bit-wise check with the PPU_STATUS ($2002) port
    BPL @VBlankWait2 ; Loop until bit-7 (sign bit) is 1, 0 = positive 1 = negative
.endmacro

.macro WAIT_FOR_VBLANK
    @WaitForVBlank:
        LDA IsDrawComplete
        BEQ @WaitForVBlank
            LDA #0
            STA IsDrawComplete
.endmacro