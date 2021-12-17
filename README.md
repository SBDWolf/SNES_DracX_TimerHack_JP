# SNES_DracX_TimerHack_JP
Timer Hack for the SNES game Castlevania: Dracula X

To be assembled using Asar, run "asar.exe --fix-checksum=off main.asm {ROM name}" on a japanese rom of the game through the command prompt.

Features:

- Current room timer that updates frame-by-frame in real time. This is displayed in the very top right of the screen.
- Previous room time. This is displayed just below the current room time.
- Overall level time. This is displayed in the top left of the screen, and at the start of each level it displays the total level time of the previously completed level.

Known jank:

- Lots of graphical artifacts, including the collapsing platforms in level 2, and walls that contain meat.
- The timers all visually disappear while the orb is spawning. They still count the overall time in the background, and will visually show and update the time as soon as you grab the orb.
- After grabbing the Dracula orb, the only window to read the room and level times is those 10-15 frames before the screen fades to black, since there's no level afterwards.
- The overall level timer is just a sum of each room time, meaning the loading time between each room is not counted.
