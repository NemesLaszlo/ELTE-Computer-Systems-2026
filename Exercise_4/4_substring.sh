#!/bin/bash
# Részszöveg (substring) kivágása és egyszerű szövegműveletek.
#
# Futtatás:
#   ./4_substring.sh

str="ELTE IK University"
#    0123456789...        <- a karakterek sorszámozása 0-tól indul

# ${valtozo:kezdet:hossz}
# Az 5 a kezdőpozíció (0-tól számolva), a 2 a kivágott rész hossza.
subStr=${str:5:2}
echo "$subStr"          # IK

# Ha a hosszt elhagyjuk, a kezdőpozíciótól a szöveg végéig tart a kivágás.
echo "${str:8}"         # University

# Negatív kezdőpozíció: a szöveg végétől számol.
# Figyelem: a : után szóköz kell, különben mást jelent (alapértelmezett érték)!
echo "${str: -10}"      # University

# Csere a szövegben: ${valtozo/mit/mire}  (// esetén az összes előfordulást cseréli)
echo "${str/IK/TTK}"    # ELTE TTK University

# Kis- és nagybetűssé alakítás (bash 4-től)
echo "${str^^}"         # ELTE IK UNIVERSITY
echo "${str,,}"         # elte ik university
