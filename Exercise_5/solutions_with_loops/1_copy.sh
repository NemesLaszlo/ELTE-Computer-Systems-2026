#!/bin/bash
# 1. feladat (ciklusos megoldás): Fájl tartalmának átmásolása egy másik fájlba,
# a cp parancs helyett soronként, egy while ciklussal.
#
# Futtatás (a tasks mappából):
#   ../solutions_with_loops/1_copy.sh source.txt target.txt

# --- Paraméterek ellenőrzése -------------------------------------------------
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_file> <destination_file>" >&2
    exit 1
fi

source_file=$1
destination_file=$2

if [ ! -f "$source_file" ]; then
    echo "Error: source file '$source_file' does not exist" >&2
    exit 1
fi

if [ ! -r "$source_file" ]; then
    echo "Error: source file '$source_file' is not readable" >&2
    exit 1
fi

# Ha a célfájl már létezik, írhatónak kell lennie (-w).
if [ -e "$destination_file" ] && [ ! -w "$destination_file" ]; then
    echo "Error: destination file '$destination_file' is not writable" >&2
    exit 1
fi

if [ ! -e "$destination_file" ]; then
    echo "Destination file '$destination_file' does not exist, creating it."
fi

# --- Másolás soronként -------------------------------------------------------
# A read egy sort olvas be a záró újsor NÉLKÜL, ezért kiíráskor (printf '%s\n')
# nekünk kell visszatenni az újsort.
#   IFS=   a sor eleji / végi szóközök megmaradnak
#   -r     a \ karakter is változatlanul megmarad
#
# Fájlvég: ha a fájl utolsó sora után NINCS újsor (pl. a source.txt-ben a "8"
# után), a read ezt a sort még beolvassa a line változóba, de HAMIS értékkel
# tér vissza, így a ciklusmag nem fut le rá. Ezért a ciklus után megnézzük:
# ha a line nem üres, az a lezáratlan utolsó sor, ezt újsor NÉLKÜL írjuk ki.
#
# Döntés: a másolat így bájtra azonos az eredetivel (mint a cp esetén):
#   - ha az eredeti újsorral végződött, a másolat is,
#   - ha nem, a másolat sem (nem "javítjuk ki" a fájlt, csak másolunk).
# A Windows-os \r karaktert sem vágjuk le, hiszen az is a tartalom része.
# (Ha mindig újsorral lezárt fájlt szeretnénk, elég a ciklus fejét
#  while IFS= read -r line || [ -n "$line" ]; do  alakra cserélni, és a
#  ciklus utáni if-et elhagyni.)
#
# A { ... } blokk összes kimenete a > miatt a célfájlba kerül, a bemenete a
# < miatt a forrásfájlból jön. Nincs csővezeték, így nincs subshell sem: a
# line változó a ciklus után is látszik.
{
    while IFS= read -r line; do
        printf '%s\n' "$line"
    done
    if [ -n "$line" ]; then
        printf '%s' "$line"
    fi
} < "$source_file" > "$destination_file"

echo "Content copied from '$source_file' to '$destination_file'."
