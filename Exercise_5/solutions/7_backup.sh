#!/bin/bash
# 7. feladat: Biztonsági mentés készítése egy könyvtár .txt fájljairól.
# A script létrehoz egy <könyvtár>_backup_<dátum> nevű könyvtárat az aktuális
# könyvtárban, belemásolja a megadott könyvtárban (közvetlenül) található
# .txt fájlokat, majd kiírja, hány fájlt mentett.
#
# Futtatás (a tasks mappából):
#   ../solutions/7_backup.sh main_folder
#   -> main_folder_backup_2026-10-07/text1.txt, text3.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

directory=$1

if [ ! -d "$directory" ]; then
    echo "Error: directory '$directory' does not exist" >&2
    exit 1
fi

# A mentés könyvtárának neve: a könyvtár neve + _backup_ + a mai dátum.
#   basename   az útvonal utolsó tagja (pl. "a/b/main_folder/" -> "main_folder"),
#              így a név akkor is jó, ha teljes útvonalat kaptunk
#   date +%F   a mai dátum ÉÉÉÉ-HH-NN formában
# Mindkettő parancsbehelyettesítéssel, $( ), kerül a szövegbe.
backup_dir="$(basename "$directory")_backup_$(date +%F)"

# -p: nem hiba, ha a könyvtár már létezik (pl. aznap másodszor futtatjuk).
mkdir -p "$backup_dir"

count=0

# A "$directory"/*.txt minta a könyvtár összes .txt végű fájljára illeszkedik.
# (Csak a könyvtárban közvetlenül lévőkre, az alkönyvtárakba nem megy bele.)
for file in "$directory"/*.txt; do
    # Ha egyetlen .txt fájl sincs, a minta nem fejtődik ki, hanem szó szerint
    # (pl. "main_folder/*.txt") kerül a file változóba. Ezt az -f vizsgálattal
    # szűrjük ki: ilyen nevű fájl nem létezik, ezért átugorjuk.
    if [ ! -f "$file" ]; then
        continue
    fi

    cp "$file" "$backup_dir"
    echo "Copied: $file"
    ((count++))
done

if [ "$count" -eq 0 ]; then
    echo "No .txt files found in '$directory'."
    rmdir "$backup_dir"         # az üresen maradt mentési könyvtár törlése
    exit 0
fi

echo "$count file(s) backed up to '$backup_dir'."
