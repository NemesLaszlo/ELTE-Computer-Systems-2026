#!/bin/bash
# Parancssori argumentumok (paraméterek) használata.
#
# Futtatás:
#   ./2_script_with_arguments.sh Laszlo Nemes
#
# Speciális változók:
#   $0      a script neve (ahogyan elindítottuk)
#   $1..$9  az első ... kilencedik paraméter (10-től: ${10}, ${11}, ...)
#   $#      a paraméterek száma
#   $@      az összes paraméter, külön-külön szóként (idézőjelben használjuk: "$@")

echo "Script name: $0"
echo "My first name is $1"
echo "My surname is $2"
echo "Total number of arguments is $#"

# Ha szóközt tartalmazó értéket szeretnénk EGY paraméterként átadni,
# tegyük idézőjelbe:  ./2_script_with_arguments.sh "Laszlo Peter" Nemes
echo "All arguments: $*"
