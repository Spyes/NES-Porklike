.macro PUSH_REGS
    PHA                         ; Push A to stack
    TXA                         ; Transfer X to A
    PHA                         ; Push A to stack (with X value)
    TYA                         ; Transfer Y to A
    PHA                         ; Push A to stack (with Y value)
    PHP                         ; Push Processor Status flags to the stack
.endmacro

.macro PULL_REGS
    PLP                         ; Pull the Processor Status flags from the stack
    PLA                         ; Pull last value from stack to A
    TAY                         ; Transfer A to Y
    PLA
    TAX                         ; ...Pull X from stack
    PLA
.endmacro

;; Negate value
.macro NEG n
    LDA n
    EOR #$FF
    SEC
    ADC #0
    STA n
.endmacro

;; Negate A register
.macro NEGA
    EOR #$FF
    SEC
    ADC #0
.endmacro

;; Play ball hit sfx
.macro SFX_0
    LDA #%10011111
    STA SQ1_ENV
    LDA #%11111111
    STA SQ1_LO
    LDA #%00000001
    STA SQ1_HI
.endmacro

.macro SFX_1
    LDA #%10011111
    STA SQ1_ENV
    LDA #%11111111
    STA SQ1_LO
    LDA #%00000000
    STA SQ1_HI
.endmacro

.macro SFX_2
    LDA #%00011111
    STA SQ1_ENV
    LDA #%11111111
    STA SQ1_LO
    LDA #%11111010
    STA SQ1_HI
.endmacro

.macro EJECT_PLAYER_UP
    LDA PlayerY
    SEC
    SBC #8
    STA PlayerY
    LDA #4
    STA PlayerOffsetY
    JMP @EndGetInput
.endmacro

.macro EJECT_PLAYER_DOWN
    LDA PlayerY
    CLC
    ADC #8
    STA PlayerY
    LDA #%11111100
    STA PlayerOffsetY
    JMP @EndGetInput
.endmacro

.macro EJECT_PLAYER_RIGHT
    LDA PlayerX
    CLC
    ADC #8
    STA PlayerX
    LDA #%11111100
    STA PlayerOffsetX
    JMP @EndGetInput
.endmacro

.macro EJECT_PLAYER_LEFT
    LDA PlayerX
    SEC
    SBC #8
    STA PlayerX
    LDA #4
    STA PlayerOffsetX
    JMP @EndGetInput
.endmacro