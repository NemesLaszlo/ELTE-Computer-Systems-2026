#!/bin/bash
# 6. feladat: Egy adott hónap leggyakoribb betegségének meghatározása a
# patients.txt fájlból.
#
# A fájl egy sora:  Név,ÉÉÉÉ-HH-NN,betegség
#
# Futtatás (a tasks mappából):
#   ../solutions/6_most_common_illness.sh patients.txt 10

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

# A hónap két számjegy legyen 01 és 12 között:
#   0[1-9]   0 után 1-9      (01 ... 09)
#   1[0-2]   1 után 0-2      (10, 11, 12)
# A | a két lehetőség közti választás, a ( ) a csoport, amire a ^ és $ vonatkozik.
if [[ ! $month =~ ^(0[1-9]|1[0-2])$ ]]; then
    echo "Error: month must be given as two digits (01-12)" >&2
    exit 1
fi

# A feladatot egy csővezetékkel (|) oldjuk meg, lépésről lépésre:
#
#   grep -E ",[0-9]{4}-$month-[0-9]{2},"   csak a megadott hónap sorai maradnak
#       A mintát DUPLA idézőjelbe tesszük, hogy a $month behelyettesítődjön.
#   cut -d ',' -f 3                        a sorokat vesszőnél (-d) vágjuk, és
#                                          csak a 3. mezőt (-f), a betegséget tartjuk meg
#   sort                                   rendezés, így az azonos betegségek egymás mellé kerülnek
#   uniq -c                                az egymás UTÁN ismétlődő sorokat összevonja,
#                                          eléjük írva a darabszámot
#   sort -rn                               szám szerint (-n), csökkenő sorrendben (-r)
#   head -n 1                              csak az első sor, vagyis a leggyakoribb
#
# Az eredmény egyetlen sor, pl.:  "      3 fejfájás"
result=$(grep -E ",[0-9]{4}-$month-[0-9]{2}," "$file" | cut -d ',' -f 3 | sort | uniq -c | sort -rn | head -n 1)

# Ha a hónapban egyetlen beteg sem volt, a result üres (-z).
if [ -z "$result" ]; then
    echo "No patients in month $month."
    exit 0
fi

# A "      3 fejfájás" sor szétszedése két változóra: a read az első szót a
# count, a sor maradékát az illness változóba teszi (a szóközöket átugorja).
# A <<< a read bemenetére nem fájlt vagy billentyűzetet, hanem egy változó
# tartalmát adja.
read -r count illness <<< "$result"

echo "Most common illness in month $month: $illness ($count patient(s))"
