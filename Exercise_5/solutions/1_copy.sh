#!/bin/bash
# 1. feladat: Fájl tartalmának átmásolása egy másik fájlba (egy egyszerű
# "burkoló" a cp parancs felett), hibakezeléssel.
#
# Futtatás (a tasks mappából):
#   ../solutions/1_copy.sh source.txt target.txt

# --- Paraméterek ellenőrzése -------------------------------------------------
# Pontosan két paramétert várunk: a forrás- és a célfájl nevét.
# A használati útmutató hibaüzenet, ezért a standard errorra írjuk (>&2),
# és nem nulla kilépési kóddal állunk le (exit 1).
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_file> <destination_file>" >&2
    exit 1
fi

# Beszédes nevű változók a paramétereknek.
source_file=$1
destination_file=$2

# A forrásfájlnak léteznie kell (-f: létezik és sima fájl) ...
if [ ! -f "$source_file" ]; then
    echo "Error: source file '$source_file' does not exist" >&2
    exit 1
fi

# ... és olvashatónak is kell lennie (-r), különben a cp hibát adna.
if [ ! -r "$source_file" ]; then
    echo "Error: source file '$source_file' is not readable" >&2
    exit 1
fi

# --- Másolás ------------------------------------------------------------------
# Ha a célfájl még nem létezik (-e: létezik, bármilyen típusú), létrehozzuk.
# A touch egy üres fájlt hoz létre (a cp ezt magától is megtenné, de a feladat
# ezt kéri, és így a felhasználó is értesül róla).
if [ ! -e "$destination_file" ]; then
    echo "Destination file '$destination_file' does not exist, creating it."
    touch "$destination_file"
fi

# Az if közvetlenül egy parancs sikerességét is vizsgálhatja: a feltétel akkor
# igaz, ha a parancs kilépési kódja 0. Így a cp eredménye alapján döntünk.
if cp "$source_file" "$destination_file"; then
    echo "Content copied from '$source_file' to '$destination_file'."
else
    # A cp a saját hibaüzenetét már kiírta az stderr-re, mi csak hibakóddal lépünk ki.
    echo "Error: copy failed" >&2
    exit 1
fi
