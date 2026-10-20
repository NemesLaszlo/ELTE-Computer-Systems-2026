#!/bin/bash
# 4. feladat: Kiírja a fájl azon sorait, amelyekben sem az "alma", sem a
# "körte", sem a paraméterként megadott szó nem szerepel.
#
# Futtatás (a tasks mappából):
#   ../solutions/4_exclude_words.sh fruits.txt asd

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file> <search_word>" >&2
    exit 1
fi

file=$1
search_word=$2

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# Három feltétel ÉS kapcsolattal (&&): a sor egyik szót sem tartalmazhatja.
# A != és a *minta* glob minta azt vizsgálja, hogy a szó NEM része a sornak.
while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    if [[ $line != *"alma"* && $line != *"körte"* && $line != *"$search_word"* ]]; then
        echo "$line"
    fi
done < "$file"

# Ugyanez egyetlen paranccsal: több -e minta, a grep -v mindet kizárja.
#   grep -v -e alma -e körte -e "$search_word" "$file"
