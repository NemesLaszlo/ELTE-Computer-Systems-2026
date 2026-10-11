#!/bin/bash
# 5. feladat (ciklusos megoldás): Kapcsolótól függően más-más műveletet végez.
#   -d  az aktuális dátum és idő
#   -w  a bejelentkezett felhasználó neve
#   -l  a felhasználó saját könyvtárának listázása
# A case helyett if / elif láncot, az ls helyett egy for ciklust használunk.
#
# Futtatás:
#   ../solutions_with_loops/5_switches.sh -l
#   ../solutions_with_loops/5_switches.sh -x      -> hibaüzenet és használati útmutató

usage() {
    echo "Usage: $0 -d | -w | -l"
    echo "  -d  print the current date and time"
    echo "  -w  print the name of the logged in user"
    echo "  -l  list the home directory of the user"
}

# A saját könyvtár tartalma ciklussal, az  ls -l "$HOME"  helyett.
list_home() {
    local entry
    local name

    for entry in "$HOME"/*; do
        # Üres könyvtárban a minta szó szerint marad: ilyenkor nincs mit kiírni.
        if [ ! -e "$entry" ]; then
            continue
        fi

        # ${entry##*/}: az útvonal utolsó tagja (a basename megfelelője),
        # a ## a legutolsó /-ig mindent levág az elejéről.
        name=${entry##*/}

        if [ -d "$entry" ]; then
            echo "[dir]  $name"
        else
            echo "[file] $name"
        fi
    done
}

if [ "$#" -ne 1 ]; then
    usage >&2
    exit 1
fi

# Ugyanaz, mint a case: felülről lefelé vizsgáljuk a lehetőségeket, és az
# első igaz ág fut le. Az else ág a case *) ágának felel meg.
if [ "$1" == "-d" ]; then
    date
elif [ "$1" == "-w" ]; then
    # A USER környezeti változó (a whoami helyett). Windows-on (Git Bash) a
    # USER nincs beállítva, ott a USERNAME tartalmazza a nevet:
    # ${USER:-$USERNAME} = a USER értéke, ha üres, akkor a USERNAME-é.
    echo "${USER:-$USERNAME}"
elif [ "$1" == "-l" ]; then
    list_home
else
    echo "Error: unknown option '$1'" >&2
    usage >&2
    exit 1
fi
