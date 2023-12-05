.scope State
    .proc GamePlay
        @InitVariables:
            LDA #States::GAMEPLAY
            STA GameState

            LDA #0
            STA Frame
            STA Clock60
            STA PrevObjOAMCount
            STA PrevMobsOAMCount
            STA AnimFrame

            LDA #10
            STA AnimTimer

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
            LDA AnimTimer
            BEQ @ResetAnimTimer
                DEC AnimTimer
                JMP @EndCheckAnimTimer
            @ResetAnimTimer:
                LDA #10
                STA AnimTimer
                INC AnimFrame
                LDA AnimFrame
                CMP #4
                BNE @EndCheckAnimTimer
                    LDA #0
                    STA AnimFrame
            @EndCheckAnimTimer:
            
            JSR Player::Update
            JSR Mobs::Update
            JMP @Draw

        @Draw:
            JSR Player::Draw
            JSR Objects::Draw
            JSR Mobs::Draw

        WAIT_FOR_VBLANK

        JMP @GameLoop
    .endproc

.endscope