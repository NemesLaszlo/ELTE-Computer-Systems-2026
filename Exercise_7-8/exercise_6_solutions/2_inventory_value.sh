#!/bin/bash
# 6. heti további gyakorlás, 2. feladat: Raktárkészlet értéke. Az inventory.txt
# első sora fejléc, utána  termék;darab;egységár  sorok jönnek (Windows-os
# CRLF sorvégekkel, üres sorokkal, szóközökkel és hibás sorokkal).
#
#   inventory_report.txt   soronként  termék;érték  (érték = darab * egységár),
#                          a végén a teljes érték
#   errors.txt             a hibás sorok a sorszámukkal
#
# Futtatás (az exercise_6_solutions mappából):
#   ./2_inventory_value.sh inventory.txt
#   cat inventory_report.txt errors.txt
#
# Elvárt eredmény: teljes érték 18840, 2 hibás sor (szilva, narancs).

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <inventory_file>" >&2
    exit 1
fi

input_file=$1
report_file="inventory_report.txt"
error_file="errors.txt"

if [ ! -f "$input_file" ]; then
    echo "Error: file '$input_file' does not exist" >&2
    exit 1
fi

line_number=0
items=0
errors=0
total=0

# Mindkét kimeneti fájlt kiürítjük, hogy a többszöri futtatás ugyanazt adja.
> "$report_file"
> "$error_file"

# IFS=';' : a read a pontosvesszőnél vágja a sort három mezőre. A Windows-os
# \r az UTOLSÓ mezőbe (price) kerül, az üres sorból pedig csak a product kap
# értéket (egy \r-t).
while IFS=';' read -r product quantity price || [ -n "$product" ]; do
    line_number=$(( line_number + 1 ))

    # Az első sor a fejléc.
    if [ "$line_number" -eq 1 ]; then
        continue
    fi

    # Szóközök és \r törlése: a termék nevéből csak a sor végi \r-t vágjuk le
    # (a név tartalmazhat szóközt), a számokból minden szóköz jellegű karaktert.
    product=${product%$'\r'}
    quantity=$(echo "$quantity" | tr -d '[:space:]')
    price=$(echo "$price" | tr -d '[:space:]')

    # Üres sor: minden mező üres, kihagyjuk.
    if [ -z "$product" ] && [ -z "$quantity" ] && [ -z "$price" ]; then
        continue
    fi

    # Hibás sor: a darab vagy az egységár nem egész szám (üres is lehet).
    if [[ ! $quantity =~ ^[0-9]+$ ]] || [[ ! $price =~ ^[0-9]+$ ]]; then
        echo "line $line_number: $product;$quantity;$price" >> "$error_file"
        errors=$(( errors + 1 ))
        continue
    fi

    value=$(( quantity * price ))
    echo "$product;$value" >> "$report_file"

    items=$(( items + 1 ))
    total=$(( total + value ))
done < "$input_file"

echo "Total: $total" >> "$report_file"

echo "$items product(s) written to '$report_file', total value: $total"
echo "$errors invalid line(s) written to '$error_file'"
