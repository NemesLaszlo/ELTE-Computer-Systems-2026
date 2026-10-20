#!/bin/bash
# 1. feladat: Egy szám (n) faktoriálisa:  n! = 1 * 2 * ... * n
#
# Futtatás:
#   ../solutions/1_factorial.sh 5      -> 5! = 120

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number>" >&2
    exit 1
fi

number=$1

# Csak nemnegatív egész számnak van faktoriálisa.
if [[ ! $number =~ ^[0-9]+$ ]]; then
    echo "Error: '$number' is not a non-negative integer" >&2
    exit 1
fi

# A bash 64 bites egészekkel számol: a 20! még belefér, a 21! már túlcsordulna.
if [ "$number" -gt 20 ]; then
    echo "Error: the number must be at most 20" >&2
    exit 1
fi

factorial=1

# A szorzat 1-ről indul, így a 0! és az 1! is 1 lesz (a ciklus le sem fut).
for (( i=2; i<=number; i++ )); do
    factorial=$(( factorial * i ))
done

echo "$number! = $factorial"
