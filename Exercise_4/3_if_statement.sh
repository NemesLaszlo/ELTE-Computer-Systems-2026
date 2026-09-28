#!/bin/bash
# Elágazás (if / elif / else) számok összehasonlításával.
#
# Futtatás:
#   ./3_if_statement.sh        -> az alapértelmezett értékkel (10) dolgozik
#   ./3_if_statement.sh 7      -> a megadott számmal dolgozik

# ${1:-10}: ha van első paraméter, azt használjuk, különben 10 az érték.
n=${1:-10}

# Számok összehasonlítása a [ ] (test) parancsban:
#   -eq  egyenlő              (equal)
#   -ne  nem egyenlő          (not equal)
#   -lt  kisebb               (less than)
#   -le  kisebb vagy egyenlő  (less or equal)
#   -gt  nagyobb              (greater than)
#   -ge  nagyobb vagy egyenlő (greater or equal)
#
# Fontos: a [ után és a ] előtt kötelező a szóköz!
# A változót idézőjelbe tesszük, hogy üres érték esetén se kapjunk szintaktikai hibát.
if [ "$n" -lt 10 ]; then
    echo "It is a one digit number"
elif [ "$n" -lt 100 ]; then
    echo "It is a two digit number"
else
    echo "It has three or more digits"
fi

# Ugyanez aritmetikai kifejezéssel is leírható, itt a megszokott operátorok
# használhatók (<, <=, >, >=, ==, !=), és a változó elé nem kell $ jel:
if (( n % 2 == 0 )); then
    echo "$n is even"
else
    echo "$n is odd"
fi
