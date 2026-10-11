#!/bin/bash
# 5. heti további gyakorlás, 2. feladat: Egy könyvtár összes .txt fájljáról
# kiírja a nevét és a sorainak számát (wc -l), a végén az összes sor számát.
#
# Futtatás (az exercise_5_solutions mappából):
#   ./2_txt_line_counts.sh main_folder
#
# Figyelem: a main_folder/text3.txt egy sort tartalmaz ("banan"), a wc -l
# mégis 0-t mond rá, mert az újsor karaktereket számolja, és ennek a fájlnak
# az utolsó sora után nincs újsor (lásd a 6. heti anyag "Fájlvégek" részét).

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

directory=$1

if [ ! -d "$directory" ]; then
    echo "Error: directory '$directory' does not exist" >&2
    exit 1
fi

total=0
files=0

for file in "$directory"/*.txt; do
    # Ha nincs .txt fájl, a minta szó szerint kerül a változóba (lásd 5. hét).
    if [ ! -f "$file" ]; then
        continue
    fi

    # A < miatt a wc csak a számot írja ki; a $(( )) a macOS-en a szám elé
    # tett szóközöket is eltünteti.
    lines=$(( $(wc -l < "$file") ))
    echo "$file: $lines"
    total=$(( total + lines ))
    files=$(( files + 1 ))
done

if [ "$files" -eq 0 ]; then
    echo "No .txt files in '$directory'."
    exit 0
fi

echo "Total: $total line(s) in $files file(s)"
