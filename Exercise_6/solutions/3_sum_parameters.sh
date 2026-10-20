#!/bin/bash
# 3. feladat: A paraméterként kapott számok (legfeljebb 10) összeadása.
# A --help kapcsolóra rövid leírást ír ki.
#
# Futtatás:
#   ../solutions/3_sum_parameters.sh 4 -2 10     -> Sum: 12
#   ../solutions/3_sum_parameters.sh --help

# A súgót nézzük meg először: ez nem hiba, ezért exit 0.
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 <number1> [number2] ... [number10]"
    echo "Adds up at most 10 integers and prints the sum."
    exit 0
fi

if [ "$#" -eq 0 ] || [ "$#" -gt 10 ]; then
    echo "Error: give 1-10 numbers (or --help)" >&2
    exit 1
fi

sum=0

# "$@": az összes paraméter, egyenként
for number in "$@"; do
    if [[ ! $number =~ ^-?[0-9]+$ ]]; then
        echo "Error: '$number' is not an integer" >&2
        exit 1
    fi
    sum=$(( sum + number ))
done

echo "Sum: $sum"
