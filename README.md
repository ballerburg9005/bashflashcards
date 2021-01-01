Bash Flash Cards
================

This is a simple bash script to train vocabulary.

bashflashcards [OPTION] file1.txt [file2.txt] .. [fileN.txt]  
OPTION: -r -reverse		Switches between asking for meaning or word.  

file1.txt has the following format as in the example file:  
#comments  
word1	meaning, meaning, meaning  
word2[:space:]+meaning,meaning,meaning  
...  

The script will shuffle the words and then ask for them, with wrong answers being shuffled and appended at the end.  

It will detect the right or wrong answer even if it is merely spelled in ASCII and also if it contains at most one typo.  

Example:   

correct answer: diĝir  
* user input: d1gir -> validates as correct (only one wrong character, any amount of non-ASCII characters are transcribed to the next best thing)  
* user input: d1g1r -> validates as wrong (two wrong characters)  
* user input: igir -> validates as correct (one missing character)  


I did not test this much yet.
