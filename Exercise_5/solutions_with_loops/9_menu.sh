#!/bin/bash
# 9. feladat (ciklusos megoldás): Interaktív menü. A menüpontok a cut / sort /
# grep parancsok helyett ciklusokkal dolgoznak (lásd a 2. és a 8. feladat
# ciklusos megoldását).
#
# Futtatás (a tasks mappából, mert a menüpontok az itteni fájlokat használják):
#   ../solutions_with_loops/9_menu.sh

menu_file="menu.txt"
patients_file="patients.txt"

for f in "$menu_file" "$patients_file"; do
    if [ ! -f "$f" ]; then
        echo "Error: '$f' not found, run the script from the tasks directory" >&2
        exit 1
    fi
done

# --- Függvények ---------------------------------------------------------------

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

    for file in *.txt; do
        if [ -f "$file" ]; then
            ((count++))
        fi
    done

    echo "Number of .txt files: $count"
}

# A betegségek listája ábécérendben, mindegyik egyszer (a cut | sort -u helyett).
list_illnesses() {
    local name date illness
    local illnesses=()
    local i j n tmp already

    # 1. lépés: a különböző betegségek összegyűjtése egy tömbbe.
    while IFS=, read -r name date illness || [ -n "$name" ]; do
        illness=${illness%$'\r'}        # Windows-os (CRLF) sorvég levágása
        if [ -z "$illness" ]; then
            continue
        fi

        already=0
        for (( i=0; i<${#illnesses[@]}; i++ )); do
            if [ "${illnesses[i]}" == "$illness" ]; then
                already=1
                break
            fi
        done

        if [ "$already" -eq 0 ]; then
            illnesses+=("$illness")
        fi
    done < "$patients_file"

    # 2. lépés: buborékrendezés ábécérendbe.
    n=${#illnesses[@]}
    for (( i=0; i<n-1; i++ )); do
        for (( j=0; j<n-1-i; j++ )); do
            if [[ ${illnesses[j]} > ${illnesses[j+1]} ]]; then
                tmp=${illnesses[j]}
                illnesses[j]=${illnesses[j+1]}
                illnesses[j+1]=$tmp
            fi
        done
    done

    # 3. lépés: kiírás.
    for (( i=0; i<n; i++ )); do
        echo "${illnesses[i]}"
    done
}

# Szó keresése a menu.txt-ben, kis- és nagybetűtől függetlenül, egész szóként
# (a grep -iw helyett, ugyanúgy, mint a 2. feladat ciklusos megoldásában).
search_word() {
    local word line w found=0
    local words=()

    read -r -p "Word to search: " word

    if [ -z "$word" ]; then
        echo "Error: the word cannot be empty" >&2
        return
    fi

    # A [[ == ]] ezután nem különbözteti meg a kis- és nagybetűket (grep -i).
    # (A ${w,,} kisbetűsítés bash 4-es, a macOS bash 3.2-je nem ismeri.)
    # A függvény végén visszakapcsoljuk, hogy a script többi részére ne hasson.
    shopt -s nocasematch

    while IFS= read -r line || [ -n "$line" ]; do
        line=${line%$'\r'}
        read -r -a words <<< "$line"
        for w in "${words[@]}"; do
            if [[ $w == "$word" ]]; then
                echo "$line"
                found=1
                break
            fi
        done
    done < "$menu_file"

    shopt -u nocasematch

    if [ "$found" -eq 0 ]; then
        echo "No line contains '$word'."
    fi
}

# --- Főciklus -----------------------------------------------------------------
operations=0

while true; do
    print_menu

    if ! read -r -p "Your choice: " choice; then
        echo
        break
    fi

    case "$choice" in
        1) show_date ;;
        2) show_user ;;
        3) count_txt_files ;;
        4) list_illnesses ;;
        5) search_word ;;
        0)
            break
            ;;
        *)
            echo "Error: invalid choice '$choice'" >&2
            continue
            ;;
    esac

    ((operations++))
done

echo "Bye! You ran $operations operation(s)."
