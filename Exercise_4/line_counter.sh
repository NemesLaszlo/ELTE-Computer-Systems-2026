#!/bin/bash
# Megszámolja a fájl azon sorait, amelyek csak egy számot tartalmaznak,
# és a szám 1-esre végződik.
#
# Futtatás:
#   ./line_counter.sh numbers.txt

echo "The script counts the number of lines that contain only numbers and end with 1"

# Paraméterek számának ellenőrzése.
#
# >&2: az echo kimenetét a standard output helyett a standard errorra irányítja.
# A szabványos adatfolyamok számai: 0 = stdin (bemenet), 1 = stdout (normál kimenet),
# 2 = stderr (hibaüzenetek).
# Emiatt pl. a  ./line_counter.sh numbers.txt > result.txt  parancsnál a hibaüzenet
# nem kerül bele az eredményfájlba, hanem a terminálon jelenik meg.
if [ "$#" -lt 1 ]; then
    echo "Not enough parameters" >&2
    echo "Usage: $0 <file>" >&2
    exit 1
fi

# Létezik-e a fájl?
if [ ! -f "$1" ]; then
    echo "File not found: $1" >&2
    exit 1
fi

# A reguláris kifejezés részei:
#   ^               a sor eleje
#   [+-]?           opcionális előjel
#   ([0-9]+[.,])?   opcionális egészrész tizedesjellel (pl. "12." vagy "13,")
#   [0-9]*          tetszőleges számú számjegy
#   1               az utolsó számjegy 1-es
#   $               a sor vége
#
# A mintát aposztrófok közé írjuk, hogy a shell ne értelmezze a speciális
# karaktereket (pl. $, *, ?), hanem változtatás nélkül adja át a grep-nek.
#
# grep -E: bővített reguláris kifejezések, -c: a találatok (sorok) számát írja ki.
grep -cE '^[+-]?([0-9]+[.,])?[0-9]*1$' "$1"
