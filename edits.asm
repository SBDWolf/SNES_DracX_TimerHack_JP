@include

; when dying at 0 lives, instead of game overing it sets the lives count to 42
org game_over_skip
	LDA #$0042
	STA $9E
	NOP
	NOP
	
	

	
	
	
