#!/bin/bash
# 2. feladat: Megszámolja, hány olyan sor van a fájlban, amely csak betűket
# (és szóközöket) tartalmaz: számjegy vagy írásjel nem lehet benne.
#
# Futtatás (a tasks mappából):
#   ../solutions/2_count_letter_lines.sh letters.txt      -> 2

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file_name=$1

if [ ! -f "$file_name" ]; then
    echo "Error: file '$file_name' does not exist" >&2
    exit 1
fi

count=0

# [[:alpha:]]   bármely betű (kis- és nagybetű; az ékezetes betűket a nyelvi
#               beállítástól (locale) függően ismeri fel)
# [[:space:]]   szóköz, tab
# A két karakterosztály egy közös [ ] zárójelben: [[:alpha:][:space:]]
# ^ … + … $     a teljes sornak ilyen karakterekből kell állnia, legalább egyből
while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    if [[ $line =~ ^[[:alpha:][:space:]]+$ ]]; then
        count=$(( count + 1 ))
    fi
done < "$file_name"

echo "There are $count lines in the file that contain only letters."

# Ugyanez ciklus nélkül: a grep -c az illeszkedő sorok számát adja vissza.
#   grep -c -E '^[[:alpha:][:space:]]+$' "$file_name"
