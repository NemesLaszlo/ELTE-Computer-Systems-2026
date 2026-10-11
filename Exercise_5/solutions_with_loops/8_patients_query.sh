#!/bin/bash
# 8. feladat (ciklusos megoldás): Lekérdezések a betegnyilvántartásból
# (patients.txt), kapcsolókkal. A grep / cut / sort / uniq parancsok helyett a
# fájlt egyszer beolvassuk három tömbbe, és a lekérdezések ciklusokkal dolgoznak.
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
#   ../solutions_with_loops/8_patients_query.sh patients.txt -i fejfájás
#   ../solutions_with_loops/8_patients_query.sh patients.txt -m 10
#   ../solutions_with_loops/8_patients_query.sh patients.txt -l
#   ../solutions_with_loops/8_patients_query.sh patients.txt -c

# --- Függvények ---------------------------------------------------------------

usage() {
    echo "Usage: $0 <file> -i <illness> | -m <month> | -l | -c"
    echo "       $0 -h"
    echo "  -i <illness>  names of the patients with the given illness"
    echo "  -m <month>    number of patients in the given month (01-12)"
    echo "  -l            list of the illnesses (sorted, each once)"
    echo "  -c            number of patients per illness (most common first)"
    echo "  -h            print this help"
}

# A fájl beolvasása három párhuzamos tömbbe: az i. beteg neve names[i],
# a dátuma dates[i], a betegsége patient_illnesses[i]. A tömbök globálisak,
# így a többi függvény is látja őket.
load_patients() {
    local name date illness

    names=()
    dates=()
    patient_illnesses=()

    # IFS=, : vesszőknél bontjuk a sort (a cut -d ',' megfelelője).
    # || [ -n "$name" ]: a záró újsor nélküli utolsó sort is beolvassuk.
    while IFS=, read -r name date illness || [ -n "$name" ]; do
        illness=${illness%$'\r'}        # Windows-os (CRLF) sorvég levágása

        if [ -z "$illness" ]; then      # üres / hiányos sor kihagyása
            continue
        fi

        names+=("$name")
        dates+=("$date")
        patient_illnesses+=("$illness")
    done < "$file"
}

# Az adott betegséggel kezelt betegek neve (a grep -i ",$illness$" | cut -f 1 helyett).
list_patients_by_illness() {
    local illness=$1
    local found=0
    local i

    # A [[ == ]] ezután nem különbözteti meg a kis- és nagybetűket (grep -i).
    # (A ${1,,} kisbetűsítés bash 4-es, a macOS bash 3.2-je nem ismeri.)
    shopt -s nocasematch

    for (( i=0; i<${#names[@]}; i++ )); do
        # A teljes mezőt hasonlítjuk, így pl. a "fáj" nem illeszkedik a "fejfájás"-ra.
        if [[ ${patient_illnesses[i]} == "$illness" ]]; then
            echo "${names[i]}"
            found=1
        fi
    done

    shopt -u nocasematch

    if [ "$found" -eq 0 ]; then
        echo "No patients with illness '$1'."
    fi
}

# Hány beteg volt az adott hónapban (a grep -c helyett számláló változóval).
count_patients_in_month() {
    local month=$1
    local count=0
    local i

    if [[ ! $month =~ ^(0[1-9]|1[0-2])$ ]]; then
        echo "Error: month must be given as two digits (01-12)" >&2
        exit 1
    fi

    for (( i=0; i<${#dates[@]}; i++ )); do
        # ${dates[i]:5:2}: a dátum (ÉÉÉÉ-HH-NN) 5. karakterétől 2 karakter = a hónap
        if [ "${dates[i]:5:2}" == "$month" ]; then
            ((count++))
        fi
    done

    echo "Number of patients in month $month: $count"
}

# A különböző betegségek összegyűjtése az unique_illnesses tömbbe, és mellé a
# darabszámuk az illness_counts tömbbe (a sort | uniq -c megfelelője, rendezés nélkül).
count_illnesses() {
    local i j index

    unique_illnesses=()
    illness_counts=()

    for (( i=0; i<${#patient_illnesses[@]}; i++ )); do
        # Lineáris keresés: benne van-e már a listában?
        index=-1
        for (( j=0; j<${#unique_illnesses[@]}; j++ )); do
            if [ "${unique_illnesses[j]}" == "${patient_illnesses[i]}" ]; then
                index=$j
                break
            fi
        done

        if [ "$index" -eq -1 ]; then
            unique_illnesses+=("${patient_illnesses[i]}")
            illness_counts+=(1)
        else
            (( illness_counts[index]++ ))
        fi
    done
}

# Két tömbelem cseréje mindkét tömbben (hogy a párok együtt maradjanak).
swap() {
    local a=$1
    local b=$2
    local tmp

    tmp=${unique_illnesses[a]}
    unique_illnesses[a]=${unique_illnesses[b]}
    unique_illnesses[b]=$tmp

    tmp=${illness_counts[a]}
    illness_counts[a]=${illness_counts[b]}
    illness_counts[b]=$tmp
}

# Az előforduló betegségek ábécérendben, mindegyik egyszer (a sort -u helyett).
list_illnesses() {
    local i j n

    count_illnesses
    n=${#unique_illnesses[@]}

    # Buborékrendezés: minden körben a szomszédos elemeket hasonlítjuk, és ha
    # rossz sorrendben vannak, megcseréljük őket. A [[ a > b ]] szövegeket
    # hasonlít (ábécérend), a [ ] -gt pedig számokat.
    for (( i=0; i<n-1; i++ )); do
        for (( j=0; j<n-1-i; j++ )); do
            if [[ ${unique_illnesses[j]} > ${unique_illnesses[j+1]} ]]; then
                swap "$j" "$((j+1))"
            fi
        done
    done

    for (( i=0; i<n; i++ )); do
        echo "${unique_illnesses[i]}"
    done
}

# Betegségenként a betegek száma, a leggyakoribbal kezdve
# (a sort | uniq -c | sort -rn helyett).
list_illness_counts() {
    local i j n

    count_illnesses
    n=${#unique_illnesses[@]}

    # Buborékrendezés a darabszám szerint, csökkenő sorrendben (-lt).
    for (( i=0; i<n-1; i++ )); do
        for (( j=0; j<n-1-i; j++ )); do
            if [ "${illness_counts[j]}" -lt "${illness_counts[j+1]}" ]; then
                swap "$j" "$((j+1))"
            fi
        done
    done

    # printf '%7d': a számot 7 karakter szélesen, jobbra igazítva írja ki,
    # pont úgy, ahogy a uniq -c.
    for (( i=0; i<n; i++ )); do
        printf '%7d %s\n' "${illness_counts[i]}" "${unique_illnesses[i]}"
    done
}

# --- Paraméterek ellenőrzése --------------------------------------------------
if [ "$1" == "-h" ]; then
    usage
    exit 0
fi

if [ "$#" -lt 2 ]; then
    usage >&2
    exit 1
fi

file=$1
option=$2
value=$3

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

load_patients

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
