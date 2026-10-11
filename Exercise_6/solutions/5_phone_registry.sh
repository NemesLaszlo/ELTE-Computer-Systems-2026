#!/bin/bash
# 5. feladat: Telefonregiszter. A phone_registry.txt fájl soronként egy
# bejegyzést tárol:  Név,telefonszám
#
#   -a <név> <szám>   új bejegyzés (ugyanaz a név nem lehet kétszer)
#   -d <név>          a bejegyzés törlése
#   -s <minta>        a mintát tartalmazó nevek és számaik
#   -c                a tárolt telefonszámok száma
#   -o                a nevek ábécérendben, mindegyik egyszer
#
# Futtatás (a tasks mappából):
#   ../solutions/5_phone_registry.sh -a "Szabó Dénes" 06301112222
#   ../solutions/5_phone_registry.sh -s szab

registry_file="phone_registry.txt"

# Ha még nincs regiszter, létrehozzuk.
if [ ! -f "$registry_file" ]; then
    touch "$registry_file"
fi

add_entry() {
    local name=$1
    local phone=$2

    if [ -z "$name" ] || [ -z "$phone" ]; then
        echo "Error: -a requires a name and a phone number" >&2
        exit 1
    fi

    # Telefonszám: opcionális + jel, utána csak számjegyek.
    if [[ ! $phone =~ ^\+?[0-9]+$ ]]; then
        echo "Error: '$phone' is not a valid phone number" >&2
        exit 1
    fi

    # grep -q: nem ír ki semmit, csak a kilépési kódja jelzi, volt-e találat.
    # "^$name," : a sor elején álló név, utána vessző (pontos névegyezés)
    if grep -q "^$name," "$registry_file"; then
        echo "Error: '$name' is already in the registry" >&2
        exit 1
    fi

    # A tasks/phone_registry.txt utolsó sora után nincs újsor. Ha így írnánk a
    # végére, az új bejegyzés az utolsó sorhoz ragadna. A tail -c 1 a fájl
    # utolsó karaktere; a $( ) levágja az újsort, tehát ha az eredmény nem
    # üres, a fájl nem újsorral végződik: ilyenkor előbb írunk egy újsort.
    if [ -n "$(tail -c 1 "$registry_file")" ]; then
        echo >> "$registry_file"
    fi

    echo "$name,$phone" >> "$registry_file"
    echo "Added: $name,$phone"
}

delete_entry() {
    local name=$1

    if [ -z "$name" ]; then
        echo "Error: -d requires a name" >&2
        exit 1
    fi

    if ! grep -q "^$name," "$registry_file"; then
        echo "'$name' is not in the registry."
        return
    fi

    # grep -v: azokat a sorokat adja, amelyek NEM illeszkednek. Ezeket egy
    # ideiglenes fájlba írjuk, majd azzal felülírjuk az eredetit.
    # (Ugyanabba a fájlba nem írhatunk: a > még az olvasás előtt kiüríti.)
    grep -v "^$name," "$registry_file" > "$registry_file.tmp"
    mv "$registry_file.tmp" "$registry_file"
    echo "Deleted: $name"
}

search_entry() {
    local pattern=$1

    if [ -z "$pattern" ]; then
        echo "Error: -s requires a pattern" >&2
        exit 1
    fi

    if ! grep -qi "$pattern" "$registry_file"; then
        echo "No name matches '$pattern'."
        return
    fi

    # -i: kis- és nagybetű mindegy. A találatokat "Név: szám" alakban írjuk ki.
    grep -i "$pattern" "$registry_file" | while IFS=, read -r name phone; do
        echo "$name: $phone"
    done
}

count_entries() {
    # A wc -l az újsorokat számolja, ezért ha az utolsó sor után nincs újsor,
    # eggyel kevesebbet mond. A grep -c '' minden sort megszámol.
    echo "Number of phone numbers: $(grep -c '' "$registry_file")"
}

list_names() {
    # cut: az 1. mező (név), sort -u: rendezés, mindegyik csak egyszer
    cut -d ',' -f 1 "$registry_file" | sort -u
}

case "$1" in
    -a) add_entry "$2" "$3" ;;
    -d) delete_entry "$2" ;;
    -s) search_entry "$2" ;;
    -c) count_entries ;;
    -o) list_names ;;
    *)
        echo "Usage: $0 -a <name> <phone> | -d <name> | -s <pattern> | -c | -o" >&2
        exit 1
        ;;
esac
