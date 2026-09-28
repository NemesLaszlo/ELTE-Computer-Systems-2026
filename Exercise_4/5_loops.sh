#!/bin/bash
# Ciklusok: while, until, for.
#
# Futtatás:
#   ./5_loops.sh

# --- While -------------------------------------------------------------------
# Addig ismétel, amíg a feltétel igaz.
echo "While:"
count=1
while [ "$count" -le 5 ]; do
    echo "$count"
    ((count++))         # aritmetikai kifejezés: a számláló növelése 1-gyel
done

# --- While + break -----------------------------------------------------------
# A "true" parancs mindig sikeres, így ez egy végtelen ciklus,
# amelyből a break utasítással lépünk ki.
#
# Gyakori hiba:  valid=true; while [ $valid ]
# A [ $valid ] csak azt vizsgálja, hogy a string NEM ÜRES-e, ezért
# valid=false esetén is igaz lenne a feltétel!
echo "While with break:"
count=1
while true; do
    echo "$count"
    if [ "$count" -eq 5 ]; then
        break           # kilépés a ciklusból
    fi
    ((count++))
done

# --- Until -------------------------------------------------------------------
# A while ellentéte: addig ismétel, amíg a feltétel HAMIS.
echo "Until:"
count=1
until [ "$count" -gt 3 ]; do
    echo "$count"
    ((count++))
done

# --- For (C stílusú) ---------------------------------------------------------
# for (( kezdőérték; feltétel; léptetés ))
echo "For (C style):"
for (( counter=10; counter>0; counter-- )); do
    echo -n "$counter "     # -n: nem tesz sortörést a kiírás végére
done
printf "\n"

# --- For (lista bejárása) ----------------------------------------------------
echo "For (list):"
for fruit in alma korte banan; do
    echo "Fruit: $fruit"
done

# --- For (számtartomány) -----------------------------------------------------
# {1..5} kifejtve: 1 2 3 4 5
echo "For (range):"
for i in {1..5}; do
    if (( i == 3 )); then
        continue        # a ciklusmag hátralévő részét kihagyja, jön a következő kör
    fi
    echo -n "$i "
done
printf "\n"

# --- For (fájlok bejárása) ---------------------------------------------------
# A *.sh az aktuális könyvtár összes .sh végű fájljára illeszkedik.
echo "For (files):"
for file in *.sh; do
    echo "Script: $file"
done
