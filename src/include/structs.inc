.struct SObject
    Type        .byte
    XPos        .byte
    YPos        .byte
.endstruct

.struct SMob
    Type        .byte
    XPos        .byte
    YPos        .byte
    HP          .byte   ;; LSB - current HP, MSB - max HP, %11110111 - Max: 15, current: 7
    AtkDef      .byte   ;; LSB - attack, MSB - defp
.endstruct
