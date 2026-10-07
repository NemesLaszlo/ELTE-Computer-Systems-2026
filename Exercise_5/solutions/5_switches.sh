#!/bin/bash
# 5. feladat: Kapcsolótól függően más-más parancsot futtat.
#   -d  a date parancs futtatása (aktuális dátum és idő)
#   -w  a bejelentkezett felhasználó neve
#   -l  a felhasználó saját könyvtárának listázása
#
# Futtatás:
#   ./5_switches.sh -d
#   ./5_switches.sh -x      -> hibaüzenet és használati útmutató

# A használati útmutatót függvénybe tesszük, mert több helyről is hívjuk.
# A függvény a standard outputra ír; híváskor döntjük el, hova irányítjuk.
usage() {
    echo "Usage: $0 -d | -w | -l"
    echo "  -d  print the current date and time"
    echo "  -w  print the name of the logged in user"
    echo "  -l  list the home directory of the user"
}

# Pontosan egy kapcsolót várunk.
# A  usage >&2  a függvény TELJES kimenetét a standard errorra irányítja.
if [ "$#" -ne 1 ]; then
    usage >&2
    exit 1
fi

# A case szerkezet egy értéket hasonlít össze mintákkal felülről lefelé, és az
# ELSŐ illeszkedő ág utasításait hajtja végre. Minden ágat ;; zár le.
# A * minta bármire illeszkedik, ez az "egyéb" (else) ág, ezért az utolsó.
case "$1" in
    -d)
        date
        ;;
    -w)
        whoami              # ugyanezt adja:  echo "$USER"
        ;;
    -l)
        ls -l "$HOME"       # a HOME környezeti változó a saját könyvtár útvonala
        ;;
    *)
        echo "Error: unknown option '$1'" >&2
        usage >&2
        exit 1
        ;;
esac
