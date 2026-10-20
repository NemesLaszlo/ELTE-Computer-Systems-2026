#!/bin/bash
# 5. feladat: A fájlban minden megadott szót kicserél egy másikra. Magát a
# fájlt módosítja, ezért érdemes előbb egy másolaton kipróbálni.
#
# Futtatás (a tasks mappából):
#   cp replace.txt test.txt
#   ../solutions/5_replace_word.sh test.txt alma barack
#   cat test.txt

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <file> <word_to_replace> <replacement_word>" >&2
    exit 1
fi

file=$1
word_to_replace=$2
replacement_word=$3

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

# A cserét a sed végzi, a 4. héten látott s/minta/csere/ paranccsal:
#   s/.../.../    csere (substitute) a fájl minden sorában
#   g             (global) a sor MINDEN előfordulását cseréli, nem csak az elsőt
#   A minta dupla idézőjelben van, hogy a két változó behelyettesítődjön.
#
# Nem írhatunk közvetlenül a beolvasott fájlba (a > már az olvasás előtt
# kiürítené), ezért az eredményt egy ideiglenes fájlba írjuk, majd az mv-vel
# felülírjuk vele az eredetit (lásd 5. hét, 4. feladat).
sed "s/$word_to_replace/$replacement_word/g" "$file" > "$file.tmp"
mv "$file.tmp" "$file"

echo "Word '$word_to_replace' replaced with '$replacement_word' in '$file'."

# Megjegyzések:
#   - A sed részszót is cserél (az "almafa" is "barackfa" lesz). GNU sed-del
#     (Linux, Git Bash) a \b szóhatárral csak egész szót: "s/\b$word_to_replace\b/…/g"
#   - Ugyanez sed nélkül, az univerzális mintával soronként olvasva:
#         echo "${line//$word_to_replace/$replacement_word}"   (a ciklusban)
#     a ciklus kimenetét pedig a .tmp fájlba irányítjuk: done < "$file" > "$file.tmp"
