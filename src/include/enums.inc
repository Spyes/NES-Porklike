.enum ObjectType            ; Object type is also the tile ID
    NULL                = 0
    DOOR                = $0F
    CHEST_CLOSED_L      = $0E
    CHEST_OPEN_L        = $0D
    CHEST_CLOSED_S      = $0C
    CHEST_OPEN_S        = $0B
    VASE_L              = $0A
    VASE_S              = $09
    TABLET              = $08
.endenum

.enum MobType
    NULL                = 0
    SLIME               = $30
.endenum

.enum States
    TITLESCREEN
    GAMEPLAY
    PAUSED
    GAMEOVER
.endenum