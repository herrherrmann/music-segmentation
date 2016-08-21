README
(G. Peeters 16 septembre 2002, Geoffroy.Peeters@ircam.fr)

INTRODUCTION
------------
This database is provided for the ISO MPEG-7 version 2 Core Experiment on AudioSpectralEnvelopeEvolution
It is provided solely for the testing of algorithm for detection of music structures and melody repetition.

See output document w5049 of Klangenfurt ISO meeting for details.

The database is composed of 20 tracks of various musical genre.
These tracks have been chosen because of the clarity of their structures 
or the clarity or the melody repetition.

STRUCTURE ANNOTATION
--------------------
The structures are indicated as 
- segment label (example: introduction, verse, chorus, brige)
- begin time (in sec)
- end time (in sec) 
for each part of the track.
Usually the starting time corresponds to the beginning of a measure.

MELODY REPETITION ANNOTATION
----------------------------
The melody are indicated as
- melody label (example: verseA, verseB, chorusA, chorusB, ...)
- the starting time
for each occurrence of the melodies

The end time is not indicated because the same melody can be repeated later in the track 
with a shortest length (example: B=A(1:end/2))
We use as starting time a "mean staring time". This is because the same melody can start 
a bit before of after (because of the lyrics). Because of that the values indicated are
the part of the melody which is common to all.

DATABASE
--------
Not all the tracks are structure and melody annotated. 
This is because melody repetition can corresponds exactly to the structure. 
That is:
a) the structure of the track is defined by the melody repetition 
(the arrangement is always the same except the melody)
b) the structure follow exactly the melody uses.

Among the 20 tracks, we've chosen 
-14 tracks for structure annotation
-11 tracks for melody repetition annotation
 
TRACK LIST
----------

A Ha			Take On Me							structure 
Alanis Morisette	Thank U								structure
Bjork			Oh so quiet							structure
Britney Spears 		Baby one more time						structure
Chumbawamba		Tubthumping							structure
Crannberies		Zombie								structure
Deus			Suds and Soda							structure
RadioHead 		Creep								structure
Seal 			Crazy								structure
Spice Girls		Wannabe								structure
The Clash		Should I Stay of Should I go					structure				

Dave Brubeck		Take Five					melody
Moby			Natural Blues					melody
Moby			What does my heart feel so bad ?		melody
Pink Floyd 		Another Brick In the Wall (Part II)		melody
Pink Martini		Sympathique "Je ne veux pas travailler"		melody
The Beatles		Hard Day's Night				melody
The Beatles		She Loves You					melody
The Beatles		Love Me Do					melody

Alanis Morisette	Head Over Feet					melody		structure
Nirvana			Smells Like Teen Spirit				melody		structure
Oasis			Wonderwall					melody		structure