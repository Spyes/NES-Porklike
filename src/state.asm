.scope State

    .enum States
        TITLESCREEN
        GAMEPLAY
        GAMEOVER
    .endenum

    .proc GamePlay
        InitVariables:
            LDA States::GAMEPLAY
            STA GameState

            LDA #0
            STA Frame
            STA Clock60
            STA PrevOAMCount

            JSR Collision::Init
            JSR Player::Init

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

            LDA #ObjectType::CHEST_CLOSED_L
            STA ParamType
            LDA #24
            STA ParamXPos
            LDA #40
            STA ParamYPos
            JSR Objects::Add

            LDA #ObjectType::CHEST_CLOSED_S
            STA ParamType
            LDA #16
            STA ParamXPos
            LDA #80
            STA ParamYPos
            JSR Objects::Add

        Main:
            JSR GFX::DisablePPURendering
            JSR GFX::LoadPalette

            LDA #<BackgroundData        ; Fetch lo-byte of BackgroundData
            STA BgPtr
            LDA #>BackgroundData        ; Fetch hi-byte of BackgroundData
            STA BgPtr+1
            JSR GFX::LoadNametable

            JSR GFX::LoadSprites
            JSR GFX::EnablePPURendering

        GameLoop:
            LDA Buttons
            STA PrevButtons
            JSR Joypad::ReadController

        Update:
            JSR Player::Update

        Draw:
            JSR Player::Draw
            JSR Objects::Draw

        WAIT_FOR_VBLANK

        JMP GameLoop
    .endproc

.endscope