#!/bin/bash
# 10. feladat: Beolvas egy számot a billentyűzetről, és kiírja a számjegyeit
# fordított sorrendben:  1234 -> 4321
#
# Futtatás:
#   ../solutions/10_reverse_number.sh
#   echo 1234 | ../solutions/10_reverse_number.sh      a bemenet csővezetékből

read -r -p "Enter a number: " number

# Csak nemnegatív egész számot fogadunk el.
if [[ ! $number =~ ^[0-9]+$ ]]; then
    echo "Error: '$number' is not a non-negative integer" >&2
    exit 1
fi

reversed=""

# A számot szövegként kezeljük, és a karakterein hátulról előre lépkedünk:
#   ${#number}      a szöveg hossza (a számjegyek száma)
#   ${number:i:1}   az i-edik karakter (részszöveg: ${szöveg:kezdet:hossz})
# Az utolsó karakter indexe hossz-1, az elsőé 0.
for (( i=${#number}-1; i>=0; i-- )); do
    reversed="$reversed${number:i:1}"
done

echo "Reversed number: $reversed"

# Más megoldások:
#   echo "$number" | rev                 (Linuxon van, a Git Bash-ből hiányzik)
#
#   Aritmetikával, a 10-zel való osztás maradékával: a % 10 az utolsó
#   számjegyet adja, a / 10 pedig levágja azt a számról.
#   while (( number > 0 )); do
#       reversed="$reversed$(( number % 10 ))"
#       number=$(( number / 10 ))
#   done
#   (Ez a 0-ra üres szöveget ad, és az 1200 végén lévő nullák is eltűnnek: 21.)
