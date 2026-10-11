#!/bin/bash
# 3. feladat (ciklusos megoldás): Megkeresi egy könyvtárban és annak
# alkönyvtáraiban azokat a fájlokat, amelyek tartalmazzák a megadott szót.
# A find helyett egy önmagát hívó (rekurzív) függvény járja be a könyvtárakat,
# a grep -q helyett egy while ciklus nézi végig a fájl sorait.
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/3_find_files_with_word.sh main_folder banan

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <word>" >&2
    exit 1
fi

directory=$1
word=$2

if [ ! -d "$directory" ]; then
    echo "Error: directory '$directory' does not exist" >&2
    exit 1
fi

# --- Függvények ---------------------------------------------------------------

# Igaz (0) a visszatérési értéke, ha a fájl valamelyik sora tartalmazza a
# szót, különben hamis (1). Ez a  grep -q "$word" "$file"  megfelelője.
contains_word() {
    local file=$1
    local line

    while IFS= read -r line || [ -n "$line" ]; do
        # [[ szöveg == *minta* ]]: igaz, ha a minta bárhol előfordul a szövegben.
        # A "$word" idézőjelben van, így a benne lévő * vagy ? nem helyettesítő
        # karakter, hanem sima szöveg.
        if [[ $line == *"$word"* ]]; then
            return 0            # megvan, a fájl többi részét már nem kell olvasni
        fi
    done < "$file"

    return 1
}

# Bejárja a könyvtárat: a fájlokat megvizsgálja, az alkönyvtárakra pedig
# önmagát hívja meg (rekurzió). Ez a  find "$dir" -type f  megfelelője.
search_dir() {
    local dir=$1
    local entry

    # A * a könyvtár elemeit ábécérendben adja vissza.
    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            # Alkönyvtár: a függvény meghívja önmagát, és bejárja azt is.
            search_dir "$entry"
        elif [ -f "$entry" ] && contains_word "$entry"; then
            # Sima fájl, amelyben benne van a szó.
            echo "$entry"
        fi
        # Üres könyvtárban a "$dir"/* szó szerint marad: ez se nem könyvtár,
        # se nem fájl, így egyik ág sem fut le rá.
    done
}

# --- Főprogram ----------------------------------------------------------------
# A directory végéről levágjuk a / jelet (ha van), hogy ne legyen "a//b" alakú útvonal.
search_dir "${directory%/}"

# Megjegyzés:
#   - a * nem illeszkedik a ponttal kezdődő (rejtett) fájlokra, a find viszont
#     azokat is megtalálja;
#   - a find nem rendezi a kimenetét (a fájlrendszertől függő sorrendben ír),
#     ezért a két megoldás sorrendje eltérhet, a találatok viszont ugyanazok.
