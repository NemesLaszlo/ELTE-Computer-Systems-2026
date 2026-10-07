#!/bin/bash
# 2. feladat: Két szám összege, különbsége és szorzata.
# Hibás paraméterszám esetén használati útmutatót ír ki (a standard errorra),
# és nem nulla kilépési kóddal áll le.
#
# Futtatás:
#   ./2_calculator.sh 7 3
#   ./2_calculator.sh 7        -> Usage: ...

# Pontosan két paramétert várunk.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <number1> <number2>" >&2
    exit 1
fi

a=$1
b=$2

# A feladat csak a paraméterek számának ellenőrzését kéri, de érdemes azt is
# megnézni, hogy valóban egész számokat kaptunk-e: különben a $(( )) hibát adna.
# A [+-]? rész az opcionális előjelet engedi meg.
if [[ ! $a =~ ^[+-]?[0-9]+$ || ! $b =~ ^[+-]?[0-9]+$ ]]; then
    echo "Error: both parameters must be integers" >&2
    exit 1
fi

# Számolás aritmetikai kifejezéssel: $(( ... )). A változók elé itt nem kell $ jel.
echo "Sum:        $(( a + b ))"
echo "Difference: $(( a - b ))"
echo "Product:    $(( a * b ))"
