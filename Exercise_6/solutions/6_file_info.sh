#!/bin/bash
# 6. feladat: Mi van a fájl végén? A script kiírja a paraméterként kapott
# fájl sorainak számát (wc -l és ciklus szerint), hogy újsorral végződik-e,
# hány üres sora van, és hány sora végződik Windows-os \r\n sorvéggel.
#
# Futtatás (a tasks mappából):
#   ../solutions/6_file_info.sh numbers_no_newline.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "Error: file '$file' does not exist" >&2
    exit 1
fi

lines=0
empty_lines=0
crlf_lines=0

while IFS= read -r line || [ -n "$line" ]; do
    lines=$(( lines + 1 ))

    # Windows-os sorvég: a sor végén ott marad a \r karakter ($'\r').
    if [[ $line == *$'\r' ]]; then
        crlf_lines=$(( crlf_lines + 1 ))
        line=${line%$'\r'}              # a \r levágása
    fi

    if [ -z "$line" ]; then
        empty_lines=$(( empty_lines + 1 ))
    fi
done < "$file"

# A $( ) levágja a záró újsort: ha a fájl utolsó karaktere \n, az eredmény üres.
if [ -z "$(tail -c 1 "$file")" ]; then
    ends_with_newline="yes"
else
    ends_with_newline="NO"
fi

# A $(( )) a macOS-en a wc kimenete elé tett szóközöket is eltünteti.
echo "File:                 $file"
echo "Lines (wc -l):        $(( $(wc -l < "$file") ))"
echo "Lines (read loop):    $lines"
echo "Ends with newline:    $ends_with_newline"
echo "Empty lines:          $empty_lines"
echo "Lines ending in CRLF: $crlf_lines"
