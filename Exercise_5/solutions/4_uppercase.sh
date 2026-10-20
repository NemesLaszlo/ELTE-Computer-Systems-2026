#!/bin/bash
# 4. feladat: A paraméterként kapott fájl tartalmát nagybetűsre cseréli
# (magát a fájlt írja át).
#
# Futtatás (a tasks mappából):
#   ../solutions/4_uppercase.sh all_lower.txt
#
# Figyelem: a script a fájlt módosítja! Érdemes először egy másolaton
# kipróbálni, pl. az 1. feladat scriptjével:
#   ../solutions/1_copy.sh all_lower.txt test.txt
#   ../solutions/4_uppercase.sh test.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# Írnunk is kell a fájlba, ezért az írási jogot (-w) is ellenőrizzük.
if [ ! -w "$file" ]; then
    echo "Error: file '$file' is not writable" >&2
    exit 1
fi

# A tr a bemenet karaktereit cseréli: minden kisbetűt a nagybetűs párjára.
#   < "$file"        a bemenet (stdin) a fájlból érkezik
#   > "$file.tmp"    a kimenet (stdout) egy ideiglenes fájlba kerül
#
# Fontos: a  tr ... < "$file" > "$file"  NEM működne! A shell a > miatt
# először kiürítené a fájlt, és a tr már egy üres fájlt olvasna.
# Ezért előbb ideiglenes fájlba írunk, majd azzal írjuk felül az eredetit.
tr '[:lower:]' '[:upper:]' < "$file" > "$file.tmp"

# mv: az ideiglenes fájl átnevezése az eredeti nevére (felülírja az eredetit).
mv "$file.tmp" "$file"

echo "All letters in '$file' have been changed to uppercase."
