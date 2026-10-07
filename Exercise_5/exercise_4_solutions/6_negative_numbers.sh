#!/bin/bash
# 6. feladat: A numbers.txt fájlból csak a negatív egész számokat tartalmazó
# sorok kiválogatása reguláris kifejezéssel.
#
# Futtatás:
#   ./6_negative_numbers.sh                -> a script melletti numbers.txt fájlt dolgozza fel
#   ./6_negative_numbers.sh masik.txt      -> a megadott fájlt dolgozza fel

# Ha nem kapunk paramétert, a numbers.txt az alapértelmezett fájl.
file=${1:-numbers.txt}

if [ ! -f "$file" ]; then
    echo "File not found: $file" >&2
    exit 1
fi

# A reguláris kifejezés részei:
#   ^        a sor eleje
#   -        kötelező mínuszjel (ettől negatív a szám)
#   [0-9]+   legalább egy számjegy
#   $        a sor vége (nem jöhet utána semmi, pl. tizedesjel)
#
# Így a "-13.321" nem illeszkedik (tizedes tört), a "-7" és a "-42" igen.
# A mintát aposztrófok közé írjuk, hogy a shell ne értelmezze a $ jelet.
echo "Negative integers in $file:"
grep -E '^-[0-9]+$' "$file"

# Ugyanaz a minta a -c kapcsolóval: csak az illeszkedő sorok számát írja ki.
echo "Count: $(grep -cE '^-[0-9]+$' "$file")"
