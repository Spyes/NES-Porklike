.scope State
    .proc GamePlay
        @InitVariables:
            LDA #States::GAMEPLAY
            STA GameState

            LDA #0
            STA Frame
            STA Clock60
            STA PrevOAMCount

            JSR Map::Init
            JSR Player::Init

        @Main:
            JSR GFX::DisablePPURendering
            JSR GFX::LoadPalette

            LDA #<BackgroundData        ; Fetch lo-byte of BackgroundData
            STA BgPtr
            LDA #>BackgroundData        ; Fetch hi-byte of BackgroundData
            STA BgPtr+1
            JSR GFX::LoadNametable

            JSR GFX::LoadSprites
            JSR GFX::EnablePPURendering

        @GameLoop:
            LDA Buttons
            STA PrevButtons
            JSR Joypad::ReadController

        @Update:
            LDA GameState
            CMP #States::PAUSED
            BEQ @Paused
            JSR Player::Update
            JMP @Draw

        @Paused:
            LDA Buttons
            AND #BUTTON_START
            BEQ @NotStartButton
                JSR GFX::ClearMessage
                LDA #States::GAMEPLAY
                STA GameState
            @NotStartButton:

        @Draw:
            JSR Player::Draw
            JSR Objects::Draw

        WAIT_FOR_VBLANK

        JMP @GameLoop
    .endproc

.endscope