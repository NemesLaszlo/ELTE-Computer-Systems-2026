#!/bin/bash
# 8. feladat: Szöveges fájl "rendbetétele". Az új fájlban:
#   - nincs Windows-os \r karakter,
#   - a sorok elején és végén nincs felesleges szóköz,
#   - nincsenek üres sorok,
#   - az utolsó sor után is van újsor.
#
# Futtatás (a tasks mappából):
#   ../solutions/8_normalize_file.sh messy.txt clean.txt
#   cat -et clean.txt

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

# Ha a kimenet ugyanaz a fájl, mint a bemenet, a > még az olvasás előtt kiürítené.
if [ "$input_file" -ef "$output_file" ]; then
    echo "Error: the input and the output file must be different" >&2
    exit 1
fi

# tr -d '\r'      a \r karakterek törlése az egész fájlból
# read -r line    IFS= NÉLKÜL: így a read levágja a sor eleji és végi szóközöket
# [ -n "$line" ]  csak a nem üres sorokat írjuk ki
# Az echo minden sor után újsort ír, így az utolsó sor is újsorral végződik.
# A > a teljes ciklus kimenetét a fájlba írja.
tr -d '\r' < "$input_file" | while read -r line || [ -n "$line" ]; do
    if [ -n "$line" ]; then
        echo "$line"
    fi
done > "$output_file"

echo "Normalized file written to '$output_file'."
