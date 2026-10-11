#!/bin/bash
# 2. feladat (ciklusos megoldás): Kiírja a fájl azon sorait, amelyek
# tartalmazzák a paraméterként megadott szót. A grep -iw helyett a sorokat
# és a szavakat mi magunk járjuk be.
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/2_search_word.sh menu.txt bor

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file> <word>" >&2
    exit 1
fi

file=$1
word=$2

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# A kis- és nagybetűk ne számítsanak (grep -i): a nocasematch beállítás után
# a [[ … == … ]] összehasonlítás nem különbözteti meg a kis- és nagybetűket.
# (A bash 4-től a ${változó,,} kisbetűsítés is használható lenne, de a macOS
#  beépített bash-e 3.2-es, és azt nem ismeri.)
shopt -s nocasematch

# --- Sorok bejárása ------------------------------------------------------------
found=0

# || [ -n "$line" ]: a záró újsor nélküli utolsó sort is feldolgozzuk.
# (A read ilyenkor hamisat ad, de a line-ban ott van a sor tartalma.)
while IFS= read -r line || [ -n "$line" ]; do
    # Windows-os (CRLF) sorvég esetén a sor végén egy \r karakter marad,
    # ezt levágjuk: ${line%minta} a sor végéről elhagyja a mintát.
    line=${line%$'\r'}

    # A sort szavakra bontjuk (szóközöknél): read -a a szavakat a words
    # tömbbe teszi, a <<< a read bemenetére a line tartalmát adja.
    read -r -a words <<< "$line"

    # Egész szavakat hasonlítunk (grep -w): "bor" igen, "borsó" nem.
    for w in "${words[@]}"; do
        if [[ $w == "$word" ]]; then
            echo "$line"
            ((found++))
            break               # egy sort elég egyszer kiírni
        fi
    done
done < "$file"

# Megjegyzés: a grep -w a szót írásjelek (pl. vessző) mellett is megtalálja,
# ez a megoldás csak a szóközökkel elválasztott szavakat hasonlítja össze.

if [ "$found" -eq 0 ]; then
    echo "No line contains the word '$word'." >&2
    exit 1
fi
