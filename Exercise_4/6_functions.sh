#!/bin/bash
# Függvények.
#
# Futtatás:
#   ./6_functions.sh

# --- Függvény definiálása ----------------------------------------------------
# Két írásmód létezik, a működésük azonos:
#   function nev { ... }
#   nev() { ... }          <- ez a hordozhatóbb, ezt érdemes használni
#
# A függvényt a használata ELŐTT kell definiálni.
function F1 {
    echo 'This is a function'
}

# Hívás: csak a nevét írjuk le, zárójelek nélkül.
F1

# --- Paraméterek -------------------------------------------------------------
# A függvény a paramétereit ugyanúgy éri el, mint a script: $1, $2, ..., $#, $@
# A local kulcsszóval a változó csak a függvényen belül létezik.
# $(( ... )): aritmetikai kifejezés kiértékelése.
Rectangle_Area() {
    local area=$(( $1 * $2 ))
    echo "Area is : $area"
}

Rectangle_Area 10 20

# --- Érték "visszaadása" -----------------------------------------------------
# A függvény az eredményt kiírja (echo), a hívó pedig a $( ... )
# parancsbehelyettesítéssel változóba menti.
Square() {
    echo $(( $1 * $1 ))
}

result=$(Square 7)
echo "Square of 7 is : $result"

# --- Visszatérési érték (exit status) ----------------------------------------
# A return egy 0-255 közötti állapotkódot ad vissza: 0 = siker (igaz), más = hiba (hamis).
# Ezért a függvény közvetlenül használható if feltételként.
Is_Even() {
    if (( $1 % 2 == 0 )); then
        return 0
    else
        return 1
    fi
}

if Is_Even 4; then
    echo "4 is even"
fi

Is_Even 5
# $?: az utoljára futtatott parancs / függvény visszatérési értéke
echo "Exit status of Is_Even 5 : $?"
