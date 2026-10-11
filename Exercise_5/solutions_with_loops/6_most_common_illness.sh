#!/bin/bash
# 6. feladat (ciklusos megoldás): Egy adott hónap leggyakoribb betegségének
# meghatározása a patients.txt fájlból. A grep | cut | sort | uniq -c | sort -rn
# csővezeték helyett soronként olvasunk, és két tömbben számolunk.
#
# A fájl egy sora:  Név,ÉÉÉÉ-HH-NN,betegség
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/6_most_common_illness.sh patients.txt 10

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file> <month (01-12)>" >&2
    exit 1
fi

file=$1
month=$2

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

if [[ ! $month =~ ^(0[1-9]|1[0-2])$ ]]; then
    echo "Error: month must be given as two digits (01-12)" >&2
    exit 1
fi

# --- Számlálás két "párhuzamos" tömbbel ----------------------------------------
# illnesses[i]  az i. betegség neve
# counts[i]     hányszor fordult elő az i. betegség
# Az azonos indexű elemek összetartoznak (ezért "párhuzamos" tömbök).
# (Bash 4-től asszociatív tömbbel is megoldható: declare -A counts;
#  ((counts[$illness]++)) - itt szándékosan a más nyelvekben is ismert,
#  egyszerű tömbös megoldást használjuk.)
illnesses=()
counts=()

# IFS=, : a read a sort a vesszőknél bontja mezőkre, a három mező a három
# változóba kerül (ez a cut -d ',' megfelelője).
while IFS=, read -r name date illness || [ -n "$name" ]; do
    # Windows-os (CRLF) sorvég: a \r az utolsó mező, az illness végére kerül.
    illness=${illness%$'\r'}

    # Az üres (vagy hiányos) sorokat kihagyjuk, pl. a fájl végén lévő üres sort.
    if [ -z "$illness" ]; then
        continue
    fi

    # A dátum ÉÉÉÉ-HH-NN alakú: a hónap az 5. karaktertől kezdődő 2 karakter.
    # ${változó:kezdet:hossz} - a karakterek számozása 0-tól indul.
    if [ "${date:5:2}" != "$month" ]; then
        continue                # ez nem a keresett hónap (a grep szűrés helyett)
    fi

    # Lineáris keresés: szerepel-e már a betegség a tömbben?
    index=-1
    for (( i=0; i<${#illnesses[@]}; i++ )); do
        if [ "${illnesses[i]}" == "$illness" ]; then
            index=$i
            break
        fi
    done

    if [ "$index" -eq -1 ]; then
        # Új betegség: a tömbök végére tesszük, 1-es számlálóval.
        illnesses+=("$illness")
        counts+=(1)
    else
        # Már láttuk: növeljük a számlálóját.
        (( counts[index]++ ))
    fi
done < "$file"

# Ha a hónapban egyetlen beteg sem volt, a tömb üres (0 elemű).
if [ "${#illnesses[@]}" -eq 0 ]; then
    echo "No patients in month $month."
    exit 0
fi

# --- Maximumkeresés (a sort -rn | head -n 1 helyett) -------------------------
max_index=0
for (( i=1; i<${#counts[@]}; i++ )); do
    if [ "${counts[i]}" -gt "${counts[max_index]}" ]; then
        max_index=$i
    fi
done

echo "Most common illness in month $month: ${illnesses[max_index]} (${counts[max_index]} patient(s))"
