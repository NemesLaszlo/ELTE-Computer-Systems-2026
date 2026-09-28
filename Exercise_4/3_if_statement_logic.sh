#!/bin/bash
# Logikai műveletek feltételekben + adat bekérése a felhasználótól.
#
# Futtatás:
#   ./3_if_statement_logic.sh

# read: egy sort olvas be a billentyűzetről (standard input) a megadott változóba.
#   -r  a \ karaktert nem kezeli speciálisan (szinte mindig érdemes megadni)
#   -p  beolvasás előtt kiírja a megadott szöveget (prompt)
#   -s  a begépelt szöveg nem jelenik meg a terminálon (jelszavakhoz)
read -r -p "Enter username: " username
read -r -s -p "Enter password: " password
echo    # a -s miatt az Enter nem jelenik meg, ezért kézzel törünk sort

# Szövegek összehasonlítása a [[ ]] szerkezetben:
#   ==  egyezik        !=  nem egyezik
#   -z  üres string    -n  nem üres string
#
# Logikai műveletek:
#   &&  ÉS   (mindkét feltételnek teljesülnie kell)
#   ||  VAGY (elég, ha az egyik teljesül)
#   !   tagadás
if [[ $username == "admin" && $password == "secret" ]]; then
    echo "valid user"
else
    echo "invalid user"
fi

# Megjegyzés: ez csak szemléltető példa! Valódi scriptbe soha ne írjunk bele jelszót.
