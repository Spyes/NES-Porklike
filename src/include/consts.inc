;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants for PPU registers mapped from addressses $2000 to $2007
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PPU_CTRL    = $2000
PPU_MASK    = $2001
PPU_STATUS  = $2002
OAM_ADDR    = $2003
OAM_DATA    = $2004
PPU_SCROLL  = $2005
PPU_ADDR    = $2006
PPU_DATA    = $2007
PPU_OAM_DMA = $4014

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants for APU registers mapped from addressses $4000 to $4017
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SQ1_ENV     = $4000
; 76543210
; ||||++++- Volume
; |||+----- Saw Envelope Disable (0: use internal counter for volume; 1: use Volume for volume)
; ||+------ Length Counter Disable (0: use Length Counter; 1: disable Length Counter)
; ++------- Duty Cycle

SQ1_LO      = $4002
; 76543210
; ++++++++- Low 8-bits of period

SQ1_HI      = $4003
; 76543210
; |||||+++- High 3-bits of period
; +++++---- Length Counter

APU_FLAGS   = $4015
; 76543210
;    ||||+- Square 1 (0: disable; 1: enable)
;    |||+-- Square 2
;    ||+--- Triangle
;    |+---- Noise
;    +----- DMC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Controller ports and buttons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JOYPAD1         = $4016
JOYPAD2         = $4017
BUTTON_A        = $80   ; 10000000
BUTTON_B        = $40   ; 01000000
BUTTON_SELECT   = $20   ; 00100000
BUTTON_START    = $10   ; 00010000
BUTTON_UP       = $08   ; 00001000
BUTTON_DOWN     = $04   ; 00000100
BUTTON_LEFT     = $02   ; 00000010
BUTTON_RIGHT    = $01   ; 00000001

FALSE           = $00
TRUE            = $01

;;;;;;;;;;;;;;;;;;;;;;
;; Game constants
;;;;;;;;;;;;;;;;;;;;;;
MAX_OBJECTS     = $14   ; 20 max objects
