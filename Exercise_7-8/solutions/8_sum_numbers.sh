#!/bin/bash
# 8. feladat: A fájlban soronként egy szám van. Összeadja a számokat, a nem
# szám sorokat figyelmeztetéssel kihagyja.
#
# Futtatás (a tasks mappából):
#   ../solutions/8_sum_numbers.sh numbers.txt       -> 20

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

sum=0

while IFS= read -r number || [ -n "$number" ]; do
    number=${number%$'\r'}          # Windows-os sorvég (\r) levágása

    if [ -z "$number" ]; then       # üres sor kihagyása
        continue
    fi

    # Csak az egész számokat adjuk össze; a többi sorra figyelmeztetünk.
    if [[ $number =~ ^[0-9]+$ ]]; then
        sum=$(( sum + number ))
    else
        echo "Warning: skipping invalid number: '$number'" >&2
    fi
done < "$file"

echo "Sum of numbers in the file: $sum"
