#!/bin/bash
# 8. feladat: Lekérdezések a betegnyilvántartásból (patients.txt), kapcsolókkal.
#
# A fájl egy sora:  Név,ÉÉÉÉ-HH-NN,betegség
#
#   -i <betegség>   az adott betegséggel kezelt betegek neve
#   -m <hónap>      hány beteg volt az adott hónapban (01-12)
#   -l              az előforduló betegségek listája (ábécérendben, mindegyik egyszer)
#   -c              betegségenként a betegek száma, csökkenő sorrendben
#   -h              használati útmutató
#
# Futtatás (a tasks mappából):
#   ../solutions/8_patients_query.sh patients.txt -i fejfájás
#   ../solutions/8_patients_query.sh patients.txt -m 10
#   ../solutions/8_patients_query.sh patients.txt -l
#   ../solutions/8_patients_query.sh patients.txt -c

# --- Függvények ---------------------------------------------------------------
# Minden kapcsolóhoz egy-egy rövid függvény tartozik. A file változó globális
# (a scriptben, a függvényeken kívül kap értéket), ezért a függvények is látják.

usage() {
    echo "Usage: $0 <file> -i <illness> | -m <month> | -l | -c"
    echo "       $0 -h"
    echo "  -i <illness>  names of the patients with the given illness"
    echo "  -m <month>    number of patients in the given month (01-12)"
    echo "  -l            list of the illnesses (sorted, each once)"
    echo "  -c            number of patients per illness (most common first)"
    echo "  -h            print this help"
}

# Az adott betegséggel kezelt betegek neve.
list_patients_by_illness() {
    local illness=$1
    local names

    # A betegség a 3. mező, a sor végén áll: a ",betegség$" mintával keressük,
    # így pl. a "fejfájás" nem illeszkedik egy "Nagy Fejfájásné" nevű betegre.
    # -i: a kis- és nagybetűk nem számítanak. Az 1. mező (-f 1) a név.
    names=$(grep -i ",$illness$" "$file" | cut -d ',' -f 1)

    if [ -z "$names" ]; then
        echo "No patients with illness '$illness'."
    else
        echo "$names"
    fi
}

# Hány beteg volt az adott hónapban.
count_patients_in_month() {
    local month=$1
    local count

    if [[ ! $month =~ ^(0[1-9]|1[0-2])$ ]]; then
        echo "Error: month must be given as two digits (01-12)" >&2
        exit 1
    fi

    # grep -c: a találatok helyett az illeszkedő sorok számát adja vissza.
    count=$(grep -cE ",[0-9]{4}-$month-[0-9]{2}," "$file")
    echo "Number of patients in month $month: $count"
}

# Az előforduló betegségek ábécérendben, mindegyik csak egyszer.
list_illnesses() {
    # sort -u (unique): rendez, és az ismétlődő sorokból csak egyet tart meg.
    cut -d ',' -f 3 "$file" | sort -u
}

# Betegségenként a betegek száma, a leggyakoribbal kezdve.
list_illness_counts() {
    cut -d ',' -f 3 "$file" | sort | uniq -c | sort -rn
}

# --- Paraméterek ellenőrzése --------------------------------------------------
# A -h kapcsolót önmagában is elfogadjuk (fájl nélkül), ezért ezt nézzük először.
if [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Különben legalább két paraméter kell: a fájl és egy kapcsoló.
if [ "$#" -lt 2 ]; then
    usage >&2
    exit 1
fi

file=$1
option=$2
value=$3        # csak a -i és a -m kapcsolónál van rá szükség

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# --- A kapcsoló feldolgozása --------------------------------------------------
case "$option" in
    -i)
        if [ -z "$value" ]; then
            echo "Error: -i requires an illness name" >&2
            exit 1
        fi
        list_patients_by_illness "$value"
        ;;
    -m)
        if [ -z "$value" ]; then
            echo "Error: -m requires a month" >&2
            exit 1
        fi
        count_patients_in_month "$value"
        ;;
    -l)
        list_illnesses
        ;;
    -c)
        list_illness_counts
        ;;
    -h)
        usage
        ;;
    *)
        echo "Error: unknown option '$option'" >&2
        usage >&2
        exit 1
        ;;
esac
