#!/bin/bash
# 4. feladat: Kiírja 1-től a paraméterként kapott számig a páros számokat.
#
# Futtatás:
#   ./4_even_numbers.sh 10     -> 2 4 6 8 10

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number>" >&2
    exit 1
fi

n=$1

# Csak nemnegatív egész számot fogadunk el.
if [[ ! $n =~ ^[0-9]+$ ]]; then
    echo "Error: '$n' is not a non-negative integer" >&2
    exit 1
fi

# 1. megoldás: végigmegyünk az összes számon, és csak a párosakat írjuk ki.
# (( i % 2 == 0 )): a 2-vel való osztás maradéka 0, vagyis a szám páros.
echo "Checking every number:"
for (( i=1; i<=n; i++ )); do
    if (( i % 2 == 0 )); then
        echo -n "$i "       # -n: nem tesz sortörést a kiírás végére
    fi
done
printf "\n"

# 2. megoldás: 2-től indulunk, és kettesével lépünk (i+=2), így eleve csak
# páros számokon megyünk végig. Kevesebb lépés, és nem kell feltétel.
echo "Stepping by two:"
for (( i=2; i<=n; i+=2 )); do
    echo -n "$i "
done
printf "\n"
