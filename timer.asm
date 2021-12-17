org every_frame

	;Checks if the game is in a gameplay state, if not don't run the timer.
	;This also excludes the results screen. With additional checks against more memory addresses, the results screen could be included.
	SEP #$20
	LDA in_gameplay
	CMP #$00
	BNE skip7
	JML exit
	skip7:
	CMP #$AF
	BNE skip8
	JML exit
	skip8:
	;Checks if the game is in the middle of changing rooms, if so it does a bunch of things
	LDA screen_brightness
	CMP #$0F
	REP #$20
	BNE skip1
	JML checks
	skip1:
	;Checks if the previous room time has already been stored, so that this code only gets executed once every loading screen
	SEP #$28
	LDA already_transferred_room_time
	CMP #$01
	BEQ skip2
	JML done
	skip2:
	;These next 7 lines of code reset the overall level timer only if after the second room of a level.
	;This is so the user can look at the previous level's timer during the first screen of the next level.
	;A problem with this is that level 7 doesn't have a next level,
	;so the only opportunity for the user to see the final level time for it is 10-15 frames after grabbing the orb.
	LDA current_screen
	CMP #$01
	BNE skip6
	LDA #$00
	STA level_timer_minutes
	STA level_timer_seconds
	STA level_timer_frames
	skip6:
	;Transfers the final current room time to the previous room time variable and adds it to the overall level time variable,
	;making sure the overall level time also gets calculated properly.
	LDA room_timer_frames
	STA previous_timer_frames
	CLC
	ADC level_timer_frames
	STA level_timer_frames
	
	CMP #$60
	BCC seconds_transfer
	SEC
	SBC #$60
	STA level_timer_frames
	LDA level_timer_seconds
	INC
	STA level_timer_seconds
	
	
	seconds_transfer:
	LDA room_timer_seconds
	STA previous_timer_seconds
	CLC
	ADC level_timer_seconds
	STA level_timer_seconds
	
	CMP #$60
	BCC minutes_transfer
	SEC
	SBC #$60
	STA level_timer_seconds
	LDA level_timer_minutes
	INC
	STA level_timer_minutes
	
	minutes_transfer:
	LDA room_timer_minutes
	STA previous_timer_minutes
	CLC
	ADC level_timer_minutes
	STA level_timer_minutes
	
	;check if level timer exceeds 9m59s59f, if so reset level timer to 9m59s59f
	LDA level_timer_minutes
	CMP #$10
	BCC skip9
	LDA #$09
	STA level_timer_minutes
	LDA #$59
	STA level_timer_seconds
	STA level_timer_frames
	skip9:
	REP #$28
	LDA #$0000
	STA room_timer_frames
	STA room_timer_seconds
	STA room_timer_minutes
	STA already_transferred_room_time
	
	BRA done
	
	;check various play states
	checks:
	;if paused or if the room time has already hit 9m59s59f, stop updating the timer
	;I think I forgot to specifically code it to unset the timer cap flag upon changing rooms...
	;but it gets reset by something else anyway... so I guess it works
	LDA pause_flag
	BIT #$0001
	BNE done
	LDA timer_cap_flag
	BIT #$0001
	BNE done
	JML update_timer
	
	;This part of code should logically be put later, but I had to move it up due to some branch instructions otherwise falling out of bounds
	;This updates the graphical aspect of the timer, as well as preparing the return to the hijacked routine
	done:
	CLD
	REP #$28
	
	;RAM addresses around the $7ED800 area are linked to BG3 graphical information.
	;I am simply making edits to those RAM addresses to make numbers show up at the top of the screen, digit by digit.
	LDA room_timer_minutes
	AND #$000F
	ORA #$2830
	STA $7ED82E
	

	LDA room_timer_seconds
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED832
	
	LDA room_timer_seconds
	AND #$000F
	ORA #$2830
	STA $7ED834
	
	LDA room_timer_frames
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED838
	
	LDA room_timer_frames
	AND #$000F
	ORA #$2830
	STA $7ED83A
	
	
	
	
	LDA previous_timer_minutes
	AND #$000F
	ORA #$2830
	STA $7ED86E
	

	LDA previous_timer_seconds
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED872
	
	LDA previous_timer_seconds
	AND #$000F
	ORA #$2830
	STA $7ED874
	
	
	

	LDA previous_timer_frames
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED878
	
	LDA previous_timer_frames
	AND #$000F
	ORA #$2830
	STA $7ED87A
	
	
	
	
	LDA level_timer_minutes
	AND #$000F
	ORA #$2830
	STA $7ED80E
	

	LDA level_timer_seconds
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED812
	
	LDA level_timer_seconds
	AND #$000F
	ORA #$2830
	STA $7ED814
	
	
	

	LDA level_timer_frames
	LSR
	LSR
	LSR
	LSR
	AND #$000F
	ORA #$2830
	STA $7ED818
	
	LDA level_timer_frames
	AND #$000F
	ORA #$2830
	STA $7ED81A
	
	;Executes hijacked instruction and return to hijacked routine
	JSL $80A68D
	RTL
	
	;This enables decimal mode on the SNES CPU for ease of calculation, and increments the frame count by 1.
	;This runs once every frame, since it's in the middle of VBlank.
	;I think I actually enabled decimal mode already and have been running a bunch of prior calculations with it... Well, nothing seemed to be breaking :)
	update_timer:
	SED
	SEP #$28
	LDA #$01
	STA already_transferred_room_time
	LDA room_timer_frames
	CLC
	ADC #$01
	STA room_timer_frames
	CMP #$60
	BCS skip3
	JML done
	skip3:
	
	;If the frame count is 60, it resets it to 0 and increments the seconds by 1
	LDA #$00
	STA room_timer_frames
	LDA room_timer_seconds
	CLC
	ADC #$01
	STA room_timer_seconds
	CMP #$60
	BCS skip4
	JML done
	skip4:
	
	
	;If the seconds count is 60, it resets it to 0 and increments the minutes by 1
	LDA #$00
	STA room_timer_seconds
	LDA room_timer_minutes
	CLC
	ADC #$01
	STA room_timer_minutes
	CMP #$10
	BCS skip5
	JML done
	skip5:
	
	;If the minutes count is 10, it freezes the timer to 9m59s59f and stops updating it
	LDA #$09
	STA room_timer_minutes
	LDA #$59
	STA room_timer_seconds
	LDA #$59
	STA room_timer_frames
	LDA #$01
	STA timer_cap_flag
	JML done
	
	
	exit:
	CLD
	REP #$28
	JSL $80A68D
	RTL
	
	
	
	
