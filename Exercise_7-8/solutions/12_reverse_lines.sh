#!/bin/bash
# 12. feladat: Megfordítja a paraméterként kapott fájl sorainak sorrendjét
# (az utolsó sor lesz az első). A sorokat egy tömbben tároljuk átmenetileg,
# és magát a fájlt írjuk felül, ezért érdemes előbb egy másolaton kipróbálni.
#
# Futtatás (a tasks mappából):
#   cp lines.txt test.txt
#   ../solutions/12_reverse_lines.sh test.txt
#   cat test.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# --- 1. lépés: a sorok beolvasása egy tömbbe ----------------------------------
# Az univerzális minta; a "feldolgozás" itt csak annyi, hogy a sort a tömb
# végére tesszük: lines+=("$line") (lásd 5. hét, tömbök).
lines=()

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    lines+=("$line")
done < "$file"

# --- 2. lépés: a tömb bejárása hátulról előre ---------------------------------
# ${#lines[@]} az elemek száma. Az indexek 0-tól (elemszám-1)-ig mennek, ezért
# az utolsó elem indexe ${#lines[@]}-1: innen indulunk, és 0-ig lépkedünk
# visszafelé. Az elemeket egy második tömbbe gyűjtjük fordított sorrendben.
reversed_lines=()

for (( i=${#lines[@]}-1; i>=0; i-- )); do
    reversed_lines+=("${lines[i]}")
done

# --- 3. lépés: visszaírás a fájlba --------------------------------------------
# A fájlt már teljesen beolvastuk (az adatok a tömbben vannak), ezért most
# már biztonságosan felülírhatjuk. A printf minden elemet külön sorba ír.
printf '%s\n' "${reversed_lines[@]}" > "$file"

echo "Lines in the file '$file' have been reversed."

# Megjegyzés: Linuxon a tac parancs ("cat" visszafelé) ugyanezt teszi egy lépésben:
#   tac "$file" > "$file.tmp" && mv "$file.tmp" "$file"
