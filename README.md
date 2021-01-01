Bash Flash Cards
================

This is a bash script to train vocabulary, alike flash cards.

	bashflashcards [OPTION] file1.txt [file2.txt] .. [fileN.txt]  
	OPTION: -r -reverse		Switches between asking for meaning or word.  

file1.txt has the following format as in the example file "lesson1.txt":  

	#comments  
	word		meaning, meaning, meaning  
	word[:space:],;\+meaning,meaning,	meaning
	word,meaning,meaning,meaning
	...  

It should thereby also be able to read regular CSV files.

The script will shuffle the words and then ask for them, with wrong answers being shuffled and appended at the end.  

It will detect the right or wrong answer, even if you only use ASCII characters and also if it contains at most one typo. 

Parenthesis are used for alternative spelling, e.g. lu(h)gal(l) validates correct as luhgal, luhgall, lugal, lugall

Example:   

correct answer: diĝi(r)  
* user input: d1gir -> validates as correct (only one wrong character, any amount of non-ASCII characters are transcribed to the next best thing)  
* user input: d1g1r -> validates as wrong (two wrong characters)  
* user input: igi -> validates as correct (one missing character and anything in parenthesis is optional)  
* user input: œigir -> by rare exception this would validate as wrong, because "œ" is transcribed as "oe" for validation, thus oeigir is counted as having two incorrect characters

Sample Output
=============

 % bashflashcards lession1_abridged.txt

	================= dub-sar =================
	ANSWER: tablet-writer (user input)
	scribe, "tablet-writer"
				      :)++RIGHT++(:
	=================== me₃ ===================
	ANSWER: combat
	battle, combat
				      :)++RIGHT++(:
	================== nita₂ ==================
	ANSWER: men 
	man, male
				      :)++RIGHT++(:
	================= kala(g) =================
	ANSWER: mightyy
	mighty
				      :)++RIGHT++(:
	=================== tur ===================
	ANSWER: young
	small, young
				      :)++RIGHT++(:
	ALL DONE! AWESOME!
	YOU MADE ZERO MISTAKES!

 % bashflashcards -r lession1_abridged.txt

	============== battle, combat =============
	ANSWER: nita2 (user input)
	me₃
				      --:(WRONG):--
	========= scribe, "tablet-writer" =========
	ANSWER: dubsar
	dub-sar
				      :)++RIGHT++(:
	=============== small, young ==============
	ANSWER: kur
	tur
				      :)++RIGHT++(:
	================ man, male ================
	ANSWER: nita2
	nita₂
				      :)++RIGHT++(:
	================== mighty =================
	ANSWER: zkalag
	kala(g)
				      :)++RIGHT++(:
	--->Still 1 to go!
	============== battle, combat =============
	ANSWER: me₃
	me₃
				      :)++RIGHT++(:
	ALL DONE! AWESOME!
	STATS: 1 wrong answers.
	STATS: Wrong words: me₃ 

