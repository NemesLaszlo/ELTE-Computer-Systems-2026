#!/bin/bash
# 5. heti további gyakorlás, 4. feladat: a 9. órai feladat (interaktív menü)
# bővítése egy új menüponttal (6), amely a 7. feladat alapján biztonsági
# mentést készít a main_folder könyvtár .txt fájljairól. A mentést végző kód
# a backup_directory függvénybe került.
#
# Az eredeti script változatlan maradt, csak az új részek kerültek bele:
# a backup_dir_source változó, a backup_directory függvény, a 6) menüpont.
#
# Futtatás (az exercise_5_solutions mappából, mert a menüpontok az itteni
# fájlokat használják):
#   ./4_menu_with_backup.sh

# A menüpontok által használt fájlok.
menu_file="menu.txt"
patients_file="patients.txt"
backup_dir_source="main_folder"     # ÚJ: a 6. menüpont ezt a könyvtárat menti

# Ha valamelyik fájl hiányzik, a script el sem indul.
for f in "$menu_file" "$patients_file"; do
    if [ ! -f "$f" ]; then
        echo "Error: '$f' not found, run the script from its directory" >&2
        exit 1
    fi
done

# --- Függvények ---------------------------------------------------------------
# Minden menüponthoz egy függvény tartozik, így a főciklus rövid és áttekinthető.

print_menu() {
    echo
    echo "===== MENU ====="
    echo "1) Current date and time"
    echo "2) Logged in user and home directory"
    echo "3) Number of .txt files in the current directory"
    echo "4) List of illnesses ($patients_file)"
    echo "5) Search a word in $menu_file"
    echo "6) Backup of $backup_dir_source (.txt files)"
    echo "0) Exit"
}

show_date() {
    date
}

show_user() {
    echo "User: $USER"
    echo "Home: $HOME"
}

count_txt_files() {
    local count=0
    local file

    # Lásd a 7. feladatot: ha nincs .txt fájl, a *.txt szó szerint marad,
    # ezért az -f vizsgálat kell.
    for file in *.txt; do
        if [ -f "$file" ]; then
            ((count++))
        fi
    done

    echo "Number of .txt files: $count"
}

list_illnesses() {
    cut -d ',' -f 3 "$patients_file" | sort -u
}

search_word() {
    local word

    # A menüponton belül kérünk be további adatot a felhasználótól.
    read -r -p "Word to search: " word

    if [ -z "$word" ]; then
        echo "Error: the word cannot be empty" >&2
        return
    fi

    if ! grep -iw "$word" "$menu_file"; then
        echo "No line contains '$word'."
    fi
}

# ÚJ: biztonsági mentés, a 7. feladat scriptje függvénybe csomagolva.
# A különbség: hiba esetén nem exit-tel lépünk ki (az a teljes menüt
# leállítaná), hanem return-nel csak a függvényből térünk vissza.
backup_directory() {
    local directory=$1
    local backup_dir
    local file
    local count=0

    if [ ! -d "$directory" ]; then
        echo "Error: directory '$directory' does not exist" >&2
        return 1
    fi

    backup_dir="$(basename "$directory")_backup_$(date +%F)"
    mkdir -p "$backup_dir"

    for file in "$directory"/*.txt; do
        if [ ! -f "$file" ]; then
            continue
        fi
        cp "$file" "$backup_dir"
        echo "Copied: $file"
        ((count++))
    done

    if (( count == 0 )); then
        echo "No .txt files found in '$directory'."
        rmdir "$backup_dir"
        return 0
    fi

    echo "$count file(s) backed up to '$backup_dir'."
}

# --- Főciklus -----------------------------------------------------------------
operations=0

while true; do
    print_menu

    # Ha a read nem tud olvasni (pl. Ctrl+D), kilépünk a ciklusból,
    # különben végtelen ciklusba kerülnénk.
    if ! read -r -p "Your choice: " choice; then
        echo
        break
    fi

    # Az egysoros ágakat tömörebben is írhatjuk:  minta) parancs ;;
    case "$choice" in
        1) show_date ;;
        2) show_user ;;
        3) count_txt_files ;;
        4) list_illnesses ;;
        5) search_word ;;
        6) backup_directory "$backup_dir_source" ;;
        0)
            break           # kilépés a ciklusból
            ;;
        *)
            echo "Error: invalid choice '$choice'" >&2
            continue        # a számlálót nem növeljük, jön a következő kör
            ;;
    esac

    ((operations++))
done

echo "Bye! You ran $operations operation(s)."
