#!/bin/bash
# 11. feladat: Beolvas egy számot a billentyűzetről, és kiírja a számjegyeinek
# összegét:  1234 -> 1+2+3+4 = 10
#
# Futtatás:
#   ../solutions/11_digit_sum.sh
#   echo 1234 | ../solutions/11_digit_sum.sh           a bemenet csővezetékből

read -r -p "Enter a number: " number

# Csak nemnegatív egész számot fogadunk el.
if [[ ! $number =~ ^[0-9]+$ ]]; then
    echo "Error: '$number' is not a non-negative integer" >&2
    exit 1
fi

sum=0

# Végigmegyünk a szám karakterein (0-tól hossz-1-ig), és minden számjegyet
# hozzáadunk az összeghez. A ${number:i:1} az i-edik karakter.
for (( i=0; i<${#number}; i++ )); do
    digit=${number:i:1}
    sum=$(( sum + digit ))
done

echo "Sum of digits: $sum"

# Ugyanez aritmetikával (lásd a 10. feladatot): a % 10 az utolsó számjegy,
# a / 10 levágja azt.
#   while (( number > 0 )); do
#       sum=$(( sum + number % 10 ))
#       number=$(( number / 10 ))
#   done
