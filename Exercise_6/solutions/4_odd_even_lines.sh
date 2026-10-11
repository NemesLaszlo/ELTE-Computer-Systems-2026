#!/bin/bash
# 4. feladat: A paraméterként kapott fájl páratlan sorai az odd_lines.txt,
# páros sorai az even_lines.txt fájlba kerülnek.
#
# Futtatás (a tasks mappából):
#   ../solutions/4_odd_even_lines.sh lines.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

input_file=$1

if [ ! -f "$input_file" ]; then
    echo "Error: file '$input_file' does not exist" >&2
    exit 1
fi

# A > kiüríti (vagy létrehozza) a fájlokat. Enélkül a második futtatás az
# első eredmény végére írna, mert a ciklusban >>-rel hozzáfűzünk.
> odd_lines.txt
> even_lines.txt

line_number=1

# A lines.txt utolsó sora (asd5) után nincs újsor. A read ilyenkor hamisat ad,
# pedig a sort beolvasta: a || [ -n "$line" ] miatt ezt is feldolgozzuk.
while IFS= read -r line || [ -n "$line" ]; do
    if (( line_number % 2 == 1 )); then
        echo "$line" >> odd_lines.txt
    else
        echo "$line" >> even_lines.txt
    fi
    line_number=$(( line_number + 1 ))
done < "$input_file"

echo "Odd lines:  odd_lines.txt"
echo "Even lines: even_lines.txt"
