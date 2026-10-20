#!/bin/bash
# 7. feladat: A bemeneti fájl számait (soronként egy egész szám) átírja a
# kimeneti fájlba, és a végére írja az összegüket:  Sum: <összeg>
# Az üres és a hibás sorokat kihagyja.
#
# Futtatás (a tasks mappából):
#   ../solutions/7_sum_numbers.sh numbers_mixed.txt result.txt
#   cat result.txt

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

sum=0
line_number=0

# A > kiüríti a kimeneti fájlt, utána a ciklusban >>-rel hozzáfűzünk.
> "$output_file"

while IFS= read -r line || [ -n "$line" ]; do
    line_number=$(( line_number + 1 ))

    # A szóközök, tabok és a Windows-os \r törlése (mind "space" jellegű karakter).
    number=$(echo "$line" | tr -d '[:space:]')

    # Üres sor: kihagyjuk.
    if [ -z "$number" ]; then
        continue
    fi

    # Nem egész szám: figyelmeztetés, és kihagyjuk.
    if [[ ! $number =~ ^-?[0-9]+$ ]]; then
        echo "Warning: line $line_number is not an integer, skipped: '$number'" >&2
        continue
    fi

    echo "$number" >> "$output_file"
    sum=$(( sum + number ))
done < "$input_file"

echo "Sum: $sum" >> "$output_file"
echo "Sum: $sum"
