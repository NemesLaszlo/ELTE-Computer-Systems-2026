#!/bin/bash
# Bekér egy könyvtárnevet: ha létezik, jelzi, ha nem létezik, létrehozza.
#
# Futtatás:
#   ./dir_tester.sh
# Kipróbáláshoz: a test_dir könyvtár már létezik a script mellett.

# read: egy sort olvas be a billentyűzetről (standard input) az ndir változóba.
#   -r  a \ karaktert nem kezeli speciálisan, a beírt szöveg változtatás nélkül
#       kerül a változóba (pl. a "my\dir" nem alakul át "mydir"-ré)
#   -p  beolvasás előtt kiírja a megadott szöveget (prompt), sortörés nélkül,
#       így a felhasználó ugyanabba a sorba gépelhet
read -r -p "Enter directory name: " ndir

# Minden folyamatnak három szabványos adatfolyama van, mindegyiket egy szám azonosítja:
#   0  stdin   bemenet
#   1  stdout  normál kimenet
#   2  stderr  hibaüzenetek
#
# >&2: az echo kimenetét a standard output (1) helyett a standard errorra (2) irányítja.
#   >   a kimenet átirányítása (alapértelmezetten az stdout-é, vagyis az 1> rövidítése)
#   &2  a 2-es adatfolyamba; az & nélkül (>2) egy "2" nevű FÁJLBA írnánk!
#
# Így a hibaüzenet akkor is a terminálon jelenik meg, ha a script kimenetét
# fájlba (> out.txt) vagy másik parancsba (|) irányítjuk.

# Üres bemenet kiszűrése (-z: a string üres).
if [ -z "$ndir" ]; then
    echo "Directory name cannot be empty" >&2   # a hibaüzenet a standard errorra megy
    exit 1                                      # nem 0 kilépési kód = hiba
fi

# Fájlokra vonatkozó vizsgálatok:
#   -e  létezik (bármi)         -r  olvasható
#   -f  létezik és sima fájl    -w  írható
#   -d  létezik és könyvtár     -x  futtatható
#   -s  létezik és nem üres
#
# A "$ndir" idézőjelei miatt szóközt tartalmazó névvel is működik.
if [ -d "$ndir" ]; then
    echo "Directory exist"
else
    # -p: a hiányzó szülőkönyvtárakat is létrehozza (pl. a/b/c)
    mkdir -p "$ndir"
    echo "Directory created"
fi
