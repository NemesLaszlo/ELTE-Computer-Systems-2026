#!/bin/bash
# 5. feladat: Függvény, amely a paraméterként kapott szám faktoriálisát
# számolja ki, majd meghívjuk a script első paraméterével.
#
# Futtatás:
#   ./5_factorial.sh 5     -> 5! = 120
#   ./5_factorial.sh 0     -> 0! = 1

# A függvényt a használata ELŐTT definiáljuk.
#
# Az eredményt echo-val "adjuk vissza", a hívó pedig a $( ... )
# parancsbehelyettesítéssel menti változóba. A return erre nem alkalmas:
# az csak egy 0-255 közötti állapotkódot ad vissza.
Factorial() {
    local n=$1
    local result=1
    local i

    # n! = 1 * 2 * 3 * ... * n   (az 1-gyel való szorzás kihagyható, 2-től indulunk)
    # Ha n = 0 vagy 1, a ciklus egyszer sem fut le, az eredmény 1 marad.
    for (( i=2; i<=n; i++ )); do
        result=$(( result * i ))
    done

    echo "$result"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number>" >&2
    exit 1
fi

if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "Error: '$1' is not a non-negative integer" >&2
    exit 1
fi

# A függvény hívása a script első paraméterével, az eredmény mentése.
result=$(Factorial "$1")
echo "$1! = $result"

# Megjegyzés: a bash 64 bites egész számokkal dolgozik, ezért 20! a legnagyobb
# faktoriális, amit még helyesen kiszámol; 21!-tól az eredmény "túlcsordul".
