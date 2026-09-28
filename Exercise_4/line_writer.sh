#!/bin/bash
# Két paramétert vár: az első megadja, hogy a második paramétert
# hányszor írja ki a terminálra.
#
# Futtatás:
#   ./line_writer.sh 3 "Hello ELTE"

# Pontosan két paramétert kaptunk-e?
#
# >&2: az echo kimenetét a standard output helyett a standard errorra irányítja
# (0 = stdin, 1 = stdout, 2 = stderr), mert ez hibaüzenet, nem a script eredménye.
# exit 1: a script nem nulla kilépési kóddal, vagyis hibajelzéssel áll le.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <number of times> <text>" >&2
    exit 1
fi

# A paraméterek beszédes nevű változókba mentése.
times=$1
text=$2

# Az első paraméter valóban (nemnegatív egész) szám-e?
# =~ : reguláris kifejezésre illesztés a [[ ]] szerkezetben.
if [[ ! $times =~ ^[0-9]+$ ]]; then
    echo "Error: '$times' is not a non-negative integer" >&2
    exit 1
fi

# A szöveg kiírása a megadott számú alkalommal.
for (( i=0; i<times; i++ )); do
    echo "$text"
done
