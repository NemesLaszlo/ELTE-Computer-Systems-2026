#!/bin/bash
# 7. feladat (ciklusos megoldás): Biztonsági mentés készítése egy könyvtár
# .txt fájljairól. A basename helyett paraméterkifejtést, a cp helyett
# soronkénti másolást használunk (lásd az 1. feladatot).
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/7_backup.sh main_folder
#   -> main_folder_backup_2026-10-07/text1.txt, text3.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

# ${1%/}: ha a könyvtárat "main_folder/" alakban kaptuk, a záró / jelet
# levágjuk, így nem lesz "main_folder//text1.txt" alakú útvonal.
directory=${1%/}

if [ ! -d "$directory" ]; then
    echo "Error: directory '$directory' does not exist" >&2
    exit 1
fi

# --- Függvények ---------------------------------------------------------------

# Egy fájl soronkénti másolása (az 1. feladat megoldása függvényként).
# A másolat bájtra azonos: a záró újsor nélküli utolsó sort is újsor nélkül írjuk.
copy_file() {
    local source=$1
    local target=$2
    local line

    {
        while IFS= read -r line; do
            printf '%s\n' "$line"
        done
        if [ -n "$line" ]; then
            printf '%s' "$line"
        fi
    } < "$source" > "$target"
}

# --- Mentés -------------------------------------------------------------------
# A könyvtár nevének utolsó tagja a basename parancs nélkül:
#   ${directory##*/}   az elejéről a legutolsó /-ig mindent levág ("a/b/c" -> "c")
dir_name=${directory##*/}

backup_dir="${dir_name}_backup_$(date +%F)"

mkdir -p "$backup_dir"

count=0

for file in "$directory"/*.txt; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # A célfájl neve: a mentési könyvtár + a fájl neve (az útvonal nélkül).
    copy_file "$file" "$backup_dir/${file##*/}"
    echo "Copied: $file"
    ((count++))
done

if [ "$count" -eq 0 ]; then
    echo "No .txt files found in '$directory'."
    rmdir "$backup_dir"
    exit 0
fi

echo "$count file(s) backed up to '$backup_dir'."
