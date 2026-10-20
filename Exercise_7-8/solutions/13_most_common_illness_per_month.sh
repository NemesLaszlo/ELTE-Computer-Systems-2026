#!/usr/bin/env bash
# 13. feladat: Havonta a leggyakoribb betegség, kulcs-érték tárolóval
# (asszociatív tömb). A patients_messy.txt egy sora:  Név, ÉÉÉÉ-HH-NN, betegség
# A fájl "piszkos": fejléc, szóközök a vesszők körül, írásjelek a betegség
# végén (fejfájás. / fejfájás!), kis- és nagybetű keverve, üres és hibás
# sorok, Windows-os CRLF sorvégek, és az utolsó sor után nincs újsor.
#
# Futtatás (a tasks mappából):
#   ../solutions/13_most_common_illness_per_month.sh patients_messy.txt

# Az asszociatív tömb (declare -A) csak bash 4.0-tól létezik. A macOS
# beépített /bin/bash-e 3.2-es, ott: brew install bash
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Error: bash 4+ required (this is $BASH_VERSION)." >&2
    echo "On macOS: brew install bash" >&2
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# declare -A : asszociatív tömb (kulcs-érték tároló). A sima tömb indexe csak
# szám lehet, itt a kulcs tetszőleges szöveg: counts["10:fejfájás"]=3
# A kulcs a hónap és a betegség összefűzve, kettősponttal elválasztva.
declare -A counts

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    # A sor vesszőknél mezőkre bontása (lásd 5. hét: read … <<< "$line").
    IFS=',' read -r name date illness <<< "$line"

    # Tisztítás (a betegség neve egy szó, ezért a szóközök törlése nem árt neki):
    #   tr -d '[:space:]'            a szóközök, tabok törlése (" 2023-10-13" -> "2023-10-13")
    #   tr -d '[:punct:]'            az írásjelek (. , !) törlése ("fejfájás." -> "fejfájás")
    #   tr '[:upper:]' '[:lower:]'   kisbetűsítés, hogy a Fejfájás és a fejfájás egy legyen
    date=$(echo "$date" | tr -d '[:space:]')
    illness=$(echo "$illness" | tr -d '[:space:][:punct:]' | tr '[:upper:]' '[:lower:]')

    # Hibás sor (a fejléc is ilyen): a dátum nem ÉÉÉÉ-HH-NN alakú, vagy nincs betegség.
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || [ -z "$illness" ]; then
        echo "Warning: invalid line skipped: '$line'" >&2
        continue
    fi

    month=${date:5:2}               # a hónap a dátum 5. karakterétől 2 karakter

    # Számlálás: a kulcshoz tartozó értéket eggyel növeljük. Ha a kulcs még
    # nem létezik, a ${…:-0} miatt 0-ról indul.
    key="$month:$illness"
    counts["$key"]=$(( ${counts["$key"]:-0} + 1 ))
done < "$file"

if [ "${#counts[@]}" -eq 0 ]; then
    echo "No valid records found in '$file'."
    exit 0
fi

# Maximumkeresés hónaponként, két további asszociatív tömbbel:
#   max_count[hónap]    a hónap eddigi legnagyobb darabszáma
#   max_illness[hónap]  a hozzá tartozó betegség
# "${!counts[@]}" : az összes kulcs (a ! miatt a kulcsok, nem az értékek).
declare -A max_count
declare -A max_illness

for key in "${!counts[@]}"; do
    month=${key%%:*}                # a kettőspont ELŐTTI rész (a leghosszabb ":*" végződés levágva)
    illness=${key#*:}               # a kettőspont UTÁNI rész (a legrövidebb "*:" kezdet levágva)
    count=${counts["$key"]}

    if [ "$count" -gt "${max_count["$month"]:-0}" ]; then
        max_count["$month"]=$count
        max_illness["$month"]=$illness
    fi
done

# Az asszociatív tömb kulcsai nincsenek sorban, ezért a hónapokat rendezve
# járjuk be: a printf soronként kiírja őket, a sort rendez.
for month in $(printf '%s\n' "${!max_count[@]}" | sort); do
    echo "Month $month: ${max_illness["$month"]} (${max_count["$month"]} patient(s))"
done

# Megjegyzés: ugyanez asszociatív tömb nélkül, a 5. heti "párhuzamos tömbös"
# megoldással (illnesses[i], counts[i]) is megírható, csak hosszabb.
