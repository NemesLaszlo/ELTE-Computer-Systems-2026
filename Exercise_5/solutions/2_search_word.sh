#!/bin/bash
# 2. feladat: Kiírja a fájl azon sorait, amelyek tartalmazzák a paraméterként
# megadott szót.
#
# Futtatás (a tasks mappából):
#   ../solutions/2_search_word.sh menu.txt bor

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

# grep: a mintára illeszkedő sorokat írja ki.
#   -i  nem különbözteti meg a kis- és nagybetűket ("bor" és "Bor" is találat)
#   -w  csak egész szóként illeszkedik ("bor" igen, "borsó" nem)
#
# A "$word" változót idézőjelbe tesszük: így a szóközt tartalmazó keresett
# kifejezés is egyetlen paraméterként jut el a grep-hez.
#
# A grep kilépési kódja: 0 = volt találat, 1 = nem volt találat, 2 = hiba.
# Az if ezt vizsgálja: ha a grep "sikertelen" (nincs találat), üzenetet írunk ki.
# A találatokat maga a grep írja ki, azzal nekünk nincs teendőnk.
if ! grep -iw "$word" "$file"; then
    echo "No line contains the word '$word'." >&2
    exit 1
fi
