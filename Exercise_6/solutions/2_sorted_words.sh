#!/bin/bash
# 2. feladat: Szavak beolvasása egészen addig, amíg a "vége" szót be nem írjuk,
# majd a beolvasott szavak kiírása ábécérendben.
#
# Futtatás (a tasks mappából):
#   ../solutions/2_sorted_words.sh                 a billentyűzetről
#   ../solutions/2_sorted_words.sh < words.txt     egy fájlból

words=()

# A read akkor is leáll, ha elfogyott a bemenet (Ctrl+D, vagy a fájl vége).
# A || [ -n "$word" ] az utolsó, újsor nélküli sort is feldolgozza.
while read -r -p "Enter a word (vége to finish): " word || [ -n "$word" ]; do
    if [ "$word" == "vége" ]; then
        break
    fi

    # Az üres sor (csak Enter) nem szó.
    if [ -n "$word" ]; then
        words+=("$word")        # a szó hozzáadása a tömb végéhez
    fi
done

# ${#words[@]}: a tömb elemeinek száma
if [ "${#words[@]}" -eq 0 ]; then
    echo "No words were given."
    exit 0
fi

# A printf minden szót külön sorba ír, a sort ábécérendbe teszi őket.
echo "Sorted words:"
printf '%s\n' "${words[@]}" | sort
