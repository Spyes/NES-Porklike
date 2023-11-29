.enum ObjectType            ; Object type is also the tile ID
    NULL        = 0
    DOOR        = $0F
.endenum

.struct SObject
    Type        .byte
    XPos        .byte
    YPos        .byte
.endstruct
