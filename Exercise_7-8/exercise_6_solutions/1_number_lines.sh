#!/bin/bash
# 6. heti további gyakorlás, 1. feladat: A bemeneti fájl (poem.txt) sorait
# egy új fájlba írja  <sorszám>: <sor>  formában. Az üres sorok üresen
# maradnak, és nem kapnak sorszámot.
#
# Futtatás (az exercise_6_solutions mappából):
#   ./1_number_lines.sh poem.txt poem_numbered.txt
#   cat poem_numbered.txt
#
# Figyelem: a poem.txt utolsó sora ("Vége a versnek.") után nincs újsor.
# A || [ -n "$line" ] nélkül ez a sor kimaradna, és a kimenet 4-nél állna meg.

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

number=0

# A > kiüríti a kimeneti fájlt, utána a ciklusban >>-rel hozzáfűzünk.
> "$output_file"

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég levágása

    # Üres sor: üresen marad, sorszám nélkül (az echo paraméter nélkül egy
    # üres sort ír).
    if [ -z "$line" ]; then
        echo >> "$output_file"
        continue
    fi

    number=$(( number + 1 ))
    echo "$number: $line" >> "$output_file"
done < "$input_file"

echo "$number numbered line(s) written to '$output_file'."
