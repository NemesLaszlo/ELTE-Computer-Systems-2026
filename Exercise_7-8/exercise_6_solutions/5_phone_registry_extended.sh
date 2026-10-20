#!/bin/bash
# 6. heti további gyakorlás, 5. feladat: a 5. órai feladat (telefonregiszter)
# bővítése két új kapcsolóval. A phone_registry.txt fájl soronként egy
# bejegyzést tárol:  Név,telefonszám
#
#   -a <név> <szám>        új bejegyzés (ugyanaz a név nem lehet kétszer)
#   -d <név>               a bejegyzés törlése
#   -e <név> <új szám>     a név telefonszámának módosítása (ÚJ)
#   -i <fájl>              bejegyzések importálása egy fájlból (ÚJ)
#   -s <minta>             a mintát tartalmazó nevek és számaik
#   -c                     a tárolt telefonszámok száma
#   -o                     a nevek ábécérendben, mindegyik egyszer
#
# Az eredeti script változatlan maradt, csak az új részek kerültek bele:
# az edit_entry és az import_entries függvény, a -e és -i ág a case-ben.
#
# Futtatás (az exercise_6_solutions mappából):
#   ./5_phone_registry_extended.sh -i new_contacts.txt
#   ./5_phone_registry_extended.sh -e "Kiss Anna" 06301111111
#   ./5_phone_registry_extended.sh -o
#
# Elvárt eredmény importálásnál: 2 új név (Varga Gergő, Molnár Hanna),
# a Kiss Anna már szerepel, a "Hibás Sor" hibás, a két üres sor kimarad.
# A new_contacts.txt Windows-os (CRLF) sorvégű, és szóközök is vannak benne.

registry_file="phone_registry.txt"

# Ha még nincs regiszter, létrehozzuk.
if [ ! -f "$registry_file" ]; then
    touch "$registry_file"
fi

# Az új bejegyzés hozzáfűzése előtt pótoljuk a hiányzó záró újsort, különben
# az új sor az utolsóhoz ragadna (lásd 6. hét). Több helyről hívjuk, ezért
# függvény.
ensure_trailing_newline() {
    if [ -n "$(tail -c 1 "$registry_file")" ]; then
        echo >> "$registry_file"
    fi
}

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

    ensure_trailing_newline
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
    grep -v "^$name," "$registry_file" > "$registry_file.tmp"
    mv "$registry_file.tmp" "$registry_file"
    echo "Deleted: $name"
}

# ÚJ: egy meglévő név telefonszámának módosítása.
edit_entry() {
    local name=$1
    local phone=$2
    local current_name current_phone

    if [ -z "$name" ] || [ -z "$phone" ]; then
        echo "Error: -e requires a name and a new phone number" >&2
        exit 1
    fi

    if [[ ! $phone =~ ^\+?[0-9]+$ ]]; then
        echo "Error: '$phone' is not a valid phone number" >&2
        exit 1
    fi

    if ! grep -q "^$name," "$registry_file"; then
        echo "Error: '$name' is not in the registry" >&2
        exit 1
    fi

    # Soronként átírjuk a fájlt egy ideiglenes fájlba: a keresett névnél az új
    # számot írjuk, a többi sort változatlanul. (Ugyanabba a fájlba nem
    # írhatunk: a > még az olvasás előtt kiürítené.)
    while IFS=, read -r current_name current_phone || [ -n "$current_name" ]; do
        if [ "$current_name" == "$name" ]; then
            echo "$name,$phone"
        else
            echo "$current_name,$current_phone"
        fi
    done < "$registry_file" > "$registry_file.tmp"
    mv "$registry_file.tmp" "$registry_file"

    echo "Updated: $name,$phone"
}

# ÚJ: bejegyzések importálása egy  Név,szám  formátumú fájlból. A hibás
# sorokat és a már meglévő neveket kihagyjuk, de a script NEM áll le
# (continue, nem exit), mert a többi sor még lehet jó.
import_entries() {
    local file=$1
    local name phone
    local added=0 skipped=0 invalid=0

    if [ -z "$file" ]; then
        echo "Error: -i requires a file name" >&2
        exit 1
    fi

    if [ ! -f "$file" ]; then
        echo "Error: file '$file' does not exist" >&2
        exit 1
    fi

    while IFS=, read -r name phone || [ -n "$name" ]; do
        # Tisztítás: a névből csak a sor ELEJI és VÉGI szóközöket törölhetjük
        # (a "Molnár Hanna" belső szóköze kell), ezt a sed két cseréje teszi:
        # ^[[:space:]]* a sor eleji, [[:space:]]*$ a sor végi szóközök (és a
        # Windows-os \r). A számból minden szóköz jellegű karaktert a tr töröl.
        name=$(echo "$name" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        phone=$(echo "$phone" | tr -d '[:space:]')

        # Üres sor: kihagyjuk csendben.
        if [ -z "$name" ] && [ -z "$phone" ]; then
            continue
        fi

        # Hibás sor: nincs szám, vagy nem szám.
        if [[ ! $phone =~ ^\+?[0-9]+$ ]]; then
            echo "Invalid line skipped: '$name,$phone'" >&2
            invalid=$(( invalid + 1 ))
            continue
        fi

        if grep -q "^$name," "$registry_file"; then
            echo "Already in the registry, skipped: $name"
            skipped=$(( skipped + 1 ))
            continue
        fi

        ensure_trailing_newline
        echo "$name,$phone" >> "$registry_file"
        echo "Added: $name,$phone"
        added=$(( added + 1 ))
    done < "$file"

    echo "Import finished: $added added, $skipped already present, $invalid invalid."
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
    -e) edit_entry "$2" "$3" ;;
    -i) import_entries "$2" ;;
    -s) search_entry "$2" ;;
    -c) count_entries ;;
    -o) list_names ;;
    *)
        echo "Usage: $0 -a <name> <phone> | -d <name> | -e <name> <phone> | -i <file> | -s <pattern> | -c | -o" >&2
        exit 1
        ;;
esac
