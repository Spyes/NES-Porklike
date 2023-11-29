.include "./include/header.inc"
.include "./include/consts.inc"
.include "./include/reset.inc"
.include "./include/macros.inc"
.include "./include/structs.inc"

.segment "ZEROPAGE"
ObjectsArray:       .res MAX_OBJECTS * .sizeof(SObject)

;; Buttons
Buttons:            .res 1      ; Joypad buttons
PrevButtons:        .res 1      ; Previous joypad buttons

;; Player
PlayerX:            .res 1
PlayerY:            .res 1
PlayerOffsetX:      .res 1
PlayerOffsetY:      .res 1
PlayerAnimTimer:    .res 1

;; System
Frame:              .res 1      ; Reserve 1 byte to store the number of frames 
Clock60:            .res 1      ; Reserve 1 byte to store a counter that increments every second (60 frames)
IsDrawComplete:     .res 1
GameState:          .res 1
PrevOAMCount:       .res 1

;; Params
ParamXPos:          .res 1
ParamYPos:          .res 1
ParamAttribs:       .res 1
ParamTileNum:       .res 1
ParamType:          .res 1

;; Pointers
BgPtr:              .res 2      ; Reserve 2 bytes (16 bits) to store a pointer to the background address (address are always 2 bytes)
BuffPtr:            .res 2      ; Pointer to the background buffer address - 16bits (lo,hi)
SprPtr:             .res 2

;; Temp
Temp:               .res 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

.include "gfx.asm"
.include "joypad.asm"
.include "collision.asm"
.include "objects.asm"
.include "player.asm"
.include "state.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset handler called when game starts up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset:
    INIT_NES

    JSR State::GamePlay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NMI interrupt handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NMI:
    PUSH_REGS

    INC Frame                   ; Frame++

OAMStartDMACopy:                ; As soon as we enter the NMI handler, we start the OAM copy
    LDA #02                     ; Every frame we copy sprite data starting at $02**
    STA PPU_OAM_DMA             ; The OAM DMA copy starts when we write to $4014

    JSR GFX::EnablePPURendering

SetGameClock:
    LDA Frame
    CMP #60
    BNE :+                      ; If Frame != 60, jump to RTI
        INC Clock60             ; Increment every 60 frames (one second)
        LDA #0
        STA Frame               ; Reset Frame to 0
    :

SetDrawComplete:
    LDA #TRUE
    STA IsDrawComplete

    PULL_REGS
    RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IRQ interrupt handler (unused)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IRQ:
    RTI

PaletteData:
    .byte $0F,$00,$10,$20, $0F,$01,$11,$21, $0F,$06,$16,$26, $0F,$17,$27,$37    ; Background
    .byte $0F,$00,$10,$20, $0F,$01,$11,$21, $0F,$06,$16,$26, $0F,$0F,$29,$39    ; Sprite

BackgroundData:
.incbin "./assets/porklike.nam"

SpriteData:
;--------------------------------
; Pork
;      Y   tile#   attribs     X
.byte $00,  $01,  %00000011,  $00   ; $0200 - $0203

; Sprite Attribute Byte:
;-----------------------
; 76543210
; |||   ||
; |||   ++- Color Palette of sprite. Choose which set of 4 from the 16 colors to use
; |||
; ||+------ Priority (0: in front of background; 1: behind background)
; |+------- Flip sprite horizontally
; +-------- Flip sprite vertically

CollisionMap:
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %01111111,%11111111,%10000000,%00000000
    .byte %01000100,%00010000,%10000000,%00000000
    .byte %01000000,%00010111,%10000000,%00000000
    .byte %01000100,%00010000,%10000000,%00000000
    .byte %01000100,%00011110,%10000000,%00000000
    .byte %01000100,%00001000,%10000000,%00000000
    .byte %01000111,%11101000,%10000000,%00000000
    .byte %01101111,%11101000,%10000000,%00000000
    .byte %01000000,%10001011,%10000000,%00000000
    
    .byte %01000110,%00111000,%10000000,%00000000
    .byte %01000111,%01111000,%10000000,%00000000
    .byte %01000100,%00001000,%10000000,%00000000
    .byte %01000100,%00000000,%10000000,%00000000
    .byte %01000100,%00001000,%10000000,%00000000
    .byte %01000100,%00001000,%10000000,%00000000
    .byte %01111111,%11111111,%10000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000,%00000000

CollisionMask:
    .byte %10000000
    .byte %01000000
    .byte %00100000
    .byte %00010000
    .byte %00001000
    .byte %00000100
    .byte %00000010
    .byte %00000001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Here we add the CHR-ROM data, included from an external .CHR file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.SEGMENT "CHARS"
.incbin "./assets/porklike.chr"

.SEGMENT "VECTORS"
.word   NMI
.word   Reset
.word   IRQ