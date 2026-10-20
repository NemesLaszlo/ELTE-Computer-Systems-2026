#!/bin/bash
# 3. feladat: A forrásfájl sorait átmásolja a célfájlba, KIVÉVE azokat,
# amelyek tartalmazzák a megadott szót.
#
# Futtatás (a tasks mappából):
#   ../solutions/3_copy_without_word.sh sentences.txt filtered.txt harmadik
#   cat filtered.txt

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_file> <destination_file> <search_word>" >&2
    exit 1
fi

source_file=$1
destination_file=$2
search_word=$3

if [ ! -f "$source_file" ]; then
    echo "Error: file '$source_file' does not exist" >&2
    exit 1
fi

# Ha a célfájl nem létezik, létrehozzuk; ha létezik, kiürítjük. Enélkül a
# második futtatás az első eredmény végére írna, mert a ciklusban >>-rel
# hozzáfűzünk (lásd 6. hét).
if [ ! -f "$destination_file" ]; then
    echo "Destination file '$destination_file' does not exist, creating it."
fi
> "$destination_file"

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}              # Windows-os sorvég (\r) levágása

    if [ -z "$line" ]; then         # üres sor kihagyása
        continue
    fi

    # [[ $line != *"$search_word"* ]] : helyettesítő karakteres (glob) minta,
    # nem regex. A * bármilyen (akár üres) szöveg, tehát a feltétel akkor igaz,
    # ha a szó NEM része a sornak. A $search_word idézőjelben van, így a benne
    # lévő speciális karakterek (pl. *) is betű szerint illeszkednek.
    if [[ $line != *"$search_word"* ]]; then
        echo "$line" >> "$destination_file"
    fi
done < "$source_file"

echo "Lines not containing '$search_word' copied to '$destination_file'."

# Ugyanez egyetlen paranccsal: a grep -v a NEM illeszkedő sorokat adja.
#   grep -v "$search_word" "$source_file" > "$destination_file"
