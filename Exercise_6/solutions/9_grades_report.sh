#!/bin/bash
# 9. feladat: Jegyek kiszámítása a grades.txt pontszámaiból (első sor fejléc,
# utána  név;pont  soronként). Az eredmény a kimeneti fájlba kerül
# (név;pont;jegy), a végére a hallgatók száma, az átlag és a legjobb hallgató.
#
# Ponthatárok:  0-49: 1,  50-59: 2,  60-69: 3,  70-84: 4,  85-100: 5
#
# Futtatás (a tasks mappából):
#   ../solutions/9_grades_report.sh grades.txt report.txt
#   cat report.txt

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>" >&2
    exit 1
fi

input_file=$1
output_file=$2

if [ ! -f "$input_file" ]; then
    echo "Error: file '$input_file' does not exist" >&2
    exit 1
fi

if [ "$input_file" -ef "$output_file" ]; then
    echo "Error: the input and the output file must be different" >&2
    exit 1
fi

line_number=0
count=0
sum=0
best_name=""
best_points=-1

echo "name;points;grade" > "$output_file"

# IFS=';' : a read a pontosvesszőnél vágja a sort, az első mező a name,
# a második a points változóba kerül.
while IFS=';' read -r name points || [ -n "$name" ]; do
    line_number=$(( line_number + 1 ))

    # Az első sor a fejléc.
    if [ "$line_number" -eq 1 ]; then
        continue
    fi

    # A pontszámból töröljük a szóközöket és a Windows-os \r-t.
    points=$(echo "$points" | tr -d '[:space:]')

    # Üres sor: kihagyjuk.
    if [ -z "$points" ]; then
        continue
    fi

    # Hibás pontszám (nem szám, vagy 100-nál több): figyelmeztetés, kihagyjuk.
    if [[ ! $points =~ ^[0-9]+$ ]] || [ "$points" -gt 100 ]; then
        echo "Warning: line $line_number has invalid points, skipped: '$name;$points'" >&2
        continue
    fi

    if [ "$points" -ge 85 ]; then
        grade=5
    elif [ "$points" -ge 70 ]; then
        grade=4
    elif [ "$points" -ge 60 ]; then
        grade=3
    elif [ "$points" -ge 50 ]; then
        grade=2
    else
        grade=1
    fi

    echo "$name;$points;$grade" >> "$output_file"

    count=$(( count + 1 ))
    sum=$(( sum + points ))
    if [ "$points" -gt "$best_points" ]; then
        best_points=$points
        best_name=$name
    fi
done < "$input_file"

# Üres fájlnál nem oszthatunk nullával.
if [ "$count" -eq 0 ]; then
    echo "Error: no students found" >&2
    exit 1
fi

echo "---" >> "$output_file"
echo "Students: $count" >> "$output_file"
echo "Average: $(( sum / count ))" >> "$output_file"
echo "Best: $best_name ($best_points)" >> "$output_file"

echo "Report written to '$output_file'."
