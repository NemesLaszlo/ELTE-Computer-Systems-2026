#!/bin/bash
# 6. heti további gyakorlás, 4. feladat: Két fájl összefésülése. A names.txt
# és az emails.txt i. sora összetartozik. A contacts.txt-be  név;email
# formában írjuk őket; ha az egyik fájl rövidebb, a hiányzó mező üres marad.
#
# Futtatás (az exercise_6_solutions mappából):
#   ./4_merge_files.sh names.txt emails.txt contacts.txt
#   cat contacts.txt
#
# Elvárt eredmény: 5 sor, az utolsó  "Szabó Emese;"  (nincs hozzá email).
# Az emails.txt utolsó sora után nincs újsor.

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <names_file> <emails_file> <output_file>" >&2
    exit 1
fi

names_file=$1
emails_file=$2
output_file=$3

for f in "$names_file" "$emails_file"; do
    if [ ! -f "$f" ]; then
        echo "Error: file '$f' does not exist" >&2
        exit 1
    fi
done

# --- 1. lépés: mindkét fájl beolvasása egy-egy tömbbe -------------------------
# Két fájlt nem tudunk egyszerre soronként olvasni egy while ciklussal, ezért
# előbb tömbbe gyűjtjük a sorokat, és utána indexszel járjuk be őket.
names=()
emails=()

while IFS= read -r line || [ -n "$line" ]; do
    names+=("${line%$'\r'}")
done < "$names_file"

while IFS= read -r line || [ -n "$line" ]; do
    emails+=("${line%$'\r'}")
done < "$emails_file"

# --- 2. lépés: a hosszabb tömb hosszáig megyünk -------------------------------
count=${#names[@]}
if [ "${#emails[@]}" -gt "$count" ]; then
    count=${#emails[@]}
fi

> "$output_file"

# Ha az index túlmutat a rövidebb tömbön, a ${tomb[i]} üres szöveget ad,
# így a hiányzó mező magától üres marad.
for (( i=0; i<count; i++ )); do
    echo "${names[i]};${emails[i]}" >> "$output_file"
done

echo "$count contact(s) written to '$output_file'."

# Ugyanez egy paranccsal (a paste a két fájl sorait egymás mellé teszi):
#   paste -d ';' "$names_file" "$emails_file" > "$output_file"
