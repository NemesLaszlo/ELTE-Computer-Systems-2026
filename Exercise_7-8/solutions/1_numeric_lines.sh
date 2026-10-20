#!/bin/bash
# 1. feladat: A paraméterként kapott fájlból kiírja azokat a sorokat, amelyek
# csak egy számot tartalmaznak. Az egész számok mellett a valós (tizedes)
# számokat és az előjelet is elfogadjuk:  23   -12.2   +7   .5
#
# Futtatás (a tasks mappából):
#   ../solutions/1_numeric_lines.sh numbers_mixed.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file_name=$1

if [ ! -f "$file_name" ]; then
    echo "Error: file '$file_name' does not exist" >&2
    exit 1
fi

# A reguláris kifejezés részei (=~ : illeszkedik-e a sor a mintára):
#   ^          a sor eleje
#   [+-]?      opcionális előjel
#   [0-9]*     a tizedespont előtti számjegyek (lehet, hogy egy sincs: .5)
#   \.?        opcionális tizedespont (a \ miatt a . nem "bármilyen karakter")
#   [0-9]+     legalább egy számjegy a végén (így a "12." nem szám)
#   $          a sor vége: utána nem jöhet semmi (a "33.3o" ezért kiesik)
#
# A fájlt a 6. heti univerzális mintával olvassuk: a numbers_mixed.txt utolsó
# sora (-12.2) után nincs újsor, ezért kell a || [ -n "$line" ]; a Windows-os
# \r levágása nélkül a $ horgony nem illeszkedne.
while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    if [[ $line =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then
        echo "$line"
    fi
done < "$file_name"

# Ugyanez egyetlen paranccsal, ciklus nélkül (-E: kiterjesztett regex):
#   grep -E '^[+-]?[0-9]*\.?[0-9]+$' "$file_name"
