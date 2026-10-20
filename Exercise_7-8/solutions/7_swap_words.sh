#!/bin/bash
# 7. feladat: A fájl minden sorában két szó van. Soronként megcseréli a két
# szó sorrendjét:  asd1 asd2 -> asd2 asd1
#
# Futtatás (a tasks mappából):
#   ../solutions/7_swap_words.sh word_pairs.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    # A sor szavakra bontása: a read a szóközöknél vág, az első szó a word1,
    # a második a word2 változóba kerül (lásd 5. hét: read … <<< "$line").
    # Ha a sorban kettőnél több szó lenne, a maradék a word2 végére kerülne,
    # ezért van egy harmadik, nem használt rest változó is.
    read -r word1 word2 rest <<< "$line"

    # A két szót fordított sorrendben írjuk ki.
    echo "$word2 $word1"
done < "$file"

# Más megoldások:
#   sed -E 's/^([^ ]+) ([^ ]+)$/\2 \1/' "$file"
#       a két ( ) csoport a két szó ([^ ]+ : szóköz nélküli karakterek),
#       a \2 \1 fordított sorrendben írja vissza őket (lásd 4. hét)
#   awk '{print $2, $1}' "$file"
#       az awk szövegfeldolgozó program, amely a sort magától mezőkre bontja
#       ($1, $2, …); a kurzuson nem tanuljuk, de a gyakorlatban sokszor látni.
