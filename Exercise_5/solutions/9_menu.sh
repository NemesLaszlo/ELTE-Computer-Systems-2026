#!/bin/bash
# 9. feladat: Interaktív menü. A script kiír egy menüt, bekéri a felhasználó
# választását, és elvégzi a megfelelő műveletet, egészen addig, amíg a
# felhasználó ki nem lép (0). Kilépéskor kiírja, hány műveletet futtatott.
#
# Futtatás (a tasks mappából, mert a menüpontok az itteni fájlokat használják):
#   ../solutions/9_menu.sh

# A menüpontok által használt fájlok.
menu_file="menu.txt"
patients_file="patients.txt"

# Ha valamelyik fájl hiányzik, a script el sem indul.
for f in "$menu_file" "$patients_file"; do
    if [ ! -f "$f" ]; then
        echo "Error: '$f' not found, run the script from the tasks directory" >&2
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
