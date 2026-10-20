#!/bin/bash
# 9. feladat: A fájlban számok és szövegek vannak vegyesen. A NEM csak számot
# tartalmazó sorokat átmásolja egy új fájlba.
#
# Futtatás (a tasks mappából):
#   ../solutions/9_copy_non_numeric.sh numbers_and_text.txt text_only.txt
#   cat text_only.txt

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>" >&2
    exit 1
fi

input_file=$1
output_file=$2

if [ ! -f "$input_file" ]; then
    echo "Error: file '$input_file' does not exist" >&2
    exit 1
fi

# A > kiüríti (vagy létrehozza) a kimeneti fájlt, a ciklusban >>-rel
# hozzáfűzünk (lásd 6. hét).
> "$output_file"

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    # A ! a feltételt tagadja: ha a sor NEM csak számjegyekből áll, másoljuk.
    if [[ ! $line =~ ^[0-9]+$ ]]; then
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

echo "Non-numeric lines copied to '$output_file'."

# Ugyanez egyetlen paranccsal:
#   grep -v -E '^[0-9]+$' "$input_file" > "$output_file"
