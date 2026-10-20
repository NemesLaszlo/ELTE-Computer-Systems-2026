#!/bin/bash
# 6. heti további gyakorlás, 3. feladat: Naplófájl szétválogatása. A server.log
# sorai  dátum idő SZINT üzenet  formájúak. A sorokat szintenként külön
# fájlba írjuk (info.log, warning.log, error.log), és kiírjuk, melyik szintből
# hány sor volt.
#
# Futtatás (az exercise_6_solutions mappából):
#   ./3_split_log.sh server.log
#
# Elvárt eredmény: 5 INFO, 2 WARNING, 2 ERROR. Az utolsó sor ("Backup
# finished") után nincs újsor, a || [ -n "$line" ] nélkül csak 4 INFO lenne.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log_file>" >&2
    exit 1
fi

log_file=$1

if [ ! -f "$log_file" ]; then
    echo "Error: file '$log_file' does not exist" >&2
    exit 1
fi

# A kimeneti fájlokat kiürítjük: így a többszöri futtatás ugyanazt az
# eredményt adja, nem fűz hozzá az előzőhöz.
> info.log
> warning.log
> error.log

info=0
warning=0
error=0

while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}

    if [ -z "$line" ]; then
        continue
    fi

    # A sor szavakra bontása: a 3. szó a szint, a többi (message) nem kell.
    # A read az utolsó változóba a sor maradékát teszi (lásd 5. hét).
    read -r date time level message <<< "$line"

    # A teljes sort írjuk a szint fájljába, nem csak az üzenetet.
    case "$level" in
        INFO)
            echo "$line" >> info.log
            info=$(( info + 1 ))
            ;;
        WARNING)
            echo "$line" >> warning.log
            warning=$(( warning + 1 ))
            ;;
        ERROR)
            echo "$line" >> error.log
            error=$(( error + 1 ))
            ;;
        *)
            echo "Warning: unknown level '$level', line skipped: '$line'" >&2
            ;;
    esac
done < "$log_file"

echo "INFO:    $info line(s) -> info.log"
echo "WARNING: $warning line(s) -> warning.log"
echo "ERROR:   $error line(s) -> error.log"

# Ugyanez ciklus nélkül, három grep-pel (a -w miatt csak egész szóra illeszkedik):
#   grep -w INFO "$log_file" > info.log
#   grep -c -w INFO "$log_file"
