#!/bin/bash

##### USER SETTINGS #####
MAXTYPOS=1
SEP="[:space:];," # grep
#########################

# measures difference between two words for typo checking
function levenshtein {
    if [ "$#" -ne "2" ]; then
        echo "Usage: $0 word1 word2" >&2
    elif [ "${#1}" -lt "${#2}" ]; then
        levenshtein "$2" "$1"
    else
        local str1len=$((${#1}))
        local str2len=$((${#2}))
        local d i j
        for i in $(seq 0 $(((str1len+1)*(str2len+1)))); do
            d[i]=0
        done
        for i in $(seq 0 $((str1len))); do
            d[$((i+0*str1len))]=$i
        done
        for j in $(seq 0 $((str2len))); do
            d[$((0+j*(str1len+1)))]=$j
        done

        for j in $(seq 1 $((str2len))); do
            for i in $(seq 1 $((str1len))); do
                [ "${1:i-1:1}" = "${2:j-1:1}" ] && local cost=0 || local cost=1
                local del=$((d[(i-1)+str1len*j]+1))
                local ins=$((d[i+str1len*(j-1)]+1))
                local alt=$((d[(i-1)+str1len*(j-1)]+cost))
                d[i+str1len*j]=$(echo -e "$del\n$ins\n$alt" | sort -n | head -1)
            done
        done
        echo ${d[str1len+str1len*(str2len)]}
    fi
}

REVERSE="false"
FILES="$@"
if [[ " --help -help -h " =~ " $1 " || "$1" == "" ]]; then 
	echo "$0 [OPTION] file1.txt [file2.txt] .. [fileN.txt]"
	echo "OPTION: -r -reverse		Switches between asking for the vocabulary word or the meaning of it."
	exit -1
elif [[ " --reverse -r " =~ " $1 " ]]; then
	REVERSE="true"
	FILES="$(echo "$@" | sed "s/^[^ ]* //g")"
fi

for file in $FILES; do
	if ! file $file | grep -q "text"; then
		echo "$FILE doesn't appear to be a text file! Exiting.."
		exit 1
	fi
done

LINESLEFT="$(IFS=' ' cat $FILES | shuf)"

# stats
WRONGCTR="0"
WRONGARR=()

while [[ "$LINESLEFT" != "" ]]; do
	NEWLINES=""
	while read -u 3 line; do
		if [[ "$line" =~ ^"#" ]]; then continue
		elif echo "$line" | grep -q "^[^${SEP}]\+[${SEP}]\+[^${SEP}]\+.*$"; then 
			WORD=("$(echo "$line" | grep -osa "^[^${SEP}]*")")
			WORDS=("$WORD")
			NOMEANING=(); IFS=', ' read -r -a NOMEANING <<< "$(echo "$line" | sed "s/^[^${SEP}]*[${SEP}]\+//g")"
			MEANINGS=(); for i in "${NOMEANING[@]}"; do if [[ "$(echo "$i" | sed "s/[[:space:]\"]*//g")" != "" ]]; then MEANINGS+=("$i"); fi; done

			if [[ "$REVERSE" == "true" ]]; then
				TEMPVAR=("${WORDS[@]}") 
				WORDS=("${MEANINGS[@]}") 
				MEANINGS=("${TEMPVAR[@]}")
				askwords="$(echo ${WORDS[@]} | sed 's/ /, /g')"
			else
				askwords="${WORDS[0]}"
			fi 

			MEANINGSPRINT="$(echo ${MEANINGS[@]} | sed 's/ /, /g')"
			# this adds alternative spellings to the list of correct solutions, in form of: (i)kala(gb) -> kala, ikalagb, kalagb, ikala
			# can only handle up to two parenthesis
			for i in "${MEANINGS[@]}"; do 
				if echo "$i" | grep -osaq "(.\+)"; then

					for j in `echo 	"$(echo "$i" | sed "s/\(.*\)([^\(\)]\+)/\1/") \
							 $(echo "$i" | sed "s/([^\(\)]\+)//") \
							 $(echo "$i" | sed "s/([^\(\)]\+)//g") \
						 	 $(echo "$i")" | sed "s/[\(\)]*//g" | xargs -n1 | sort -u | xargs`; do
						MEANINGS+=("$j")
					done
				fi
			done
			TEMPVAR="$( echo " $askwords " | sed  -e :a -e 's/^.\{1,41\}$/=&=/;ta' )"
			while [ ${#TEMPVAR} -lt 43 ]; do TEMPVAR="=$TEMPVAR"; done
			echo "$TEMPVAR"

			read -p "ANSWER: " answer
			
			echo "$MEANINGSPRINT"

			WRONG="true"
			for meaning in ${MEANINGS[@]}; do
				meaning="$(echo "$meaning" | sed "s/[[:space:]\"]*//g")"
				answer="$(echo "$answer" | sed "s/[[:space:]\"]*//g")"
				# iconv transcribes characters to the next best ASCII thing, used for checking if the answer is sort of correct
				simpmeaning="$(echo "$meaning" | iconv -f utf-8 -t ascii//TRANSLIT | sed "s/[^A-z0-9\-\_]//g")"
				simpanswer="$(echo "$answer" | iconv -f utf-8 -t ascii//TRANSLIT | sed "s/[^A-z0-9\-\_]//g")"
				if [ "$(levenshtein "$simpmeaning" "$simpanswer")" -lt "$(($MAXTYPOS+1))" ] || [[ "$meaning" == "$answer" ]]; then
					WRONG="false"
					echo "                              :)++RIGHT++(:"
					break
				fi
			done

			if [[ "$WRONG" == "true" ]]; then
				WRONGCTR="$(($WRONGCTR + 1))"
				WRONGARR+=("$WORD")
				echo "                              --:(WRONG):--"
				NEWLINES="$(echo -e "$line\n$NEWLINES")"
			fi
		fi
	done 3< <(echo "$LINESLEFT" | shuf)

	LINESLEFT="$NEWLINES"

	if [[ "$LINESLEFT" != "" ]]; then 
		echo "--->Still $(echo "$LINESLEFT" | wc -l ) to go!"
	fi
done

if [[ "$LINESLEFT" == "" ]]; then
	echo "ALL DONE! AWESOME!"
	if [ "$WRONGCTR" -gt "0" ]; then
		echo "STATS: $WRONGCTR wrong answers."
		echo "STATS: Wrong words: $(echo "${WRONGARR[*]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
	else
		echo "YOU MADE ZERO MISTAKES!"
	fi
fi 
