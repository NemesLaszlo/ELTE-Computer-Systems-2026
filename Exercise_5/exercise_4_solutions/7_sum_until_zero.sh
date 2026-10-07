#!/bin/bash
# 7. feladat: Addig kér be számokat a felhasználótól, amíg 0-t nem ad meg,
# majd kiírja a megadott számok összegét.
#
# Futtatás:
#   ./7_sum_until_zero.sh

sum=0
count=0

# Végtelen ciklus: a kilépésről a ciklus belsejében döntünk (break).
while true; do
    # Ha a read nem tud olvasni (pl. a felhasználó Ctrl+D-t nyom), kilépünk a
    # ciklusból, különben a script soha nem állna le.
    if ! read -r -p "Enter a number (0 to finish): " number; then
        echo
        break
    fi

    # Hibás bemenet (nem egész szám): hibaüzenet, és új szám bekérése.
    # A continue a ciklusmag hátralévő részét kihagyja, jön a következő kör.
    if [[ ! $number =~ ^[+-]?[0-9]+$ ]]; then
        echo "Error: '$number' is not an integer, try again" >&2
        continue
    fi

    # A 0 a befejezést jelenti: kilépünk a ciklusból.
    if (( number == 0 )); then
        break
    fi

    sum=$(( sum + number ))
    ((count++))
done

echo "You entered $count number(s), their sum is: $sum"
