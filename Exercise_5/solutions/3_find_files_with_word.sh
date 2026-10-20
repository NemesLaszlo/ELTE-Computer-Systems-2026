#!/bin/bash
# 3. feladat: Megkeresi egy könyvtárban és annak alkönyvtáraiban azokat a
# fájlokat, amelyek tartalmazzák a megadott szót, és kiírja a nevüket.
#
# Futtatás (a tasks mappából):
#   ../solutions/3_find_files_with_word.sh main_folder banan

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <word>" >&2
    exit 1
fi

directory=$1
word=$2

# A kiindulási könyvtárnak léteznie kell (-d: létezik és könyvtár).
if [ ! -d "$directory" ]; then
    echo "Error: directory '$directory' does not exist" >&2
    exit 1
fi

# A find -type f a könyvtár alatti ÖSSZES sima fájlt kilistázza (az
# alkönyvtárakban lévőket is), soronként egyet. Ezt a listát a csővezetéken (|)
# keresztül egy while ciklusnak adjuk át, amely soronként, vagyis fájlonként
# olvassa be a file változóba.
#
# grep -q ("quiet"): nem ír ki semmit, csak a kilépési kódjával jelzi, hogy
# volt-e találat (0 = igen, 1 = nem). Pont ezért használható if feltételként.
find "$directory" -type f | while read -r file; do
    if grep -q "$word" "$file"; then
        echo "$file"
    fi
done

# Ugyanez egyetlen paranccsal:
#   grep -rl "$word" "$directory"
#   -r  rekurzívan, az alkönyvtárakat is bejárva keres
#   -l  a találati sorok helyett csak a fájlok nevét írja ki
