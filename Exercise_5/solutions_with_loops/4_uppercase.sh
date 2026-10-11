#!/bin/bash
# 4. feladat (ciklusos megoldás): A paraméterként kapott fájl tartalmát
# nagybetűsre cseréli (magát a fájlt írja át). Az egész fájl helyett soronként
# olvasunk, és sorról sorra alakítjuk át a szöveget.
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/1_copy.sh all_lower.txt test.txt
#   ../solutions_with_loops/4_uppercase.sh test.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

if [ ! -w "$file" ]; then
    echo "Error: file '$file' is not writable" >&2
    exit 1
fi

# --- Átalakítás soronként -----------------------------------------------------
# Egy sor nagybetűsítése: a tr a <<< miatt csak a line tartalmát kapja meg.
# A $( ) levágja a <<< által hozzáadott újsort, így a sor vége a ciklusban dől el.
# (Bash 4-től a ${line^^} is ezt adná, de a macOS beépített bash-e 3.2-es,
#  és azt nem ismeri. Az ékezetes betűk átalakítása mindkét esetben a nyelvi
#  beállításon (locale) és a rendszeren múlik.)
#
# Ugyanaz a csapda, mint a tr-nél: nem írhatunk közvetlenül az olvasott fájlba,
# ezért egy ideiglenes fájlba gyűjtjük az eredményt, és a végén átnevezzük.
#
# A fájlvéget ugyanúgy kezeljük, mint az 1. feladatban: a záró újsor nélküli
# utolsó sort a ciklus után, újsor nélkül írjuk ki, így a fájl szerkezete
# (a nagybetűktől eltekintve) nem változik.
{
    while IFS= read -r line; do
        printf '%s\n' "$(tr '[:lower:]' '[:upper:]' <<< "$line")"
    done
    if [ -n "$line" ]; then
        printf '%s' "$(tr '[:lower:]' '[:upper:]' <<< "$line")"
    fi
} < "$file" > "$file.tmp"

mv "$file.tmp" "$file"

echo "All letters in '$file' have been changed to uppercase."
