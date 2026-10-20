#!/bin/bash
# 6. feladat: A fájlban kétjegyű számok vannak, soronként egy. Minden számot
# a számjegyek fordított sorrendjében írunk ki:  12 -> 21,  90 -> 09
#
# Futtatás (a tasks mappából):
#   ../solutions/6_reverse_two_digits.sh two_digit_numbers.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

while IFS= read -r number || [ -n "$number" ]; do
    number=${number%$'\r'}          # Windows-os sorvég (\r) levágása

    if [ -z "$number" ]; then       # üres sor kihagyása
        continue
    fi

    # Pontosan két számjegy: ^[0-9]{2}$ – a többi sort nem írjuk ki.
    if [[ $number =~ ^[0-9]{2}$ ]]; then
        # Részszöveg (lásd 4. hét): ${szöveg:kezdet:hossz}, az indexelés 0-tól
        # indul. ${number:0:1} az első, ${number:1:1} a második számjegy,
        # ezeket fordított sorrendben fűzzük össze.
        reversed_number="${number:1:1}${number:0:1}"
        echo "$reversed_number"
    fi
done < "$file"

# Más megoldások:
#   echo "$number" | rev        a rev parancs megfordít egy szöveget (Linuxon
#                               van, a Git Bash-ből hiányzik)
#   sed -E 's/^([0-9])([0-9])$/\2\1/' "$file"
#                               a ( ) csoportokra a \1, \2 hivatkozik (lásd 4. hét),
#                               és fordított sorrendben írjuk vissza őket
