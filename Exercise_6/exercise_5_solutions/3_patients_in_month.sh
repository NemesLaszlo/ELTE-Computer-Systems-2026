#!/bin/bash
# 5. heti további gyakorlás, 3. feladat: A patients.txt fájlból az adott
# hónapban kezelt betegek nevének kiírása ábécérendben. A hónapot paraméterként
# kapja; ha nincs paraméter, read-del kéri be.
#
# A fájl egy sora:  Név,ÉÉÉÉ-HH-NN,betegség
#
# Futtatás (az exercise_5_solutions mappából):
#   ./3_patients_in_month.sh 05
#   ./3_patients_in_month.sh            -> Month (01-12): 05

file="patients.txt"

if [ ! -f "$file" ]; then
    echo "Error: '$file' not found, run the script from its directory" >&2
    exit 1
fi

# Ha van paraméter, az a hónap; ha nincs, bekérjük.
if [ "$#" -eq 1 ]; then
    month=$1
else
    read -r -p "Month (01-12): " month
fi

# Két számjegy, 01-12 (lásd az 5. heti 6. feladatot).
if [[ ! $month =~ ^(0[1-9]|1[0-2])$ ]]; then
    echo "Error: month must be two digits (01-12)" >&2
    exit 1
fi

# A hónap sorai -> a név (1. mező) -> ábécérend
names=$(grep -E ",[0-9]{4}-$month-[0-9]{2}," "$file" | cut -d ',' -f 1 | sort)

if [ -z "$names" ]; then
    echo "No patients in month $month."
else
    echo "Patients in month $month:"
    echo "$names"
fi
