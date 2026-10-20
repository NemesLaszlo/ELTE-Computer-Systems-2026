#!/bin/bash
# 3. feladat: Eldönti a paraméterként kapott útvonalról, hogy fájl,
# könyvtár, vagy nem létezik.
#
# Futtatás:
#   ./3_path_type.sh 1_greeting.sh      -> '1_greeting.sh' is a file
#   ./3_path_type.sh ../tasks           -> '../tasks' is a directory
#   ./3_path_type.sh nincs_ilyen        -> 'nincs_ilyen' does not exist

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>" >&2
    exit 1
fi

path=$1

# Fájlokra vonatkozó vizsgálatok:
#   -f  létezik és sima fájl
#   -d  létezik és könyvtár
#   -e  létezik (bármi)
#
# A vizsgálatok sorrendje számít: a -e fájlra és könyvtárra is igaz lenne,
# ezért a konkrétabb feltételeket (-f, -d) nézzük meg először.
if [ -f "$path" ]; then
    echo "'$path' is a file"
elif [ -d "$path" ]; then
    echo "'$path' is a directory"
elif [ -e "$path" ]; then
    # Létezik, de nem sima fájl és nem is könyvtár (pl. eszközfájl: /dev/null).
    echo "'$path' exists, but it is neither a file nor a directory"
else
    echo "'$path' does not exist"
fi
