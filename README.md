# BowlingScore

Bowling score can keep track of multiple players bowling scores.
Also has the ability to generate random scores for 
multiple people to have multiple fun...

GameUnit.pas contains the logic for correctly scoring the game.
BowlingScore.pas contains the code for a Simple UI to demonstrate 
how to use GameUnit.

Used the following link to help understand the scoring logic

https://www.thoughtco.com/bowling-scoring-420895

# Frame State for Double Strikes

Frame | 4 | 5 | 6 | 7 | 8 |
------|---|---|---|---|---|
Frame State In|GS=fsSecondBall|GS=fsSB|GS=fsSB1R|GS=gsDSBR1|GS=gsDBR1
Result|9 /|X|X|X|4
Frame State after Roll|F4R2=1 F4S=fsSpareBonus GS=fsSpareBonus|F4BI=10 F5R1=10 F4S=Strike F5S=fsSB1R GS=fsSB1R|F5B1=10 F6R1=10 F5S=fsSB2R F6S=fsSBR1 GS=gsDSBR1|F7R1=10 F6B1=10 F5B2=10 F5S=fsStrike F6S=fsSBR2 F7S=fsSBR1 F6S=gsDSBR1|F8R1=4 F7B1=4 F6B2=4  F6S=fsStrike F7S=fsSBR1 F8S=fsR2 GS=gsSBR1

## Legend
FnRn = Frame <number> Roll < 1 or 2 > <br/>
FnBn = Frame <number> Bonus < 1 or 2 ><br/>
FnS = Frame <number> State<br/>
GS = Game State<br/>

# Going into the 10th Frame
Frame | 8 | 9 | 10 |
-----|---|---|----
Frame State In|GS=fsOpen|GS=fsOpen|
Result|4 5|4 /|
Frame State after Roll|F8R2=fsOpen<br/>F8S=fsOpen GS=fsOpen|F9R2=6<br/> F9S=fsSpareBonus GS=fsSpareBonus|


## Frame 10 possible states
fsFirstRoll<br/>
fsSecondRoll<br/>
fsSpareBonusRoll<br/>
fsSpare<br/>
fsStrikeBonusRoll1<br/>
fsStrikeBonusRoll2<br/>
fsStrike<br/>
fsSpareBonusRollFrame10<br/>
fsStrikeBonusFirstRollFrame10<br/>
fsStrikeBonusSecondRollFrame10<br/>
  
  // fsDoubleStrikeBonusRoll = two strikes in a row<br/>
TGameState = (fsFirstRoll, fsSecondRoll, fsOpen, fsSpareBonusRoll, fsSpare,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsStrikeBonusFirstRoll, fsStrikeBonusSecondRoll, fsStrike,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsGameOver, fsDoubleStrikeBonusRoll,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsSpareBonusRollFrame10, fsStrikeBonusFirstRollFrame10,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsStrikeBonusSecondRollFrame10, fsDoubleStrikeBonusRollFrame10);<br/>
<br/>
  TFrameState = fsFirstRoll..fsGameOver;<br/>
  TRoll = (trFirst=1, trSecond);<br/>
<br/>
const<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cCrLf = #$D#$A;<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cMaxFrames = 10; // Frames collection starts at "0"<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cDisplayLastTwoFrames = false; // should NOT of brought these out to the UI, but oh well ;-(<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cDisplayInLine = true; // displays stats in a single line.. Same here with UI ;-(<br/>

cShowLastTwoFrameState = ([fsSpareBonusRoll, fsSpare,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsStrikeBonusFirstRoll, fsStrikeBonusSecondRoll, fsStrike,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsDoubleStrikeBonusRoll,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsSpareBonusRollFrame10, fsStrikeBonusFirstRollFrame10,<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fsStrikeBonusSecondRollFrame10]);<br/>
<br/>





